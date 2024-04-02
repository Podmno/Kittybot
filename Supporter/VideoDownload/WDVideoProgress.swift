//
//  WDVideoProgress.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/1.
//

import Cocoa
import SupporterCore

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
        self.close()
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
        
        
        progressBar.startAnimation(self)
        progressBar.isIndeterminate = true
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(addLog), name: Notification.Name(DLManager.signalDownloadLog), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiSetComplete), name: Notification.Name(DLManager.signalDownloadFinish), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiAlertAlreadyComplete), name: Notification.Name(DLManager.signalDownloadAlready), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiAlertError), name: Notification.Name(DLManager.signalDownloadError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiUpdateProgress), name: Notification.Name(DLManager.signalDownloadProgress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiSetConverting), name: Notification.Name(DLManager.signalVideoConvertStart), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(uiStartDownload), name: Notification.Name(DLManager.signalDownloadStart), object: nil)
    }
    
    
    // MARK: Notification Response
    
    @objc func addLog(sender: Notification) {
        DispatchQueue.main.async {
            let data_log = sender.object as! String
            self.tableProvider.addInformation(data_log.trimmingCharacters(in: .newlines))
            self.mainTable.reloadData()
        }
        
    }
    
    var downloadStarted = false
    @objc func uiStartDownload() {
        if (downloadStarted) {
            return
        }
        DispatchQueue.main.async {
            self.lbTitle.stringValue = "Downloading..."
            self.lbMessage.stringValue = "Prepare for downloading..."
            self.progressBar.doubleValue = 0.0
            self.progressBar.isIndeterminate = false
            self.progressBar.stopAnimation(self)
            self.downloadStarted = true
        }
    }
    
    @objc func uiUpdateProgress(sender: Notification) {
        DispatchQueue.main.async {
            let data_log = sender.object as! DLSignalDownloadProgress
            
            if (data_log.currentGrade == 3) {
                self.lbTitle.stringValue = "Downloading..."
                self.lbMessage.stringValue = "Current Speed: \(data_log.currentDownloadSpeed),Estimate Time Remaining: \(data_log.currentDownloadETA)"
                self.progressBar.doubleValue = Double(data_log.currentPercent)
                print(data_log.currentPercent)
            }
            
            if (data_log.currentGrade == 4) {
                self.lbTitle.stringValue = "Downloading..."
                self.lbMessage.stringValue = "Download Finished with total time: \(data_log.currentDownloadETA), total file size: \(data_log.currentDownloadTotalSize)"
                self.progressBar.doubleValue = 99.0
            }
            
        }
    }
    
    @objc func uiSetConverting() {
        DispatchQueue.main.async {
            self.lbTitle.stringValue = "Converting File to Target Format, Please wait a while."
            self.lbMessage.stringValue = "This may take a while."
            self.progressBar.doubleValue = 99.0
            self.progressBar.isIndeterminate = true
            self.progressBar.startAnimation(self)
            self.btnOK.isEnabled = false
        }
    }
    
    @objc func uiSetComplete() {
        DispatchQueue.main.async {
            self.lbTitle.stringValue = "Download Finished."
            self.lbMessage.stringValue = "All tasks are finished."
            self.progressBar.doubleValue = 100.0
            self.progressBar.isIndeterminate = false
            self.progressBar.stopAnimation(self)
            self.btnOK.isEnabled = true
        }
    }
    
    @objc func uiAlertAlreadyComplete() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.informativeText = "It seems that the task is already completed."
            alert.messageText = " "
            alert.runModal()
        }
    }
    
    @objc func uiAlertError(sender: Notification) {
        DispatchQueue.main.async {
            self.lbTitle.stringValue = "Download Finished."
            self.lbMessage.stringValue = "Error Occoured."
            self.progressBar.doubleValue = 100.0
            self.progressBar.isIndeterminate = false
            self.progressBar.stopAnimation(self)
            self.btnOK.isEnabled = true
            
            
            let data_log = sender.object as! String
            let alert = NSAlert()
            alert.informativeText = data_log
            alert.messageText = " "
            alert.runModal()
        }
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
        tf.lineBreakMode = .byWordWrapping
        return tf
    }
    
}
