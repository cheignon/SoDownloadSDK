//
//  ViewController.swift
//  SoDownloadExample
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import UIKit
import SoDownloadSDK
class ViewController: UITableViewController {

    let resources: [DownloadObject] = [
        DownloadObject(url:  "https://images.pexels.com/photos/4603873/pexels-photo-4603873.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500", priority: .none),
        DownloadObject(url:  "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_5MG.mp3", priority: .low),
        DownloadObject(url:  "https://www.orphoz.com/uploads/media/pdf-exemple.pdf", priority: .high)
        ,
        DownloadObject(url: "https://i.pinimg.com/originals/24/93/53/24935369aad7ca83e7da140fb1d6d548.jpg", priority: .none)
    ]
    
    lazy var manger: SoDownloadSDK = {
        return SoDownloadSDK.shared
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try manger.addDownload(for: resources)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadTableViewCell") as! DownloadTableViewCell
        let resource = resources[indexPath.row]
        cell.bindWith(downloadResource: resource)
        if let task = manger.downloadTask(for: resource) {
            cell.bindWith(task: task)
        }
        
        manger.addDelegate(cell)
        cell.reuse = { [weak self] cellDown in
            self?.manger.removeDelegate(cellDown)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }
}
