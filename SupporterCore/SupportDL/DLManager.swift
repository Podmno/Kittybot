//
//  DLManager.swift
//  SupporterCore
//
//  Created by Ki MNO on 2024/4/2.
//

import Cocoa

/// Support Video Format
public enum DLFormat {
    case useDefault
    case mov
    case mp4
    case m4a
    case mp3
}

/*
    Grade0: Ignore
    Grade1: Check yt-dlp & ffmpeg toolchain
    Grade2: Video Info
    Grade3: Video Download
    Grade4: Download Finish & Convert
    Grade5: Finish
 */

// MARK: - Download Signal

public struct DLSignalDownloadProgress {
    
    /// Session ID: Task ID
    public var sessionID: Int = 0
    
    /// Current Download Grade
    public var currentGrade: Int = 0
    /// Current Download Progress. Minus number = awaiting
    public var currentPercent: Double = 0.0
    
    public var currentDownloadSpeed: String = ""
    public var currentDownloadTotalSize: String = ""
    public var currentDownloadETA: String = ""
    
    public var downloadFileName: String = ""
    
    /// Generic Log Content
    public var logContent: String = ""
    
    public init(sessionID: Int, currentGrade: Int, currentPercent: Double, currentDownloadSpeed: String, currentDownloadTotalSize: String, currentDownloadETA: String, downloadFileName: String, logContent: String) {
        self.sessionID = sessionID
        self.currentGrade = currentGrade
        self.currentPercent = currentPercent
        self.currentDownloadSpeed = currentDownloadSpeed
        self.currentDownloadTotalSize = currentDownloadTotalSize
        self.currentDownloadETA = currentDownloadETA
        self.downloadFileName = downloadFileName
        self.logContent = logContent
    }
    
    public init() {
        
    }
}

// MARK: - Download Config Struct

public struct DLManagerConfig {
    
    public var enableExternal_ytdlp = true
    public var externalPath_ytdlp = "/usr/local/bin/yt-dlp"
    
    public var internalPath_ytdlp = ""
    
    public var enableExternal_ffmpeg = true
    public var externalPath_ffmpeg = "/usr/local/bin/ffmpeg"
    
    public var internalPath_ffmpeg = ""
    
    public var configDefaultDownloadPath = NSHomeDirectory() + "/Downloads"
    
    public init(enableExternal_ytdlp: Bool = true, externalPath_ytdlp: String = "/usr/local/bin/yt-dlp", enableExternal_ffmpeg: Bool = true, externalPath_ffmpeg: String = "/usr/local/bin/ffmpeg", configDefaultDownloadPath: String = NSHomeDirectory() + "/Downloads") {
        self.enableExternal_ytdlp = enableExternal_ytdlp
        self.externalPath_ytdlp = externalPath_ytdlp
        self.enableExternal_ffmpeg = enableExternal_ffmpeg
        self.externalPath_ffmpeg = externalPath_ffmpeg
        self.configDefaultDownloadPath = configDefaultDownloadPath
    }
    
    public init() {
        
    }
    
}

// MARK: - Download Task Struct

public struct DLManagerTask {
    
    public var sessionID: Int = Int.random(in: 1...900000)
    
    public var url: String = ""
    public var convertFormat: DLFormat = .useDefault
    
    public var savePath: String = NSHomeDirectory() + "/Downloads"
    
    public var specXAddressReplaceToTwitter = true
    
    public init() {
        
    }
    
    public init(sessionID: Int, url: String, convertFormat: DLFormat, savePath: String) {
        self.sessionID = sessionID
        self.url = url
        self.convertFormat = convertFormat
        self.savePath = savePath
        
        
    }
}



// MARK: - Download Manager

public class DLManager: NSObject {

    public var downloadTask: DLManagerTask? = nil
    public var downloadConfig: DLManagerConfig = DLManagerConfig()
    
    public func setupTask(task: DLManagerTask) {
        self.downloadTask = task
        
        if (task.specXAddressReplaceToTwitter) {
            self.downloadTask?.url = replace(validateStr: task.url, regularExpress: "x.com", contentStr: "twitter.com")
            print("SPECIAL > specXAddressReplaceToTwitter: \(String(describing: self.downloadTask?.url))")
        }
    }
    
    public func runTask() {
        if downloadTask == nil {
            print("Mgr > Task nil.")
            return
        }
        print("runTask > \(downloadTask!)")
        downloadWithoutConvertFinishFlag = 0
        let task = Process()

        task.launchPath = "/bin/sh"
       
        var launchCommand = ""
        launchCommand.append("/usr/local/bin/yt-dlp ")
        launchCommand.append("'\(downloadTask!.url)'")
        launchCommand.append(" -P ")
        launchCommand.append(downloadTask!.savePath)
        
        if (downloadTask!.convertFormat == .mov) {
            launchCommand.append(" --recode-video mov")
        }
        if (downloadTask!.convertFormat == .mp3) {
            launchCommand.append(" --recode-video mp3")
        }
        if (downloadTask!.convertFormat == .mp4) {
            launchCommand.append(" --recode-video mp4")
        }
        if (downloadTask!.convertFormat == .m4a) {
            launchCommand.append(" --recode-video m4a")
        }

        launchCommand.append(" --ffmpeg-location '/usr/local/bin/ffmpeg'")
        print("yt-dlp command: \(launchCommand)")
        task.arguments = ["-c" , launchCommand]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading

        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                // Update your view with the new text here
                if line.isEmpty {
                    return
                }
                self.logParser(line)
                
            } else {
                print("Error decoding data: \(pipe.availableData)")
                self.logParser(String(data: pipe.availableData, encoding: .utf8) ?? "")
            }
        }
        /*
        let pipe_Error = Pipe()
        task.standardError = pipe_Error
        let outHandle_Error = pipe.fileHandleForReading
        
        outHandle_Error.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: .utf8) {
                // TODO: Error Message
                if line.isEmpty {
                    return
                }
                self.logParser(line)
                self.sendSignalError(line)
            } else {
                print("Error decoding data: \(pipe.availableData)")
                self.logParser(String(data: pipe.availableData, encoding: .utf8) ?? "")
            }
        }
        */
            
        task.launch()
    }
    
    
    var downloadWithoutConvertFinishFlag = 0
    func logParser(_ log_line: String) {
        
        sendSignalMainLog(log_line)
        
        if (log_line.contains("[download]")) {
            
            if (downloadTask == nil) {
                return
            }
            sendSignal(DLManager.signalDownloadStart)
            
            var download_signal = DLSignalDownloadProgress()
            download_signal.sessionID = downloadTask!.sessionID
            download_signal.logContent = log_line
            if (log_line.contains("ETA")) {
                download_signal.currentGrade = 3
                
                // Downloading Percent
                download_signal.currentPercent = parseDownloadPercent(log_line)
                // Total Size
                download_signal.currentDownloadTotalSize = parseDownloadSize(log_line)
                // Speed
                download_signal.currentDownloadSpeed = parseDownloadSpeed(log_line)
                // ETA
                download_signal.currentDownloadETA = parseDownloadETA(log_line)
                sendSignalDownloadProgress(download_signal)
                
                // SP: Download without convert: 100% appear twice
                if (log_line.contains("100.0%") && downloadTask?.convertFormat == .useDefault) {
                    downloadWithoutConvertFinishFlag = 1
                }
                
                if (downloadWithoutConvertFinishFlag == 1 && downloadTask?.convertFormat == .useDefault) {
                    // Finish Download
                    download_signal.currentGrade = 4
                    download_signal.currentPercent = 100
                    download_signal.currentDownloadTotalSize = parseDownloadFinishSize(log_line)
                    download_signal.currentDownloadETA = parseDownloadFinishTime(log_line)
                    download_signal.currentDownloadSpeed = parseDownloadFinishSpeed(log_line)
                    sendSignalDownloadProgress(download_signal)
                    
                    if (downloadTask!.convertFormat == .useDefault) {
                        sendSignal(DLManager.signalDownloadFinish)
                    }
                }
            } else {
                // Download Finished
                if (log_line.contains("Deleting original file")) {
                    download_signal.currentGrade = 4
                    download_signal.currentPercent = 100
                    download_signal.currentDownloadTotalSize = parseDownloadFinishSize(log_line)
                    download_signal.currentDownloadETA = parseDownloadFinishTime(log_line)
                    download_signal.currentDownloadSpeed = parseDownloadFinishSpeed(log_line)
                    sendSignalDownloadProgress(download_signal)
                    
                    if (downloadTask!.convertFormat == .useDefault) {
                        sendSignal(DLManager.signalDownloadFinish)
                    }
                    
                }
            }
        }
        
        if (log_line.contains("[VideoConvertor]")) {
            sendSignal(DLManager.signalVideoConvertStart)
            flagVideoConvertNow = true
        }
        
        if (log_line.contains("Deleting original file")) {
            sendSignal(DLManager.signalDownloadFinish)
        }
        
        if (log_line.contains("has already been downloaded")) {
            sendSignal(DLManager.signalDownloadAlready)
            sendSignal(DLManager.signalDownloadFinish)
        }
        
        if (log_line.contains("ERROR")) {
            sendSignalError(log_line)
        }
    }
    
    var flagVideoConvertNow = false
    
    // - MARK: - Signal Send
    
    public static let signalDownloadStart = "KittybotDownloadStart"
    public static let signalVideoConvertStart = "KittybotVideoConvertStart"
    public static let signalDownloadFinish = "KittybotDownloadFinish"
    public static let signalDownloadAlready = "KittybotAlreadyDownload"
    public static let signalDownloadProgress = "KittybotDownloadProgress"
    public static let signalDownloadLog = "KittybotDownloadLog"
    public static let signalDownloadError = "KittybotDownloadError"
    
    func sendSignalDownloadProgress(_ signal: DLSignalDownloadProgress) {
        print("Signal > KittybotDownloadProgress - Download Progress : \(signal)")
        NotificationCenter.default.post(name: NSNotification.Name(DLManager.signalDownloadProgress), object: signal)
    }
    
    func sendSignal(_ signalName: String) {
        if (downloadTask == nil) {
            print("Task nil. Failed to send signal.")
        }
        print("Signal > \(signalName)")
        NotificationCenter.default.post(name: NSNotification.Name(signalName), object: downloadTask!.sessionID)
    }
    
    func sendSignalMainLog(_ logLine: String) {
        print("Signal > KittybotDownloadLog - logLine: \(logLine)")
        NotificationCenter.default.post(name: NSNotification.Name(DLManager.signalDownloadLog), object: logLine)
    }
    
    func sendSignalError(_ logLine: String) {
        print("Signal > KittybotDownloadError - logLine: \(logLine)")
        NotificationCenter.default.post(name: NSNotification.Name(DLManager.signalDownloadError), object: logLine)
    }
    
    
    // - MARK: - Regex Parser
    
    func parseFileName(_ log_line: String) -> String {
        if (downloadTask == nil) {
            return ""
        }
        if (log_line.contains("Destination:")) {
            let path_data = downloadTask!.savePath
            
            if (log_line.contains(path_data)) {
                let data_file_str = regulayExpression(regularExpress: "\(path_data)/(.*)*", validateString: log_line)
                print(data_file_str)
                if (data_file_str.isEmpty) { return "" }
                let video_file_name = replace(validateStr: data_file_str[0], regularExpress: "\(path_data)/", contentStr: "")
                print("Video File Name: \(video_file_name)")
                return video_file_name
            }
            
            return ""
        } else {
            return ""
        }
    }
    
    func parseDownloadHelper(_ log_line: String) -> String {
        let dl_helper_str = regulayExpression(regularExpress: "\\[.*\\]", validateString: log_line)
        if (dl_helper_str.isEmpty) { return "" }
        let dl_helper_str1 = replace(validateStr: dl_helper_str[0], regularExpress: "\\[", contentStr: "")
        let helper = replace(validateStr: dl_helper_str1, regularExpress: "\\]", contentStr: "")
        print("P * helper: \(helper)")
        return helper
    }
    
    func parseDownloadPercent(_ log_line: String) -> Double {
        let dl_percent_total = regulayExpression(regularExpress: "(-?\\d+)(\\.\\d+)?% of", validateString: log_line)
        if (dl_percent_total.isEmpty) { return -1 }
        let dl_percent = replace(validateStr: dl_percent_total[0], regularExpress: "\\% of", contentStr: "")
        print("P * Percent: \(dl_percent)")
        return Double(dl_percent) ?? -1
    }
    
    func parseDownloadSize(_ log_line: String) -> String {
        let dl_total_size = regulayExpression(regularExpress: "of(.*?)at", validateString: log_line)
        if (dl_total_size.isEmpty) { return "" }
        let dl_total_size_str_1 = replace(validateStr: dl_total_size[0], regularExpress: "of[\\s]*", contentStr: "")
        let dl_total_size_str_result = replace(validateStr: dl_total_size_str_1, regularExpress: "[\\s]*at", contentStr: "")
        print("P * Full file size: \(dl_total_size_str_result)")
        return dl_total_size_str_result
    }
    
    func parseDownloadSpeed(_ log_line: String) -> String {
        let dl_speed = regulayExpression(regularExpress: "at[\\s]*(.*?)[\\s]*ETA", validateString: log_line)
        if (dl_speed.isEmpty) { return "" }
        let dl_speed_str_1 = replace(validateStr: dl_speed[0], regularExpress: "at[\\s]*", contentStr: "")
        let dl_speed_result = replace(validateStr: dl_speed_str_1, regularExpress: "[\\s]*ETA", contentStr: "")
        print("P * DL Speed: \(dl_speed_result)")
        return dl_speed_result
    }
    
    func parseDownloadETA(_ log_line: String) -> String {
        let dl_eta = regulayExpression(regularExpress: "ETA[\\s]*(.*)*", validateString: log_line)
        if (dl_eta.isEmpty) { return "" }
        let dl_eta_result = replace(validateStr: dl_eta[0], regularExpress: "ETA[\\s]*", contentStr: "")
        print("P * DL ETA: \(dl_eta_result)")
        return dl_eta_result
    }
    
    func parseDownloadFinishSize(_ log_line: String) -> String {
        let dl_total_size = regulayExpression(regularExpress: "of(.*?)in", validateString: log_line)
        if (dl_total_size.isEmpty) { return "" }
        let dl_total_size_str_1 = replace(validateStr: dl_total_size[0], regularExpress: "of[\\s]*", contentStr: "")
        let dl_total_size_str_result = replace(validateStr: dl_total_size_str_1, regularExpress: "[\\s]*in", contentStr: "")
        print("P * DL Finish Full file size: \(dl_total_size_str_result)")
        return dl_total_size_str_result
    }
    
    func parseDownloadFinishTime(_ log_line: String) -> String {
        let dl_speed = regulayExpression(regularExpress: "in[\\s]*(.*?)[\\s]*at", validateString: log_line)
        if (dl_speed.isEmpty) { return "" }
        let dl_speed_str_1 = replace(validateStr: dl_speed[0], regularExpress: "in[\\s]*", contentStr: "")
        let dl_speed_result = replace(validateStr: dl_speed_str_1, regularExpress: "[\\s]*at", contentStr: "")
        print("P * DL Finish Total Time: \(dl_speed_result)")
        return dl_speed_result
    }
    
    func parseDownloadFinishSpeed(_ log_line: String) -> String {
        let dl_eta = regulayExpression(regularExpress: "at[\\s]*(.*)*", validateString: log_line)
        if (dl_eta.isEmpty) { return "" }
        let dl_eta_result = replace(validateStr: dl_eta[0], regularExpress: "at[\\s]*", contentStr: "")
        print("P * DL Finish Total Speed: \(dl_eta_result)")
        return dl_eta_result
    }
    
    
    func regulayExpression(regularExpress: String, validateString: String) -> [String] {
       do {
           let regex = try NSRegularExpression.init(pattern: regularExpress, options: [])
           let matches = regex.matches(in: validateString, options: [], range: NSRange(location: 0, length: validateString.count))
           var res: [String] = []
           for item in matches {
               let str = (validateString as NSString).substring(with: item.range)
               res.append(str)
           }
           return res
       } catch {
           return []
       }
   }
    
   func replace(validateStr: String, regularExpress: String, contentStr: String) -> String {
       do {
           let regrex = try NSRegularExpression.init(pattern: regularExpress, options: [])
           let modified = regrex.stringByReplacingMatches(in: validateStr, options: [], range: NSRange(location: 0, length: validateStr.count), withTemplate: contentStr)
           return modified
       } catch {
           return validateStr
       }
   }
}
