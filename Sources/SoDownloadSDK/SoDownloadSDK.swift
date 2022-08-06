import Foundation

public class SoDownloadSDK: NSObject {
    
    public static var shared = SoDownloadSDK()
    
    let configuration: DownloadOperationQueueConfiguration
    var tasks: SafeArray<DownloadTask>
    let queue: DownloadOperationQueue
    let fileManager: DownloadFileManagerProtocol
    var session: URLSession!
    var delegates: DelegateManager<SoDownloadDelegate>
    
    init(configuration: DownloadOperationQueueConfiguration = DownloadOperationQueueConfiguration.default, fileManager: DownloadFileManagerProtocol = DownloadsFileManager.default) {
        self.tasks = SafeArray<DownloadTask>()
        self.configuration = configuration
        self.queue = configuration.queueWithLimit()
        self.fileManager = fileManager
        self.delegates = DelegateManager<SoDownloadDelegate>(delegateQueue: DispatchQueue.main)
        
        let sessionConfiguration = URLSessionConfiguration.default
        super.init()
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: configuration.queue)
    }
    
    func removeFile(file: DownloadedFile) throws {
        let url = try file.url()
        try fileManager.removeFile(withUrl: url)
    }
    
    var lastError: Error?
    
    func removeTask(task: DownloadTask) {
        tasks.remove(where: { $0 == task })
        if tasks.isEmpty {
            delegates.call({ $0.downloader(self, didFinishWithMostRecentError: self.lastError) })
        }
    }
    
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
    
    public func addDownload(for objects: [DownloadObject]) throws {
        try objects.forEach { try addDownload(for: $0)}
    }
    
    func executeOperation(for task: DownloadTask) {
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
        
        queue.addOperation(operation: operation)
        delegates.call { $0.downloader(self, didStartDownloadingResource: task.object, withTask: task.task) }
    }
    
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
    
    public func cancel(downloads tasksDescription: [String]) {
        tasksDescription.forEach { descritpion in
            self.cancel(download: descritpion)
        }
    }
    
    public func cancelAllDownloads() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
    
    public func getDownloads() -> [DownloadTask] {
        return tasks.array
    }
    
    public func downloadTask(for object: DownloadObject) -> URLSessionDownloadTask? {
        return downloadTask(forTaskDescription: object.taskDescription)
    }
    public func downloadTask(forTaskDescription taskDescription: String) -> URLSessionDownloadTask? {
        return tasks.first { task in
            return task.object.taskDescription == taskDescription
        }?.task
    }
    
}

extension SoDownloadSDK {
    public func addDelegate<T: SoDownloadDelegate>(_ object: T) {
        delegates.addDelegate(object)
    }
    public func removeDelegate<T: SoDownloadDelegate>(_ object: T) {
        delegates.removeDelegate(object)
    }
}
extension SoDownloadSDK: URLSessionTaskDelegate {
    
    private func object(for task: URLSessionTask) -> DownloadTask? {
        return tasks.first(where: { $0.task.taskIdentifier == task.taskIdentifier })
    }
    
}

extension SoDownloadSDK: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let task = self.object(for: downloadTask) else { return }
        do {
            let newLocation = try task.move(from: location)
            let documentsUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let relativePath = String(newLocation.path.replacingOccurrences(of: documentsUrl.path, with: "").dropFirst())
            let file = DownloadedFile(relativePath: relativePath)
            delegates.call { $0.downloader(self, didFinishDownloadingResource: task.object, toFile: file) }
        } catch let error {
            delegates.call { $0.downloader(self, didCompleteWithError: error, withTask: downloadTask, whenDownloadingResource: task.object) }
        }
        task.terminated?()
        self.removeTask(task: task)
    }
    
    
}
