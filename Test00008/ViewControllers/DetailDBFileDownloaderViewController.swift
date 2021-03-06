//
//  DetailDBFileDownloaderViewController.swift
//  Test00008
//
//  Created by Stephan Korner on 09.02.18.
//  Copyright © 2018 Ideen Kaffee Korner. All rights reserved.
//

import Foundation
import UIKit

class DetailDBFileDownloaderViewController: UIViewController {
    
    @IBOutlet weak var titleLabelOutlet: UILabel!
    var titleLabelString: String?
    var fileURL: String?
    var downloadPath: String?
    
    @IBOutlet weak var downloadButton: UIButton!
    var downloadButtonTitleString: String?
    @IBOutlet weak var pauseButton: UIButton!
    var pauseButtonTitleString: String?
    @IBOutlet weak var cancelButton: UIButton!
    var cancelButtoTitleString: String?
    
    @IBOutlet weak var progressBarOutlet: UIProgressView!
    @IBOutlet weak var lblDetails: UILabel!
    
    var FileIndex: Int?
    
    let sessionIdentifer: String = "com.myId.BackgroundSession"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var completion = appDelegate.backgroundSessionCompletionHandler
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // create a running background-download Session
        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        MZDownloadManager.shared.activate(session: sessionIdentifer, completion: completion)
        
        MZDownloadManager.shared.downloadDelegate = self
        
        print("found tasks = \(MZDownloadManager.shared.downloadingArray.count)")
        var highestIdenty = 0
        var foundOne: Bool = false
        for downy in MZDownloadManager.shared.downloadingArray { // for all tasks..
            if downy.fileURL == self.fileURL { // the ones relevant...
                if (downy.task?.taskIdentifier)! > highestIdenty {
                    highestIdenty = (downy.task?.taskIdentifier)!
                    foundOne = true
                }
            }
        }
        if foundOne { // delete all relevant ones except one with highest taskID
            var i = 0
            let tempy = MZDownloadManager.shared.downloadingArray
            for bony in tempy {
                if bony.fileURL == self.fileURL {
                    if (bony.task?.taskIdentifier)! < highestIdenty {
                        MZDownloadManager.shared.cancelTaskAtIndex(i)
                    }
                    i = i - 1
                }
                i = i + 1
            }
            print("highest ID = \(highestIdenty)")
        } else { // if no relevant arround at all, then add one
            MZDownloadManager.shared.addDownloadTask(self.titleLabelString!, fileURL: self.fileURL!, destinationPath: self.downloadPath!)
        }
        // now we are supposed to have at least one relevant one !
        for rowny in MZDownloadManager.shared.downloadingArray {
            if rowny.fileURL == self.fileURL {
                
                let status = rowny.status
                self.showAppropriateStatus(status)
            }
        }
        
        DispatchQueue.main.async {
            self.progressBarOutlet.transform =
                self.progressBarOutlet.transform.scaledBy(x: 1, y: 3)
            self.titleLabelOutlet.text = self.titleLabelString
           self.downloadButton.setTitle(self.downloadButtonTitleString, for: .normal)
            self.pauseButton.setTitle(self.pauseButtonTitleString, for: .normal)
            self.cancelButton.setTitle(self.cancelButtoTitleString, for: .normal)
        }
    }
    
    func refreshProcess(downloadModel: MZDownloadModel) {
        
        self.progressBarOutlet?.progress = downloadModel.progress
        
        var remainingTime: String = ""
        if downloadModel.progress == 1.0 {
            remainingTime = "Please wait..."
        } else if let _ = downloadModel.remainingTime {
            if (downloadModel.remainingTime?.hours)! > 0 {
                remainingTime = "\(downloadModel.remainingTime!.hours) Hours "
            }
            if (downloadModel.remainingTime?.minutes)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) Min "
            }
            if (downloadModel.remainingTime?.seconds)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.seconds) sec"
            }
        } else {
            remainingTime = "Calculating..."
        }
        
        var fileSize = "Getting information..."
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        var speed = "Calculating..."
        if let _ = downloadModel.speed?.speed {
            speed = String(format: "%.2f %@/sec", (downloadModel.speed?.speed)!, (downloadModel.speed?.unit)!)
        }
        
        var downloadedFileSize = "Calculating..."
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.2f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        let detailLabelText = NSMutableString()
        detailLabelText.appendFormat("File Size: \(fileSize)\nDownloaded: \(downloadedFileSize) (%.2f%%)\nSpeed: \(speed)\nTime Left: \(remainingTime)\nStatus: \(downloadModel.status)" as NSString, downloadModel.progress * 100.0)
        self.lblDetails?.text = detailLabelText as String
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func resetProgressBar() {
        DispatchQueue.main.async {
            self.progressBarOutlet.progress = 0
        }
    }
    
    func showAppropriateStatus(_ requestStatus: String) {
        
        if requestStatus == TaskStatus.downloading.description() {
            self.showDuringDownloadSetting(paused: false)
        } else if requestStatus == TaskStatus.failed.description() {
            // TODO: eventually check also if download failed in the meantime and act accordingly
            self.showBeforeDownloadSetting()
        } else if requestStatus == TaskStatus.paused.description() {
            self.showDuringDownloadSetting(paused: true)
        }
    }
    
    @IBAction func startDownloadButtonPressed(_ sender: Any) {
        if MZDownloadManager.shared.downloadingArray.count == 0 {
            MZDownloadManager.shared.addDownloadTask(self.titleLabelString!, fileURL: self.fileURL!, destinationPath: self.downloadPath!)
        }
        MZDownloadManager.shared.resumeDownloadTaskAtIndex(self.FileIndex!)
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        
        if self.pauseButton.titleLabel?.text == "Pause" {
            MZDownloadManager.shared.pauseDownloadTaskAtIndex(self.FileIndex!)
        } else if self.pauseButton.titleLabel?.text == "Resume" {
            MZDownloadManager.shared.resumeDownloadTaskAtIndex(self.FileIndex!)
        }
    }
    
    @IBAction func cancelButtonPresed(_ sender: Any) {
        MZDownloadManager.shared.cancelTaskAtIndex(self.FileIndex!)
    }
    
    func retryAction() {
        MZDownloadManager.shared.retryDownloadTaskAtIndex(self.FileIndex!)
    }
}

extension DetailDBFileDownloaderViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        self.showDuringDownloadSetting(paused: false)
        self.refreshProcess(downloadModel: downloadModel)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        self.showDuringDownloadSetting(paused: true)
        self.refreshProcess(downloadModel: downloadModels[self.FileIndex!])
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        // self.showDuringDownloadSetting(paused: false)
        self.refreshProcess(downloadModel: downloadModel)
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        self.showDuringDownloadSetting(paused: true)
        self.refreshProcess(downloadModel: downloadModel)
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        self.showDuringDownloadSetting(paused: false)
        self.refreshProcess(downloadModel: downloadModel)
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        self.showBeforeDownloadSetting()
        self.refreshProcess(downloadModel: downloadModel)
        // self.resetProgressBar()
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        self.showInstalledSetting()
        self.refreshProcess(downloadModel: downloadModel)
        
        // TODO: File-writng
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        
        // TODO: If File-download failes, there needs to be an alert or sign of some sort
        debugPrint("Error while downloading file: \(downloadModel.fileName)  Error: \(error)")
    }
    
    // Oppotunity to handle destination does not exists error
    // This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        let myDownloadPath = MZUtility.baseFilePath + "/Default folder"
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        let path =  myDownloadPath + "/" + (fileName as String)
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
    
    func showBeforeDownloadSetting() {
        DispatchQueue.main.async {
            self.downloadButton.setTitle("Download", for: .normal)
            self.downloadButton.isEnabled = true
            self.downloadButton.isHidden = false
            self.cancelButton.isHidden = true
            self.pauseButton.isHidden = true
            self.lblDetails.isHidden = true
            self.progressBarOutlet.isHidden = true
        }
    }
    
    func showDuringDownloadSetting(paused: Bool) {
        DispatchQueue.main.async {
            self.downloadButton.isEnabled = false
            self.downloadButton.isHidden = true
            self.pauseButton.isHidden = false
            if paused {
                self.pauseButton.setTitle("Resume", for: .normal)
            } else {
                self.pauseButton.setTitle("Pause", for: .normal)
            }
            self.cancelButton.isHidden = false
            self.lblDetails.isHidden = false
            self.progressBarOutlet.isHidden = false
        }
    }
    
    func showInstalledSetting() {
        DispatchQueue.main.async {
            self.downloadButton.isEnabled = false
            self.downloadButton.isHidden = false
            self.downloadButton.setTitle("Installed", for: .normal)
            self.pauseButton.isHidden = true
            self.cancelButton.isHidden = true
            self.lblDetails.isHidden = true
            self.progressBarOutlet.isHidden = true
        }
    }
}

