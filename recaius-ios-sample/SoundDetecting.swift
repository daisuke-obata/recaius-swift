//
//  SoundDetection.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AudioToolbox

import SwiftyEvents


internal enum SoundDetectorState {
    
    case Idling
    case Detecting
    
}


internal enum SoundDetectorStateEvent {
    
    case WillChange
    case DidChange
    
}


internal class SoundDetectorStatePublisher: EventEmitter<SoundDetectorStateEvent, SoundDetectorState> {
    
    internal var value: SoundDetectorState {
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
    
    
    internal init(value: SoundDetectorState) {
        self.value = value
        
        super.init()
    }
    
}


internal enum DetectingSoundStateEvent {
    
    case Detected
    case Lost
    
}


internal class DetectingSoundStatePublisher: EventEmitter<DetectingSoundStateEvent, Float> {
    
    internal let threshold: Float
    
    internal var isDetected: Bool {
        didSet {
            if oldValue != isDetected {
                if isDetected {
                    emit(.Detected, value: threshold)
                } else {
                    emit(.Lost, value: threshold)
                }
            }
        }
    }
    
    
    internal init(threshold: Float, isDetected: Bool) {
        self.threshold = threshold
        self.isDetected = isDetected
        
        super.init()
    }
    
}


internal func _AudioQueueInputCallback(
    inUserData: UnsafeMutablePointer<Void>,
    inAQ: AudioQueueRef,
    inBuffer: AudioQueueBufferRef,
    inStartTime: UnsafePointer<AudioTimeStamp>,
    inNumberPacketDescriptions: UInt32,
    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>)
{
    // Do nothing, because not recoding.
}


internal class SoundDetector: NSObject {
    
    internal let interval: Double
    internal let statePublisher: SoundDetectorStatePublisher
    internal let detectingSoundStatePublisher: DetectingSoundStatePublisher
    
    private var _queue: AudioQueueRef!
    private var _timer: NSTimer?
    private var _lostCounter = 0
    
    
    internal init(interval: Double, threshold: Float) {
        self.interval = interval
        self.statePublisher = SoundDetectorStatePublisher(value: .Idling)
        self.detectingSoundStatePublisher = DetectingSoundStatePublisher(threshold: threshold, isDetected: false)
        
        super.init()
    }
    
    
    internal func start() {
        if statePublisher.value != .Idling {
            return
        }
        
        
        let channels: UInt32 = 1
        let bitsPerChannel: UInt32 = 16
        
        var format = AudioStreamBasicDescription(
            mSampleRate: 16000.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: AudioFormatFlags(kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked),
            mBytesPerPacket: (bitsPerChannel / 8) * channels,
            mFramesPerPacket: 1,
            mBytesPerFrame: (bitsPerChannel / 8) * channels,
            mChannelsPerFrame: channels,
            mBitsPerChannel: bitsPerChannel,
            mReserved: 0)
        
        var error = noErr
        
        var audioQueue: AudioQueueRef = nil
        error = AudioQueueNewInput(
            &format,
            _AudioQueueInputCallback,
            UnsafeMutablePointer(unsafeAddressOf(self)),
            .None,
            .None,
            0,
            &audioQueue)
        if error != noErr {
            fatalError()
        } else {
            _queue = audioQueue
        }
        
        error = AudioQueueStart(_queue, nil)
        if error != noErr {
            fatalError()
        }
        
        var enabledLevelMeter: UInt32 = 1
        error = AudioQueueSetProperty(_queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, UInt32(sizeof(UInt32)))
        if error != noErr {
            fatalError()
        }
        
        _timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SoundDetector.handleTimer(_:)), userInfo: nil, repeats: true)
        _timer?.fire()
        
        statePublisher.value = .Detecting
    }
    
    internal func stop() {
        if statePublisher.value != .Detecting {
            return
        }
        
        _timer?.invalidate()
        _timer = nil
        
        AudioQueueFlush(_queue)
        AudioQueueStop(_queue, false)
        AudioQueueDispose(_queue, true)
        _queue = nil
        
        statePublisher.value = .Idling
    }
    
    internal func handleTimer(timer: NSTimer) {
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(sizeof(AudioQueueLevelMeterState))
        
        var error = noErr
        
        error = AudioQueueGetProperty(
            _queue,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)
        if error != noErr {
            fatalError()
        }
        
        if levelMeter.mPeakPower >= detectingSoundStatePublisher.threshold {
            detectingSoundStatePublisher.isDetected = true
            _lostCounter = 0
        } else {
            if _lostCounter > 2 {
                detectingSoundStatePublisher.isDetected = false
                _lostCounter = 0
            } else {
                _lostCounter += 1
            }
        }
    }
    
}


internal class SoundDetectingManager {
    
    private static var _detector: SoundDetector?
    
    private static var _interval: Double = 0.5
    private static var _threshold: Float = -5.0
    
    
    internal static func configure(interval: Double, threshold: Float) {
        _detector = nil
        
        _interval = interval
        _threshold = threshold
    }
    
    internal static func sharedDetector() -> SoundDetector {
        if let detector = _detector {
            return detector
        } else {
            _detector = SoundDetector(interval: _interval, threshold: _threshold)
            return _detector!
        }
    }
    
}
