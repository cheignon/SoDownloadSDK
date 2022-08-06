//
//  DownloadObject.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public struct DownloadObject: Equatable {
    
    public let taskDescription: String
    public let url: URL?
    public let name: String
    
    public init(taskDescription: String, url: URL?, name: String) {
        self.taskDescription = taskDescription
        self.url = url
        self.name = name
    }
    
    public static func == (lhs: DownloadObject, rhs: DownloadObject) -> Bool {
        return lhs.taskDescription == rhs.taskDescription && lhs.url == rhs.url && lhs.name == rhs.name
    }
}

