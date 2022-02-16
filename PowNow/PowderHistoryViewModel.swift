
import Foundation
import SwiftCSV

class PowderHistoryViewModel {

    private var totalSnowDepth: [String]?
    private var snowDepthDateTime: [String]?

    func downloadCSVData(completion: @escaping (Error?) -> Void) {
        guard let url = snowDepthCSVURL() else {
            return
        }
        AsyncFileLoader.loadFileAsync(url: url) { path, error in
            guard let path = path else { return }
            DispatchQueue.main.async { [unowned self] in
                do {
                    let pathURL = URL(fileURLWithPath: path)
                    let resource: CSV? = try CSV(url: pathURL, delimiter: ",", encoding: .utf8, loadColumns: true)
                    self.totalSnowDepth = resource?.namedColumns["\" (5800') Timberline Lodge"]
                    let dateTimes = resource?.namedColumns["Date/Time (PST)"]
                    self.snowDepthDateTime = formatSnowDepthDateTimes(dateTimes)
                    completion(nil)
                } catch let parseError as CSVParseError {
                    print("parse error: \(parseError)")
                    completion(parseError)
                } catch {
                    print("file error: \(error)")
                    completion(error)
                }
            }
        }
    }

    func getSnowDepthDateForRow(_ row: Int) -> String? {
        guard row < snowDepthDateTime?.count ?? 0 else { return nil }
        return snowDepthDateTime?[row]
    }

    func totalSnowDepthForRow(_ row: Int) -> String? {
        guard row < totalSnowDepth?.count ?? 0 else { return nil }
        return totalSnowDepth?[row]
    }

    func numberOfRows() -> Int {
        guard let snowDepth = totalSnowDepth, let dateTime = snowDepthDateTime else { return 0 }
        if snowDepth.count < dateTime.count {
            return snowDepth.count
        } else {
            return dateTime.count
        }
    }

    func snowFallWithin24hoursInPrevious(hours: Int) -> Decimal? {
        guard hours <= 24 else { return nil }
        guard let pastSnowDepth = totalSnowDepthForRow(hours),
              let snowDepthNow = totalSnowDepthForRow(0) else { return nil }

        guard var tempFormattedPastSnowDepth = Decimal(string: pastSnowDepth),
              var tempFormattedSnowDepthNow = Decimal(string: snowDepthNow) else { return nil }
        var formattedPastSnowDepth = tempFormattedPastSnowDepth
        var formattedSnowDepthNow = tempFormattedPastSnowDepth
        NSDecimalRound(&formattedPastSnowDepth, &tempFormattedPastSnowDepth, 1, .plain)
        NSDecimalRound(&formattedSnowDepthNow, &tempFormattedSnowDepthNow, 1, .plain)

        let snowAccumulation = formattedSnowDepthNow - formattedPastSnowDepth
        return snowAccumulation
    }

    func latestSnowReading() -> String {
        snowDepthDateTime?.first ?? ""
    }

}

private extension PowderHistoryViewModel {

    func formatSnowDepthDateTimes(_ dates: [String]?) -> [String]? {
        guard let dates = dates else { return nil }
        let removedYearAndSecondsDateTimes = dates.map { String($0.dropLast(3).dropFirst(5)) }
        return removedYearAndSecondsDateTimes
    }

    func snowDepthCSVURL() -> URL? {
        let oneDay = TimeInterval(86400)

        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let tomorrow = today + oneDay
        let tomorrowsDate = dateFormatter.string(from: tomorrow)

        let yesterday = today - oneDay
        let yesterdaysDate = dateFormatter.string(from: yesterday)

        let snowDepth = "https://nwac.us/data-portal/csv/mt-hood/sensortype/snow_depth/start-date/\(yesterdaysDate)/end-date/\(tomorrowsDate)"
        return URL(string: snowDepth)
    }

}

class AsyncFileLoader {

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) {

        let destinationUrl = createFileDestinationPath()

        if didDownloadFileRecentlyTo(destinationUrl: destinationUrl) {
            print("File downloaded recently [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else {
            removePreviousDownloadedSnowDepthFiles()
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                    completion(destinationUrl.path, error)
                                } else {
                                    completion(destinationUrl.path, error)
                                }
                            } else {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                } else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }

}

private extension AsyncFileLoader {

    static func createFileDestinationPath() -> URL {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let snowDepthCSVLocationUrl = documentsUrl.appendingPathComponent("snowDepthCSVs")

        let today = Date()
        let dateFormatter = DateFormatter()
        // Using ':m' below will do more than just drop that digit.  It does some odd rounding and it will display the last minute digit if there is 0 like 05.  That's why we have to drop the last digit using string formatting below
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let todaysDateExcludingLastMinuteDigit = removeLastMinutesDigitFromDate(date: dateFormatter.string(from: today))

        let destinationUrl = snowDepthCSVLocationUrl.appendingPathComponent(todaysDateExcludingLastMinuteDigit)
        return destinationUrl
    }

    static func didDownloadFileRecentlyTo(destinationUrl: URL) -> Bool {
        let destinationPath = destinationUrl.path
        return FileManager().fileExists(atPath: destinationPath)
    }

    static func removePreviousDownloadedSnowDepthFiles() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let snowDepthCSVLocationUrl = documentsUrl.appendingPathComponent("snowDepthCSVs")

        do {
            try FileManager().removeItem(at: snowDepthCSVLocationUrl)
        } catch {
            print(error)
        }

        do {
            try FileManager().createDirectory(at: snowDepthCSVLocationUrl, withIntermediateDirectories: true)
        } catch {
            print(error)
        }
    }

    static func removeLastMinutesDigitFromDate(date: String) -> String {
        var dateWithoutLastMinutesDigit = date
        dateWithoutLastMinutesDigit.removeLast()
        return dateWithoutLastMinutesDigit
    }

}

// MARK: - Debugging

//     func getCSVSnowData() {
//        let url = URL(string: "https://nwac.us/data-portal/csv/mt-hood/sensortype/snow_depth/start-date/2021-01-31/end-date/2021-02-02")
//        self.dowloadPowderData(url: url!)
//        do {
//        let resource: CSV? = try CSV(name: "mt-hood-snow_depth", extension: "csv", bundle: .main, delimiter: ",", encoding: .utf8, loadColumns: true)
//            totalSnowDepth = resource?.namedColumns["\" (5800') Timberline Lodge"]
//            snowDepthDateTime = resource?.namedColumns["Date/Time (PST)"]
//        } catch let parseError as CSVParseError {
//            print("parse error: \(parseError)")
//        } catch {
//            print("file error: \(error)")
//        }
//
//    }
