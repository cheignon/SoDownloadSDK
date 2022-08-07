//
//  DownloadFileManagerProtocol.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public protocol DownloadFileManagerProtocol: AnyObject {
    func directory(create: Bool) throws -> URL
    func move(from source: URL, to destination: URL) throws
    func cleanDirectory() throws
    func removeFile(withUrl url: URL) throws
    func createUrl(for fileName: String) throws -> URL
}
