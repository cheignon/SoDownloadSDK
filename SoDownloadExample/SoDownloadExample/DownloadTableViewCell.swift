//
//  DownloadTableViewCell.swift
//  SoDownloadExample
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import UIKit
import SoDownloadSDK
class DownloadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    @IBOutlet weak var taskStateLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var resource: DownloadObject!
    var reuse: ((DownloadTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        downloadProgressView.transform = transform
    }
    
    func bindWith(downloadResource resource: DownloadObject) {
        downloadProgressView.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        
        self.resource = resource
        filenameLabel.text = resource.name
        
        if let url = FileManager.createPath(forResourceWithName: resource.name) {
            guard let image = UIImage(contentsOfFile: url.path) else { return }
            fileImageView.image = image
            taskStateLabel.text = "Completed"
        }
    }
    
    func bindWith(task: URLSessionDownloadTask) {
        
        switch task.state {
        case .canceling:
            taskStateLabel.text = "Canceling"
            downloadProgressView.isHidden = true
            activityIndicator.isHidden = true
        case .suspended:
            activityIndicator.isHidden = false
            downloadProgressView.isHidden = true
            activityIndicator.startAnimating()
            taskStateLabel.text = "Waiting for download"
        case .running:
            let progress = Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
            if progress >= 0.0 && progress <= 1.0 {
                taskStateLabel.text = "Downloading"
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                downloadProgressView.isHidden = false
                downloadProgressView.progress = progress
            }
        case .completed:
            activityIndicator.isHidden = true
            downloadProgressView.isHidden = true
            activityIndicator.stopAnimating()
            
            if task.countOfBytesExpectedToReceive == task.countOfBytesReceived {
                // downloaded sucessfully
                taskStateLabel.text = "Completed"
            } else {
                // error occured
                taskStateLabel.text = task.error?.localizedDescription ?? "Some error occured"
            }
        @unknown default:
            return
        }
    }
    
    fileprivate func bindWith(downloadedFile file: DownloadedFile) {
        downloadProgressView.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        do {
            let url = try file.url()
            if let image = UIImage(contentsOfFile: url.path) {
                fileImageView.image = image
            } else {
                fileImageView .image = UIImage(named: "file")
            }
            taskStateLabel.text = "Completed"
            downloadProgressView.isHidden = true
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } catch let error {
            fileImageView.image = nil
            taskStateLabel.text = error.localizedDescription
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resource = nil
        fileImageView.image = nil
        reuse?(self)
    }
}

extension DownloadTableViewCell: SoDownloadDelegate {
    func downloader(_ downloader: SoDownloadSDK, didCompleteWithError error: Error?, withTask task: URLSessionDownloadTask, whenDownloadingObject object: DownloadObject) {
        
    }
    
    func downloader(_ downloader: SoDownloadSDK, didFinishWithMostRecentError error: Error?) {
        
    }
    
    
    func downloader(_ downloader: SoDownloadSDK, didFinishDownloadingObject resource: DownloadObject, toFile file: DownloadedFile) {
        guard resource == self.resource else { return }
        bindWith(downloadedFile: file)
    }
    
    func downloader(_ downloader: SoDownloadSDK, didStartDownloadingObject resoobjecturce: DownloadObject, withTask task: URLSessionDownloadTask) {
        guard resource == self.resource else { return }
        bindWith(task: task)
    }
    
    func downloader(_ downloader: SoDownloadSDK, didUpdateStatusOfTask task: URLSessionDownloadTask, relatedToObject object: DownloadObject) {
        guard resource == self.resource else { return }
        bindWith(task: task)
    }
    
}
