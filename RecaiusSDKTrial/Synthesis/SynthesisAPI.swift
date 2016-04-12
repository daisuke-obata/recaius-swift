//
//  SynthesisAPI.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures


internal enum SynthesisAPI: URLRequestConvertible {
    
    internal struct PlainTextToSpeechParameters {
        
        internal let credential: SynthesisServiceCredential
        internal let plainText: PlainText
        internal let language: SynthesisLanguage
        internal let speaker: SynthesisSpeakerCompatible
        internal let userDictionaryIDs: [SynthesisUserDictionaryID]?
        internal let commonParameters: SynthesisCommonParameters
        internal let emotionParameters: SynthesisEmotionParameters
        internal let tagModeSetting: TagModeSetting
        internal let japaneseReadDigitSetting: ReadDigitSetting?
        internal let japaneseReadSymbolSetting: ReadSymbolSetting?
        internal let japaneseReadAlphabetSetting: ReadAlphabetSetting?
        internal let readDigitSetting: ReadDigitSetting?
        internal let codec: SynthesisCodec
        
    }
    
    
    internal static let baseURLString = "https://try-api.recaius.jp/tts/v1"
    
    
    case PlainTextToSpeech(PlainTextToSpeechParameters)
    case PlainTextToPhoneticText
    case PhoneticTextToSpeech
    
    
    internal var method: Alamofire.Method {
        return .POST
    }
    
    internal var path: String {
        switch self {
        case .PlainTextToSpeech(_):
            return "/plaintext2speechwave"
        case .PlainTextToPhoneticText:
            return "/plaintext2phonetictext"
        case .PhoneticTextToSpeech:
            return "phonetictext2speechwave"
        }
    }
    
    
    // MARK: - URLRequestConvertible
    
    internal var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: SynthesisAPI.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .PlainTextToSpeech(let parameters):
            var body: [String: AnyObject] = [:]
            body["id"] = parameters.credential.id
            body["password"] = parameters.credential.password
            
            if let userName = parameters.credential.userName {
                body["user_name"] = userName
            }
            
            body["plain_text"] = parameters.plainText
            body["lang"] = parameters.language.value
            body["speaker_id"] = parameters.speaker.id
            
            if let IDs = parameters.userDictionaryIDs {
                body["user_lang_dict_ids"] = IDs
            }
            
            body["speed"] = parameters.commonParameters.speed
            body["pitch"] = parameters.commonParameters.pitch
            body["depth"] = parameters.commonParameters.depth
            body["volume"] = parameters.commonParameters.volume
            body["upower"] = parameters.commonParameters.uPower
            
            body["happy"] = parameters.emotionParameters.happy
            body["angry"] = parameters.emotionParameters.angry
            body["sad"] = parameters.emotionParameters.sad
            body["fear"] = parameters.emotionParameters.fear
            body["tender"] = parameters.emotionParameters.tender
            
            body["tag_mode"] = parameters.tagModeSetting.int
            
            if let setting = parameters.japaneseReadDigitSetting {
                body["txtproc_jajp_read_digit"] = setting.int
            }
            
            if let setting = parameters.japaneseReadSymbolSetting {
                body["txtproc_jajp_read_symbol"] = setting.int
            }
            
            if let setting = parameters.japaneseReadAlphabetSetting {
                body["txtproc_jajp_read_alphabet"] = setting.int
            }
            
            if let setting = parameters.readDigitSetting {
                body["txtproc_read_digit"] = setting.int
            }
            
            body["codec"] = parameters.codec.contentType
            body["kbitrate"] = parameters.codec.bitRate
            
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: body).0
        default:
            return mutableURLRequest
        }
    }
    
}