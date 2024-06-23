//
//  AppDelegate.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/1.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let wndMain = WDMain(windowNibName: "WDMain")

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        wndMain.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    let wndSettings = WDSettings(windowNibName: "WDSettings")
    @IBAction func clickedPerferences(_ sender: Any) {
        wndSettings.showWindow(self)
    }
    
}

