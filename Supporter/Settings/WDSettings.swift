//
//  WDSettings.swift
//  Supporter
//
//  Created by Ki MNO on 2024/4/2.
//

import Cocoa

class WDSettingsController: NSObject {
    
}

class WDSettings: NSWindowController {
    
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var actionDownload: NSToolbarItem!
    @IBOutlet weak var actionConvert: NSToolbarItem!
    @IBOutlet weak var toolBar: NSToolbar!
    
    let vcSettingsVideo = VCSettingsVideo(nibName: "VCSettingsVideo", bundle: Bundle.main)
    let vcSettingsConvert = VCSettingsConvert(nibName: "VCSettingsConvert", bundle: Bundle.main)
    
    var originalVideoFrame: NSRect? = nil
    var originalConvertFrame: NSRect? = nil
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.containerView.addSubview(vcSettingsVideo.view)
        self.containerView.addSubview(vcSettingsConvert.view)
        originalVideoFrame = vcSettingsVideo.view.frame
        originalConvertFrame = vcSettingsConvert.view.frame
        
        toolBar.selectedItemIdentifier = NSToolbarItem.Identifier("Download")
        
        vcSettingsVideo.view.isHidden = false
        vcSettingsConvert.view.isHidden = true
        
        var fr = self.window?.frame
        fr?.size.height = vcSettingsVideo.view.frame.height
        fr?.size.width = vcSettingsVideo.view.frame.width
        self.window?.setFrame(fr!, display: true, animate: false)
        vcSettingsVideo.view.frame = containerView.bounds
        vcSettingsConvert.view.frame = containerView.bounds
        
    }
    
    @IBAction func actionClickedDownload(_ sender: Any) {
        
        vcSettingsVideo.view.isHidden = false
        vcSettingsConvert.view.isHidden = true
        
        var fr = self.window?.frame

        fr?.size.height = originalVideoFrame!.height
        fr?.size.width = originalVideoFrame!.width
        self.window?.setFrame(fr!, display: true, animate: true)
        
    }
    
    
    @IBAction func actionClickedConvert(_ sender: Any) {
        vcSettingsVideo.view.isHidden = true
        vcSettingsConvert.view.isHidden = false
        
        var fr = self.window?.frame

        fr?.size.height = originalConvertFrame!.height
        fr?.size.width = originalConvertFrame!.width
        self.window?.setFrame(fr!, display: true, animate: true)
        
    }
}
