//
//  SoundRecoding.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AVFoundation

import BrightFutures
import SwiftyEvents


internal enum SoundRecoderState {
    
    case Idling
    case Recoding
    
}


internal enum SoundRecoderStateEvent {
    
    case WillChange
    case DidChange
    
}


internal class SoundRecoderStatePublisher: EventEmitter<SoundRecoderStateEvent, SoundRecoderState> {
    
    internal var value: SoundRecoderState {
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
    
    
    internal init(value: SoundRecoderState) {
        self.value = value
        
        super.init()
    }
    
}


internal class SoundRecoder {
    
    internal let statePublisher: SoundRecoderStatePublisher
    
    private var _recoder: AVAudioRecorder?
    
    
    internal init() {
        statePublisher = SoundRecoderStatePublisher(value: .Idling)
    }
    
    
    internal func record() {
        if statePublisher.value != .Idling {
            return
        }
        
        let tempDirURL = NSURL(string: NSTemporaryDirectory())!
        let fileName = "\(NSUUID().UUIDString).wav)"
        let fileURL = tempDirURL.URLByAppendingPathComponent(fileName)
        
        do {
            _recoder = try AVAudioRecorder(
                URL: fileURL,
                settings: [
                    AVEncoderBitRateKey: 16,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 16000.0
                ])
        } catch {
            fatalError()
        }
        
        _recoder?.record()
        
        statePublisher.value = .Recoding
    }
    
    internal func stop() -> Future<NSURL, NSError> {
        let promise = Promise<NSURL, NSError>()
        
        if statePublisher.value != .Recoding {
            promise.failure(NSError(domain: "", code: 0, userInfo: nil))
        }
        
        _recoder?.stop()
        
        promise.success(_recoder!.url)
        
        _recoder = nil
        statePublisher.value = .Idling
        
        return promise.future
    }
    
}


internal class SoundRecodingManager {
    
    private static var _recoder: SoundRecoder?
    
    
    internal static func sharedRecoder() -> SoundRecoder {
        if let recoder = _recoder {
            return recoder
        } else {
            _recoder = SoundRecoder()
            return _recoder!
        }
    }
    
}
