//
//  WDMain.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/2.
//

import Cocoa

class WDMain: NSWindowController {
    
    let wndProgress = WDVideoProgress(windowNibName: "WDVideoProgress")
    let wndSettings = WDSettings(windowNibName: "WDSettings")
    @IBOutlet weak var popUpFormat: NSPopUpButton!
    
    @IBOutlet weak var tfInput: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.beginSheet(wndProgress.window!)
        wndSettings.showWindow(self)
    }
    
    @IBAction func btnClickedOK(_ sender: Any) {
        
        print(Bundle.main.bundlePath + "/Contents/Frameworks/yt-dlp_macos")
        
        let task = Process()

        task.launchPath = "/bin/sh"
        
        if (popUpFormat.indexOfSelectedItem == 0) {
            task.arguments = ["-c", "/usr/local/bin/yt-dlp '\(tfInput.stringValue)' -P ~/Downloads"]
        }
        
        if (popUpFormat.indexOfSelectedItem == 1) {
            task.arguments = ["-c", "/usr/local/bin/yt-dlp '\(tfInput.stringValue)' -P ~/Downloads --recode-video mov --ffmpeg-location /usr/local/bin/ffmpeg"]
        }
        
        if (popUpFormat.indexOfSelectedItem == 2) {
            task.arguments = ["-c", "/usr/local/bin/yt-dlp '\(tfInput.stringValue)' -P ~/Downloads --recode-video mp3 --ffmpeg-location '/usr/local/bin/ffmpeg'"]
        }

        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                // Update your view with the new text here
                if line.isEmpty {
                    return
                }
                print("New ouput: \(line)")
                DispatchQueue.main.async {
                    // TODO: Signal
                }
                
            } else {
                print("Error decoding data: \(pipe.availableData)")
                DispatchQueue.main.async {
                    // TODO: Signal
                }
            }
        }
            
        task.launch()
        
    }
    
    
    
}
