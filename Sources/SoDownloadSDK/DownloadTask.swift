//
//  DownloadTask.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public class DownloadTask: Equatable {
    internal let object: DownloadObject
    internal weak var fileManager: DownloadFileManagerProtocol!
    internal var terminated: (() -> Void)?
    internal let task: URLSessionDownloadTask
    
    private(set) var completed = false
    
    internal init(object: DownloadObject, fileManager: DownloadFileManagerProtocol, session: URLSession) throws {
        self.object = object
        self.fileManager = fileManager
    
        guard let downloadUrl = object.url else {
            throw DownloadError.noURL
        }
        
        let task = session.downloadTask(with: downloadUrl)
        task.taskDescription = object.taskDescription
        self.task = task
    }
    
    internal func cancel() {
        task.cancel()
        terminated?()
    }
    
    internal func resume() {
        task.resume()
    }
    
    internal func move(from source: URL) throws -> URL {
        let destination = try path(forObject: object)
        try fileManager.move(from: source, to: destination)
        completed = true
        return destination
    }
    
    fileprivate func path(forObject object: DownloadObject) throws -> URL {
       return try fileManager.createUrl(for: object.name)
    }
    
    public static func == (lhs: DownloadTask, rhs: DownloadTask) -> Bool {
        return lhs.object == rhs.object
            && lhs.task == rhs.task
    }
}
