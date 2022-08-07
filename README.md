# SoClip - Coding interview
## File Download Library: _SoDownloadSDK_

![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)

_SoDownloadSDK_ is a librairy to download file with a url or a list of url, writen in swift.
## Features

- Add one or multiple files to download and store on disk
- Cancel one or multiple specific downloads, or all
- List current active downloads
- Limit the number of concurrent downloads
- Provide the list of current active downloads with progress
- Handle different download priorities

## Installation

_SoDownloadSDK_ requires [Xcode](https://apps.apple.com/fr/app/xcode/id497799835?mt=12).

In Xcode select File > Add Packages.
Then on search bar on top right enter the git url:

<https://github.com/cheignon/SoDownloadSDK.git>

On Dependency Rule select **Branch** and on the prompt write **main**
clck on Add Package.

## How to use
### use case
- **initialisation**
```swift
    let manager = SoDownloadSDK.shared
```
### advanced use case
- **initialisation**
```swift
let config = DownloadOperationQueueConfiguration(mode: .concurrentWith(limit: 10))

let fileManager = DownloadsFileManager(with: "YOUR_DIRECTORY")

let manager = SoDownloadSDK(configuration: config, fileManager: fileManager)
```
- **object to download**
```swift
let object = DownloadObject(url: "URL_OF_THE_FILE")

// you can provide the priority of the download with:
let object = DownloadObject(url: "URL_OF_THE_FILE", priority: .high)

```
- **start the download**
```swift
        do {
            try manger.addDownload(for: object)
        } catch let error {
            debugPrint(error.localizedDescription)
        }

// or with the list of object
        do {
            try manger.addDownload(for: [object])
        } catch let error {
            debugPrint(error.localizedDescription)
        }
```
- **to listen event of downloadind with _SoDownloadDelegate_**
```swift
class MyviewController: UIViewController, SoDownloadDelegate {
    .... 
    manager.addDelegate(self)
    ...
}
```
then you have like URLSessionDownloadDelegate && URLSessionTaskDelegate callback

```swift
    func downloader(_ downloader: SoDownloadSDK, didStartDownloadingObject object: DownloadObject, withTask task: URLSessionDownloadTask)
    
    func downloader(_ downloader: SoDownloadSDK, didUpdateStatusOfTask task: URLSessionDownloadTask, relatedToObject object: DownloadObject)
 
    func downloader(_ downloader: SoDownloadSDK, didFinishDownloadingObject object: DownloadObject, toFile file: DownloadedFile)

    func downloader(_ downloader: SoDownloadSDK, didCompleteWithError error: Error?, withTask task: URLSessionDownloadTask, whenDownloadingObject object: DownloadObject)

    func downloader(_ downloader: SoDownloadSDK, didFinishWithMostRecentError error: Error?)

```

- **when downloadind is finish you get a DownloadedFile object**
```swift
    func downloader(_ downloader: SoDownloadSDK, didFinishDownloadingObject resource: DownloadObject, toFile file: DownloadedFile) {
        // to get the url on the disk
         file.getUrl()
    }
```

### Cancel downloads

```swift
   manager.cancel(download: object.taskDescription)
   // several
   manager.cancel(downloads: [object1.taskDescription,object2.taskDescription])
   // or all
   manager.cancelAllDownloads() 
```

### List downloads

```swift
   let objects = manager.getDownloads()
```



