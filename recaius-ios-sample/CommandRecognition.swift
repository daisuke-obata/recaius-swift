//
//  CommandRecognition.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import RecaiusSDKTrial


internal enum Command {
    
    case Wikipedia(String)

}

internal struct CommandRecognizer {

    internal let results: [RecognitionNBestResult]
    
    
    internal init (results: [RecognitionNBestResult]) {
        self.results = results
        debugPrint(results)
    }
    
    
    
    internal func recognize() -> Command? {
        var command: Command? = nil
        
        for result in results {
            switch result {
            case .RESULT(let object):
                if object.count > 0 {
                    var title: String?
                    
                    for word in object[0].words {
                        title = word.string
                    }
                    
                    if title != nil {
                        command = Command.Wikipedia(title!)
                    }
                }
            case .TMP_RESULT(let string):
                command = Command.Wikipedia(string)
            default:
                break
            }
        }
        
        return command
    }

}