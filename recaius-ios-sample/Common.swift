//
//  Common.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import SwiftyEvents


internal enum AvailableEvent {
    
    case WillChange
    case DidChange
    
}


internal class Available: EventEmitter<AvailableEvent, Bool> {
    
    internal var value: Bool {
        willSet {
            if newValue != value {
                emit(.WillChange, value: value)
            }
        }
        
        didSet {
            if oldValue != value {
                emit(.DidChange, value: value)
            }
        }
    }
    
    
    internal init(value: Bool) {
        self.value = value
        
        super.init()
    }
    
}