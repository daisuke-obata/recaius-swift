//
//  SoundPlaying.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AVFoundation

import SwiftyEvents


internal enum SoundPlayerState {
    
    case Idling
    case Pausing
    case Playing
    
}


internal enum SoundPlayerStateEvent {
    
    case WillChange
    case DidChange
    
}


internal class SoundPlayerStatePublisher: EventEmitter<SoundPlayerStateEvent, SoundPlayerState> {
    
    internal var value: SoundPlayerState {
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
    
    
    internal init(value: SoundPlayerState) {
        self.value = value
        
        super.init()
    }
    
}


internal class SoundPlayer: NSObject {
    
    internal let statePublisher: SoundPlayerStatePublisher
    
    private var _player: AVQueuePlayer?
    private var _items: [AVPlayerItem] = []
    private var _checkPlayingTimer: NSTimer?
    
    
    internal override init() {
        statePublisher = SoundPlayerStatePublisher(value: .Idling)
        
        super.init()
    }
    
    
    internal func appendItem(item: AVPlayerItem) {
        switch statePublisher.value {
        case .Idling:
            _items.append(item)
        case .Pausing, .Playing:
            _player?.insertItem(item, afterItem: nil)
        }
    }
    
    internal func appendItems(items: [AVPlayerItem]) {
        switch statePublisher.value {
        case .Idling:
            _items.appendContentsOf(items)
        case .Pausing, .Playing:
            if let player = _player {
                items.forEach { item in
                    player.insertItem(item, afterItem: nil)
                }
            }
        }
    }
    
    internal func play() {
        if statePublisher.value != .Idling {
            return
        }
        
        _player = AVQueuePlayer(items: _items)
        _items.removeAll()
        
        _player?.play()
        
        _checkPlayingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SoundPlayer.handleCheckPlayingTimer(_:)), userInfo: nil, repeats: true)
        _checkPlayingTimer?.fire()
        
        statePublisher.value = .Playing
    }
    
    internal func pause() {
        if statePublisher.value != .Playing {
            return
        }
        
        _player?.pause()
        
        _checkPlayingTimer?.invalidate()
        _checkPlayingTimer = nil
        
        statePublisher.value = .Pausing
    }
    
    internal func restart() {
        if statePublisher.value != .Pausing {
            return
        }
        
        _player?.play()
        
        _checkPlayingTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SoundPlayer.handleCheckPlayingTimer(_:)), userInfo: nil, repeats: true)
        _checkPlayingTimer?.fire()
        
        statePublisher.value = .Playing
    }
    
    internal func stop() {
        if statePublisher.value != .Playing && statePublisher.value != .Pausing {
            return
        }
        
        _player?.pause()
        _player?.removeAllItems()
        _player = nil
        
        statePublisher.value = .Idling
    }
    
    internal func handleCheckPlayingTimer(timer: NSTimer) {
        if let player = _player {
            if (player.currentItem == nil) {
                stop()
            }
        } else {
            statePublisher.value = .Idling
        }
    }
    
}


internal class SoundPlayingManager {
    
    private static var _player: SoundPlayer?
    
    
    internal static func sharedPlayer() -> SoundPlayer {
        if let player = _player {
            return player
        } else {
            _player = SoundPlayer()
            return _player!
        }
    }
    
}
