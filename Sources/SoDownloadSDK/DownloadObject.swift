//
//  DownloadObject.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public struct DownloadObject: Equatable {
    
    public enum Priority {
        case none
        case low
        case high
    }
    
    public let taskDescription: String
    public let url: URL?
    public let name: String
    public let priority: Priority

    
    public init(url: String, priority: Priority = .none) {
        self.taskDescription = UUID().uuidString
        self.url = URL(string: url)
        self.priority = priority
        guard let path = self.url?.lastPathComponent else {
            self.name = "unknown"
            return
        }
        self.name = path

    }
    
    public static func == (lhs: DownloadObject, rhs: DownloadObject) -> Bool {
        return lhs.taskDescription == rhs.taskDescription && lhs.url == rhs.url && lhs.name == rhs.name
    }
}

