//
//  DBFilesPresenterViewController.swift
//  Test00008
//
//  Created by Stephan Korner on 13.02.18.
//  Copyright © 2018 Ideen Kaffee Korner. All rights reserved.
//

import Foundation
import UIKit

class DBFilesPresenterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let myDownloadPath = MZUtility.baseFilePath + "/My Downloads"
    
    @IBOutlet weak var tableView: UITableView!
    var availableDownloadsArray: [String]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        
        self.availableDownloadsArray.append("https://www.dropbox.com/s/yrura6qlcgcwpp4/file1.mp4?dl=1")
        self.availableDownloadsArray.append("https://www.dropbox.com/s/y9kgs6caztxxjdh/AlecrimCoreData-master.zip?dl=1")
        self.availableDownloadsArray.append("https://www.dropbox.com/s/73ymbx6icoiqus9/file2.mp4?dl=1")
        self.availableDownloadsArray.append("https://www.dropbox.com/s/4pw4jwiju0eon6r/file3.mp4?dl=1")
        self.availableDownloadsArray.append("https://www.dropbox.com/s/2bmbk8id7nseirq/file4.mp4?dl=1")
        self.availableDownloadsArray.append("https://www.dropbox.com/s/cw7wfyaic9rtzwd/GCDExample-master.zip?dl=1")
        
        self.tableView.reloadData()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "goToDetailDBFiles":
            
            let destination = segue.destination as? DetailDBFileDownloaderViewController
            let idx = self.tableView.indexPathForSelectedRow?.row
            
            // fix for now...
            destination?.FileIndex = 0
            
            // add the file to the downloadManager-TaskArray (at according index
            let fileURL  : NSString = availableDownloadsArray[idx!] as NSString
            var fileName : NSString = fileURL.lastPathComponent as NSString
            fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
            
            // initialize labels
            destination?.titleLabelString = fileName as String
            destination?.downloadPath = myDownloadPath
            destination?.fileURL = fileURL as String
            
            if (self.availableDownloadsArray.count != 0) {
                destination?.downloadButtonTitleString = "Install"
            }
            
            destination?.pauseButtonTitleString = "Pause"
            destination?.cancelButtoTitleString = "Cancel"
        default:
            break
        }
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableDownloadsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)

        cell.selectionStyle = .none
        
        let fileURL  : NSString = availableDownloadsArray[indexPath.row] as NSString
        var fileName : NSString = fileURL.lastPathComponent as NSString
        fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        
        cell.textLabel?.text = fileName as String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
