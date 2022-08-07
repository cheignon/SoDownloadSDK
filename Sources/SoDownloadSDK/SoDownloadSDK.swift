import Foundation

public class SoDownloadSDK: NSObject {
    
    public init(configuration: DownloadOperationQueueConfiguration, tasks: SafeArray<DownloadTask>, queue: DownloadOperationQueue, fileManager: DownloadFileManagerProtocol, session: URLSession? = nil, delegates: DelegateManager<SoDownloadDelegate>, lastError: Error? = nil) {
        self.configuration = configuration
        self.tasks = tasks
        self.queue = queue
        self.fileManager = fileManager
        self.session = session
        self.delegates = delegates
        self.lastError = lastError
    }
    
    
    public static var shared = SoDownloadSDK()
    
    let configuration: DownloadOperationQueueConfiguration
    var tasks: SafeArray<DownloadTask>
    let queue: DownloadOperationQueue
    let fileManager: DownloadFileManagerProtocol
    var session: URLSession!
    var delegates: DelegateManager<SoDownloadDelegate>
    
    public override init() {
        self.tasks = SafeArray<DownloadTask>()
        self.configuration = DownloadOperationQueueConfiguration.default
        self.queue = self.configuration.queueWithLimit()
        self.fileManager = DownloadsFileManager.default
        self.delegates = DelegateManager<SoDownloadDelegate>(delegateQueue: DispatchQueue.main)
        
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "SoDownloadSDK.backgroundSessionConfiguration")
        super.init()
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: configuration.queue)
    }
    
    public init(configuration: DownloadOperationQueueConfiguration = DownloadOperationQueueConfiguration.default, fileManager: DownloadFileManagerProtocol = DownloadsFileManager.default) {
        self.tasks = SafeArray<DownloadTask>()
        self.configuration = configuration
        self.queue = configuration.queueWithLimit()
        self.fileManager = fileManager
        self.delegates = DelegateManager<SoDownloadDelegate>(delegateQueue: DispatchQueue.main)
        
        let sessionConfiguration = URLSessionConfiguration.background(withIdentifier: "SoDownloadSDK.backgroundSessionConfiguration")
        super.init()
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: configuration.queue)
    }
    
    /// remove specific file on disk
    ///
    /// - Parameters:
    ///   - file: DownloadedFile object to remove
    func removeFile(file: DownloadedFile) throws {
        let url = try file.url()
        try fileManager.removeFile(withUrl: url)
    }
    
    var lastError: Error?
    
    /// remove specific task when is finished or canceled
    ///
    /// - Parameters:
    ///   - task: DownloadTask object to remove
    func removeTask(task: DownloadTask) {
        tasks.remove(where: { $0 == task })
        if tasks.isEmpty {
            delegates.call({ $0.downloader(self, didFinishWithMostRecentError: self.lastError) })
        }
    }
    
    /// add file to download  on the queue
    ///
    /// - Parameters:
    ///   - object: DownloadObject object to add
    public func addDownload(for object: DownloadObject) throws {
        cleanError()
        let task = try DownloadTask(object: object, fileManager: self.fileManager, session: self.session)
        tasks.append(task)
        executeOperation(for: task)
    }
    
    private func cleanError() {
        guard tasks.isEmpty else { return }
        lastError = nil
    }
    
    /// add list of files to download  on the queue
    ///
    /// - Parameters:
    ///   - objects:  array of DownloadObject object to add
    public func addDownload(for objects: [DownloadObject]) throws {
        try objects.forEach { try addDownload(for: $0)}
    }
    
    private func executeOperation(for task: DownloadTask) {
        let operation = BlockOperation(block: { [weak task] in
            // prevent locking queue
            guard task != nil else { return }
            let semaphore = DispatchSemaphore(value: 0)
            
            task?.terminated = { [weak semaphore] in
                semaphore?.signal()
            }
            
            task?.resume()
            semaphore.wait()
        })
        switch task.object.priority {
        case .high:
            operation.queuePriority = .veryHigh
        case .low:
            operation.queuePriority = .low
        case .none:
            operation.queuePriority = .normal
        }
        queue.addOperation(operation: operation)
        delegates.call { $0.downloader(self, didStartDownloadingObject: task.object, withTask: task.task) }
    }
    
    /// cancel task on operation group with diescritpion
    ///
    /// - Parameters:
    ///   - taskDescription: String representation of task
    public func cancel(download taskDescription: String) {
        guard let filterTask = tasks.filter({ task in
            return task.object.taskDescription == taskDescription
        }) else {
            return
        }
        filterTask.forEach { task in
            task.cancel()
            self.removeTask(task: task)
        }
    }
    
    /// cancel  list of task on operation group with diescritpion
    ///
    /// - Parameters:
    ///   - tasksDescription: array of String representation of task
    public func cancel(downloads tasksDescription: [String]) {
        tasksDescription.forEach { descritpion in
            self.cancel(download: descritpion)
        }
    }
    
    /// cancel  all of task on operation group
    public func cancelAllDownloads() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    
    /// list  of task for file to download
    /// - Returns: array of DownloadTask
    public func getDownloads() -> [DownloadTask] {
        return tasks.array
    }
    
    
    /// get URLSessionDownloadTask from DownloadObject
    /// - Parameter object: DownloadObject to convert in URLSessionDownloadTask
    /// - Returns: URLSessionDownloadTask converted
    public func downloadTask(for object: DownloadObject) -> URLSessionDownloadTask? {
        return downloadTask(forTaskDescription: object.taskDescription)
    }
    
    
    /// get URLSessionDownloadTask from taskDescription
    /// - Parameter taskDescription: descritpion of the task with DownloadTask object
    /// - Returns: URLSessionDownloadTask converted
    public func downloadTask(forTaskDescription taskDescription: String) -> URLSessionDownloadTask? {
        return tasks.first { task in
            return task.object.taskDescription == taskDescription
        }?.task
    }
    
}

extension SoDownloadSDK {
    
    /// add delegate to listen callback of URLSession
    /// - Parameter object: objecrt  wich respect SoDownloadDelegateProtocol
    public func addDelegate<T: SoDownloadDelegate>(_ object: T) {
        delegates.addDelegate(object)
    }
    /// remove delegate wich  listen callback of URLSession
    /// - Parameter object: objecrt  wich respect SoDownloadDelegateProtocol
    public func removeDelegate<T: SoDownloadDelegate>(_ object: T) {
        delegates.removeDelegate(object)
    }
}
extension SoDownloadSDK: URLSessionTaskDelegate {
    
    private func downloadTask(for task: URLSessionTask) -> DownloadTask? {
        return tasks.first(where: { $0.task.taskIdentifier == task.taskIdentifier })
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let myTask = self.downloadTask(for: task) else { return }
        let downloadTask = task as! URLSessionDownloadTask
        delegates.call{ $0.downloader(self, didCompleteWithError: error, withTask: downloadTask, whenDownloadingObject: myTask.object) }
        myTask.terminated?()
        removeTask(task: myTask)
    }
    
}

extension SoDownloadSDK: URLSessionDownloadDelegate {
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let task = self.downloadTask(for: downloadTask) else { return }
        delegates.call { $0.downloader(self, didUpdateStatusOfTask: downloadTask, relatedToObject: task.object) }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = self.downloadTask(for: downloadTask) else { return }
        do {
            let newLocation = try task.move(from: location)
            let documentsUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let relativePath = String(newLocation.path.replacingOccurrences(of: documentsUrl.path, with: "").dropFirst())
            let file = DownloadedFile(relativePath: relativePath)
            delegates.call { $0.downloader(self, didFinishDownloadingObject: task.object, toFile: file) }
        } catch let error {
            delegates.call { $0.downloader(self, didCompleteWithError: error, withTask: downloadTask, whenDownloadingObject: task.object) }
        }
        task.terminated?()
        removeTask(task: task)
    }
    
}
