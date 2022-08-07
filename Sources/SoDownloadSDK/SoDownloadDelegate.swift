//
//  SoDownloadDelegate.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public protocol SoDownloadDelegate: AnyObject {

    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - object: object which download did start
    ///   - task: URLSessionDownloadTask for reading state and observing progress
    func downloader(_ downloader: SoDownloadSDK, didStartDownloadingObject object: DownloadObject, withTask task: URLSessionDownloadTask)
    
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - task: URLSessionDownloadTask for reading progress and state
    ///   - object: object related with download
    func downloader(_ downloader: SoDownloadSDK, didUpdateStatusOfTask task: URLSessionDownloadTask, relatedToObject object: DownloadObject)
 
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - object: object related with download
    ///   - file: Object that contains relative path to file
    func downloader(_ downloader: SoDownloadSDK, didFinishDownloadingObject object: DownloadObject, toFile file: DownloadedFile)
    
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - error: Error that occured during downloading
    ///   - task: URLSessionDownloadTask for getting status / progress
    ///   - object: Downloaded object
    func downloader(_ downloader: SoDownloadSDK, didCompleteWithError error: Error?, withTask task: URLSessionDownloadTask, whenDownloadingObject object: DownloadObject)

    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - error: Optional error that occured during download, if nil job completed sucessfuly
    func downloader(_ downloader: SoDownloadSDK, didFinishWithMostRecentError error: Error?)
    
}

public extension SoDownloadDelegate {
    // Default implementations for making methods optional
    
    func downloader(_ downloader: SoDownloadSDK, didStartDownloadingObject object: DownloadObject, withTask task: URLSessionDownloadTask) {
        
    }
    
    func downloader(_ downloader: SoDownloadSDK, didUpdateStatusOfTask task: URLSessionDownloadTask, relatedToObject object: DownloadObject) {
        
    }
    
    func downloader(_ downloader: SoDownloadSDK, didCompleteWithError error: Error?, withTask task: URLSessionDownloadTask, whenDownloadingObject object: DownloadObject) {
        
    }
    
    func downloader(_ downloader: SoDownloadSDK, didFinishWithMostRecentError error: Error?) {
        
    }
}
