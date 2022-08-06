//
//  Download+FileManager.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

extension FileManager {
    public static func createPath(forResourceWithName name: String, usingConfiguration configuration: DownloadOperationQueueConfiguration = DownloadOperationQueueConfiguration.default) -> URL? {
        let fileManager = DownloadsFileManager(with: configuration.downloadsDirectoryName)
        guard let downloads = try? fileManager.directory(create: false) else { return nil }
        let path = downloads.appendingPathComponent(name)
        guard FileManager.default.fileExists(atPath: path.path) else { return nil }
        return path
    }
}
