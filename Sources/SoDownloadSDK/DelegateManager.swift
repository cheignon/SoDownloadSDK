//
//  File.swift
//  
//
//  Created by Dorian Cheignon on 06/08/2022.
//

import Foundation

internal class DelegateManager<T> {
    
    private let delegates: NSHashTable<AnyObject>
    private let queue: DispatchQueue    
    
    init(delegateQueue queue: DispatchQueue) {
        delegates = NSHashTable<AnyObject>.weakObjects()
        self.queue = queue
    }
    
    var isEmpty: Bool {
        return delegates.count == 0
    }
    
    func addDelegate(_ delegate: T) {
        queue.async { [weak self] in
            self?.delegates.add(delegate as AnyObject)
        }
    }
    
    func removeDelegate(_ delegate: T) {
        queue.async { [weak self] in
            self?.delegates.remove(delegate as AnyObject)
        }
    }
    
    func call(_ call: @escaping (T) -> ()) {
        queue.async {
            for delegate in self.delegates.allObjects {
                call(delegate as! T)
            }
        }
    }
    
    
}
