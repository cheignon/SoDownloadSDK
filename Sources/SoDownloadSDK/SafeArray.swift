//
//  File.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

public class SafeArray<Element> {
    
    let queue = DispatchQueue(label: "SoDownloadSDK.SafeArray", attributes: .concurrent)
    var array = [Element]()
    
    public init() { }
    
    public convenience init(_ array: [Element]) {
        self.init()
        self.array = array
    }
    
    var first: Element? {
        var result: Element?
        queue.sync { result = self.array.first }
        return result
    }
    
    var last: Element? {
        var result: Element?
        queue.sync { result = self.array.last }
        return result
    }
    
    var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }
    
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }
}


public extension SafeArray {
    
    
    func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }
    
    func last(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.last(where: predicate) }
        return result
    }
    
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> SafeArray? {
        var result: SafeArray?
        queue.sync { result = SafeArray(self.array.filter(isIncluded)) }
        return result
    }
    
    func firstIndex(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
    
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }
    
    func contains(where predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
    
    func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            DispatchQueue.main.async { completion?(elements) }
        }
    }
    
    static func +=(left: inout SafeArray, right: Element) {
        left.append(right)
    }
    
    static func +=(left: inout SafeArray, right: [Element]) {
        left.append(right)
    }
    
    func append(_ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func append(_ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    func remove(where predicate: @escaping (Element) -> Bool, completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            var elements = [Element]()
            
            while let index = self.array.firstIndex(where: predicate) {
                elements.append(self.array.remove(at: index))
            }
            
            DispatchQueue.main.async { completion?(elements) }
        }
    }
    
    func sorted(by criteria: (Element, Element) -> Bool) -> SafeArray {
            var result: SafeArray?
            queue.sync { result = SafeArray(self.array.sorted(by: criteria)) }
            return result!
    }
}

public extension SafeArray where Element: Equatable {
    
    func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }
}
