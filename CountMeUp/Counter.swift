//
//  Counter.swift
//  CountMeUp
//
//  Created by Gustav Schmid on 11.03.19.
//  Copyright © 2019 Gustav Schmid. All rights reserved.
//

import Foundation


class Counter {
    
    let name: String
    private var queue = DispatchQueue(label: "your.queue.identifier")
    private (set) var value: Int64 = 0
    
    init (name: String, initialValue: Int64) {
        self.name = name
        self.value = initialValue
    }
    
    convenience init? (json: [String: Any]) {
        guard let name = json["name"] as? String,
            let initialValue = json["counterStatus"] as? Int64 else {
                print("error parsing in counters")
                return nil
        }
        self.init(name: name, initialValue: initialValue)
    }
    
    func increment() {
        queue.sync {
            value += 1
        }
    }
    
    func increment(by delta: Int64) {
        queue.sync {
            value += delta
        }
    }
    
    func decrement(by delta: Int64) {
        queue.sync {
            value -= delta
        }
    }
    
    
    
}
