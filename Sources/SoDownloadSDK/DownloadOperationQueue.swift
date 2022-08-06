//
//  DownloadOperationQueue.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

internal class DownloadOperationQueue {
    
    let queue: OperationQueue
    let limit: Int
    
    internal init(limit: Int = 1) {
        self.queue = OperationQueue()
        queue.maxConcurrentOperationCount = limit
        self.limit = limit
    }
    
    internal func addOperation(operation: Operation) {
        queue.addOperation(operation)
    }
}
