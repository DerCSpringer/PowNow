#  An example of the core concepts of iOS development

**Installation**
* run pod install

This app is meant to be an example of the core concepts needed to develop iOS apps.  While some patterns may not make sense in such a small application(MVVM and coordinators), they were used to demonstrate concepts that I've learned.  It is a simple two screen application.  It displays the current snow level at Timberline lodge on one screen.  The other screen displays the amount of snow accumulated or lost over 8, 12, or a 24 hour period of time.

**Although simple the app covers the following concepts of iOS development:**

* the MVVM pattern
* The Coordinator pattern
* view controllers and their lifecycle
* the view hierarchy
* xibs
* basics of Auto Layout
* outlets and the target-action pattern
* communication between view controllers and delegates
* protocols
* network calls
* correct use of background thread(for network calls) and main thread(to update ui)
* weak references to avoid strong reference cycles
* Pods

**Future improvments:**
* Choose any available NWAC weather station to display snow accumulation
