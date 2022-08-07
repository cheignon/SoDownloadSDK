//
//  DownloadOperationQueue.swift
//
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public class DownloadOperationQueue {
    
    let queue: OperationQueue
    let limit: Int
    
    public init(limit: Int = 1) {
        self.queue = OperationQueue()
        queue.maxConcurrentOperationCount = limit
        self.limit = limit
    }
    
    internal func addOperation(operation: Operation) {
        queue.addOperation(operation)
    }
}
