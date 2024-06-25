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
    
    
    var bundled_ytdlpPath = ""
    var bundled_ffmpegPath = ""
    
    @IBOutlet weak var tfInput: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()

        bundled_ytdlpPath = Bundle.main.bundlePath + "/Contents/MacOS/yt-dlp_macos"
        bundled_ffmpegPath = Bundle.main.bundlePath + "/Contents/MacOS/ffmpeg"
        
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
        task.managerConfig.ytdlp_path = bundled_ytdlpPath
        task.managerConfig.ffmpeg_path = bundled_ffmpegPath
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
