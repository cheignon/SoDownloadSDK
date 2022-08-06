//
//  File.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public struct DownloadedFile {
    
    public let path: String
   
    public init(relativePath: String) {
        self.path = relativePath
    }
    
    public func url() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(path)
    }
}
