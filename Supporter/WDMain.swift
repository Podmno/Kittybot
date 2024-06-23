//
//  WDMain.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/2.
//

import Cocoa
import SupporterCore

class WDMain: NSWindowController {
    
    var wndProgress: WDVideoProgress? = nil
    let wndSettings = WDSettings(windowNibName: "WDSettings")
    @IBOutlet weak var popUpFormat: NSPopUpButton!
    
    @IBOutlet weak var tfInput: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()

        
        //wndSettings.showWindow(self)
    }
    
    @IBAction func btnClickedOK(_ sender: Any) {
        wndProgress = WDVideoProgress(windowNibName: "WDVideoProgress")
        self.window?.beginSheet(wndProgress!.window!) {_ in 
            print("delete WDVideoProgress")
            self.wndProgress = nil
        }
        
        let manager = DLManager()
        var task = DLManagerTask()
        
        task.convertFormat = .useDefault
        task.url = tfInput.stringValue
        
        // Twitter Alt Process
        
        if (task.url.contains("x.com")) {
            
        }
        
        if (popUpFormat.indexOfSelectedItem == 1) {
            task.convertFormat = .mov
        }
        
        if (popUpFormat.indexOfSelectedItem == 2) {
            task.convertFormat = .mp3
        }
        
        
        manager.setupTask(task: task)
        manager.runTask()
        
    }
    
    
    
}
