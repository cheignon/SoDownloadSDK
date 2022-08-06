//
//  SoDownloadDelegate.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public protocol SoDownloadDelegate: AnyObject {
    /// Invoked when download did start for paricular resource (download task is added to the queue)
    ///
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - resource: Resource which download did start
    ///   - task: URLSessionDownloadTask for reading state and observing progress
    func downloader(_ downloader: SoDownloadSDK, didStartDownloadingResource resource: DownloadObject, withTask task: URLSessionDownloadTask)
    
    /// Invoked when next chunk of data is downloaded of particular item
    ///
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - task: URLSessionDownloadTask for reading progress and state
    ///   - resource: Resource related with download
    func downloader(_ downloader: SoDownloadSDK, didUpdateStatusOfTask task: URLSessionDownloadTask, relatedToResource resource: DownloadObject)
    
    /// Invoked when particular resource downloading is finished
    ///
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - resource: Resource related with download
    ///   - file: Object that contains relative path to file
    func downloader(_ downloader: SoDownloadSDK, didFinishDownloadingResource resource: DownloadObject, toFile file: DownloadedFile)
    
    /// Invoked when finished and maybe error occured during downloading particular resource
    ///
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - error: Error that occured during downloading
    ///   - task: URLSessionDownloadTask for getting status / progress
    ///   - resource: Downloaded resource
    func downloader(_ downloader: SoDownloadSDK, didCompleteWithError error: Error?, withTask task: URLSessionDownloadTask, whenDownloadingResource resource: DownloadObject)
    
    /// Invoked when queue finished since was empty
    ///
    /// - Parameters:
    ///   - downloader: SoDownloadSDK object
    ///   - error: Optional error that occured during download, if nil job completed sucessfuly
    func downloader(_ downloader: SoDownloadSDK, didFinishWithMostRecentError error: Error?)
    
}
