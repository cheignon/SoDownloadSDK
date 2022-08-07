//
//  File.swift
//
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation


public class DownloadsFileManager: DownloadFileManagerProtocol {
       
    public static var `default`: DownloadsFileManager {
        return DownloadsFileManager(with: "SoDownloadSDK")
    }
    
    public func removeFile(withUrl url: URL) throws {
        try FileManager.default.removeItem(atPath: url.path)
    }
    
    public func createUrl(for fileName: String) throws -> URL {
        try createDownloadsDirectoryIfNeeded()
        return try generateUrl(for: fileName)
    }
    
    
    let downloadsDirectory: String
    
    public init() {
        self.downloadsDirectory = "SoDownloadSDK"
    }
    
    public init(with downloadsDirectory: String) {
        self.downloadsDirectory = downloadsDirectory
    }
    
    public func directory(create: Bool = false) throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: create)
                .appendingPathComponent(self.downloadsDirectory)
    }
    
    public func move(from source: URL, to destination: URL) throws {
        return try FileManager.default.moveItem(at: source, to: destination)
    }
    
    public func cleanDirectory() throws {
        let directory = try directory()
        let content = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        try content.forEach({ try FileManager.default.removeItem(atPath: "\(directory.path)/\($0)")})
    }
    
    public func generateUrl(for fileName: String) throws -> URL {
        
        let directory = try directory(create: true)
        
        let basePath = directory.appendingPathComponent(fileName)
        let fileExtension = basePath.pathExtension
        let filenameWithoutExtension: String
        
        if fileExtension.count > 0 {
            filenameWithoutExtension = String(fileName.dropLast(fileExtension.count + 1))
        } else {
            filenameWithoutExtension = fileName
        }
        
        var destinationPath = basePath
        var existing = 0
        
        while FileManager.default.fileExists(atPath: destinationPath.path) {
            existing += 1
            
            let newFilenameWithoutExtension = "\(filenameWithoutExtension)(\(existing))"
            destinationPath = directory.appendingPathComponent(newFilenameWithoutExtension).appendingPathExtension(fileExtension)
        }
        
        return destinationPath
    }
    
    internal func createDownloadsDirectoryIfNeeded() throws {
        let directory = try directory()
        var isDir: ObjCBool = true
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDir) == false {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
