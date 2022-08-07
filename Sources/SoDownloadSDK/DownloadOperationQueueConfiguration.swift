//
//  DownloadOperationQueueConfiguration.swift
//
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation


public struct DownloadOperationQueueConfiguration {
    
    public let queue: OperationQueue
    
    public let downloadsDirectoryName: String
    
    public init(mode: Mode, queue: OperationQueue = OperationQueue(), downloadsDirectoryName: String = "SoDownloadSDK.Downloads.Configuration") {
        self.mode = mode
        self.queue = queue
        self.downloadsDirectoryName = downloadsDirectoryName
    }
    
    
    public enum Mode {
        case oneByOne
        case concurrentWith(limit: Int)
    }
    
    public let mode: Mode

    public static var `default`: DownloadOperationQueueConfiguration {
        return DownloadOperationQueueConfiguration(mode: .concurrentWith(limit: 25))
    }
    
    
    internal func queueWithLimit() -> DownloadOperationQueue {
        switch mode {
        case .oneByOne:
            return DownloadOperationQueue(limit: 1)
        case .concurrentWith(let limit):
            return DownloadOperationQueue(limit: limit)
        }
    }
}
