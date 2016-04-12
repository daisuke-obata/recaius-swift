//
//  AppOperating.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AVFoundation

import SwiftState
import SwiftyEvents

import RecaiusSDKTrial


internal enum AppState: StateType {
    
    case Initializing
    case Idling
    case AcceptingInput
    case NotifyingCommandUnrecognized
    case SpeakingWikipediaContent
    case Terminating
    case Unauthorized
    
}


internal enum AppStateEvent {
    
    case WillChange
    case DidChange
    
}


internal class AppStatePublisher: EventEmitter<AppStateEvent, AppState> {
    
    internal var value: AppState {
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
    
    
    internal init(value: AppState) {
        self.value = value
        
        super.init()
    }
    
}


internal class AppOperator: NSObject {
    
    internal let statePublisher: AppStatePublisher
    
    private let soundDetector: SoundDetector
    private let soundRecoder: SoundRecoder
    private let soundPlayer: SoundPlayer
    
    private let session = AVAudioSession.sharedInstance()
    private let notificationCenter = NSNotificationCenter.defaultCenter()
    
    internal var stateMachine: StateMachine<AppState, NoEvent>?
    
    internal override init() {
        self.statePublisher = AppStatePublisher(value: .Initializing)
        
        self.soundDetector = SoundDetectingManager.sharedDetector()
        self.soundRecoder = SoundRecodingManager.sharedRecoder()
        self.soundPlayer = SoundPlayingManager.sharedPlayer()
        
        super.init()
        
        self.initializeNotificationCenter()
        self.initializeStateMachine()
    }
    
    private func initializeNotificationCenter() {
        notificationCenter.addObserver(
            self,
            selector: #selector(AppOperator.handleDidBecomeActiveNotification(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
        notificationCenter.addObserver(
            self,
            selector: #selector(AppOperator.handleDidEnterBackgroundNotification(_:)),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
    }
    
    private func initializeStateMachine() {
        self.stateMachine = StateMachine<AppState, NoEvent>(state: .Initializing) { machine in
            
            machine.addRoute(.Any => .Unauthorized) { context in
                debugPrint("[AppState] Unauthorized")
                
                self.statePublisher.value = .Unauthorized
            }
            
            machine.addRoute(.Any => .Initializing) { context in
                debugPrint("[AppState] Initializing")
                
                self.statePublisher.value = .Initializing
                
                let configuration = ServiceConfiguration(id: "YOUR SERVICE ID", password: "YOUR SERVICE PASSWORD")
                Service.configure(configuration)
                
                try! self.session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: .DefaultToSpeaker)
                try! self.session.setActive(true)
                
                let checkPermission: () -> Void = {
                    self.session.requestRecordPermission { granted in
                        if granted {
                            self.stateMachine! <- .Idling
                        } else {
                            self.stateMachine! <- .Unauthorized
                        }
                    }
                }
                
                checkPermission()
            }
            
            machine.addRoute(.Any => .Idling) { context in
                debugPrint("[AppState] Idling")
                
                self.statePublisher.value = .Idling
                
                self.soundDetector.detectingSoundStatePublisher.on(.Detected) { _ in
                    self.soundDetector.detectingSoundStatePublisher.removeAllListeners()
                    
                    self.stateMachine! <- .AcceptingInput
                }
                
                self.soundDetector.start()
            }
            
            machine.addRoute(.Idling => .AcceptingInput) { context in
                debugPrint("[AppState] AcceptingInput")
                
                self.statePublisher.value = .AcceptingInput
                
                synthesizeJapanese("はい？", speaker: .Sakura)
                .onSuccess { item in
                    self.soundPlayer.appendItem(item)
                    
                    self.soundPlayer.statePublisher.on(.DidChange) { state in
                        switch state {
                        case .Idling:
                            self.soundPlayer.statePublisher.removeAllListeners()
                            
                            self.soundDetector.detectingSoundStatePublisher.once(.Lost) { _ in
                                self.soundDetector.detectingSoundStatePublisher.removeAllListeners()
                                
                                self.soundRecoder.stop()
                                .onSuccess { URL in
                                    recognizeJapanese(URL, audioType: .LinearPCM, threshold: 170, resultCount: 1)
                                    .onSuccess { results in
                                        if let command = CommandRecognizer(results: results).recognize() {
                                            switch command {
                                            case .Wikipedia(let title):
                                                self.stateMachine! <- (.SpeakingWikipediaContent, title)
                                            }
                                        } else {
                                            self.stateMachine! <- .NotifyingCommandUnrecognized
                                        }
                                    }
                                }
                            }
                            
                            self.soundRecoder.record()
                        default:
                            break
                        }
                    }
                    
                    self.soundPlayer.play()
                }.onFailure { error in
                    debugPrint(error)
                }
            }
            
            machine.addRoute(.AcceptingInput => .NotifyingCommandUnrecognized) { context in
                debugPrint("[AppState] NotifyingCommandUnrecognized")
                
                self.statePublisher.value = .NotifyingCommandUnrecognized
                
                synthesizeJapanese("申し訳ありません、よく聞き取れませんでした。", speaker: .Sakura)
                .onSuccess { item in
                    self.soundPlayer.appendItem(item)
                    
                    self.soundPlayer.statePublisher.on(.DidChange) { state in
                        switch state {
                        case .Idling:
                            self.soundPlayer.statePublisher.removeAllListeners()
                            
                            self.stateMachine! <- .Idling
                        default:
                            break
                        }
                    }
                    
                    self.soundPlayer.play()
                }
            }
            
            machine.addRoute(.AcceptingInput => .SpeakingWikipediaContent) { context in
                debugPrint("[AppState] SpeakingWikipediaContent")
                
                self.statePublisher.value = .SpeakingWikipediaContent
                
                let title = context.userInfo as! String
                
                Wikipedia.getExtract(title)
                .onSuccess { extract in
                    if let extract = extract {
                        synthesizeJapanese(extract, speaker: .Sakura)
                        .onSuccess { item in
                            self.soundPlayer.appendItem(item)
                            
                            self.soundPlayer.statePublisher.on(.DidChange) { state in
                                switch state {
                                case .Idling:
                                    self.soundPlayer.statePublisher.removeAllListeners()
                                    
                                    self.stateMachine! <- .Idling
                                default:
                                    break
                                }
                            }
                            
                            self.soundPlayer.play()
                        }
                    } else {
                        synthesizeJapanese("Wikipediaで見つかりませんでした。", speaker: .Sakura)
                        .onSuccess { item in
                            self.soundPlayer.appendItem(item)
                            
                            self.soundPlayer.statePublisher.on(.DidChange) { state in
                                switch state {
                                case .Idling:
                                    self.soundPlayer.statePublisher.removeAllListeners()
                                    
                                    self.stateMachine! <- .Idling
                                default:
                                    break
                                }
                            }
                            
                            self.soundPlayer.play()
                        }
                    }
                }
            }
            
            machine.addRoute(.Any => .Terminating) { context in
                debugPrint("[AppState] Terminating")
                
                self.statePublisher.value = .Terminating
                
                self.soundDetector.stop()
                self.soundRecoder.stop()
                self.soundPlayer.stop()
                
                self.soundDetector.statePublisher.removeAllListeners()
                self.soundDetector.detectingSoundStatePublisher.removeAllListeners()
                
                self.soundRecoder.statePublisher.removeAllListeners()
                
                self.soundPlayer.statePublisher.removeAllListeners()
            }
            
            machine.addErrorHandler { event, fromState, toState, userInfo in
                debugPrint("[Error] \(fromState) \(toState)")
            }
        }
    }
    
    
    internal func handleDidBecomeActiveNotification(notification: NSNotification) {
        if let machine = self.stateMachine {
            machine <- .Initializing
        }
    }
    
    internal func handleDidEnterBackgroundNotification(notification: NSNotification) {
        if let machine = self.stateMachine {
            machine <- .Terminating
        }
    }

}
