//
//  WDVideoProgress.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/1.
//

import Cocoa

class WDVideoProgress: NSWindowController {
    
    // MARK:  - Interface Builder

    @IBOutlet weak var imageMain: NSImageView!
    @IBOutlet weak var lbTitle: NSTextField!
    @IBOutlet weak var lbMessage: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var mainTable: NSTableView!
    @IBOutlet weak var btnCancel: NSButton!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var btnShowInfo: NSButton!
    @IBOutlet weak var mainTableContainer: NSScrollView!
    
    @IBAction func btnClickedCancel(_ sender: Any) {
        self.close()
    }
    
    
    @IBAction func btnClickedOK(_ sender: Any) {
        
        
    }
    
    // Window Resize (Show / Hide Info)
    
    var currentStatusWindowExpended = false
    @IBAction func btnClickedShowInfo(_ sender: Any) {
        if currentStatusWindowExpended {
            mainTableContainer.isHidden = true
            var fr = self.window?.frame
            fr!.size.height = fr!.size.height - 155
            self.window?.setFrame(fr!, display: true, animate: true)
            btnShowInfo.title = "Show Info"
            currentStatusWindowExpended = false
        } else {
            mainTableContainer.isHidden = false
            var fr = self.window?.frame
            fr!.size.height = fr!.size.height + 155
            self.window?.setFrame(fr!, display: true, animate: true)
            btnShowInfo.title = "Hide Info"
            currentStatusWindowExpended = true
        }
    }
    
    // MARK: Overrides
    
    let tableProvider = WDVideoProgressMainTableProvider()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.mainTable.delegate = tableProvider
        self.mainTable.dataSource = tableProvider
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        self.tableProvider.addInformation("yt-dlp Connection Mode: External.")
        self.tableProvider.addInformation("ffmpeg status: Unavaliable.")

        self.mainTable.reloadData()
        
        
        var fr = self.window?.frame
        fr!.size.height = fr!.size.height - 155
        self.window?.setFrame(fr!, display: true, animate: false)
        
        mainTableContainer.isHidden = true
    }
    
    // MARK: Function
    

    
}

// - MARK: Window TableView

class WDVideoProgressMainTableProvider: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    private var infoList: [String] = []
    
    public func addInformation(_ information: String) {
        infoList.append(information)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return infoList.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let tf = NSTextField(labelWithString: infoList[row])
        tf.font = NSFont.systemFont(ofSize: 11.0)
        return tf
    }
    
}
