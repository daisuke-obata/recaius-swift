//
//  Synthesis.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AVFoundation

import Alamofire
import BrightFutures


public func synthesizeJapanese(
    plainText: PlainText,
    speaker: SynthesisJapaneseSpeaker) -> Future<AVPlayerItem, ServiceError>
{
    let commonParameters = SynthesisCommonParameters(
        speed: 0,
        pitch: 0,
        depth: 0,
        volume: 50,
        uPower: 0)
    
    let emotionParameters = SynthesisEmotionParameters(
        happy: 0,
        angry: 0,
        sad: 0,
        fear: 0,
        tender: 0)
    
    let tagModeSetting = TagModeSetting.Deactive
    let readDigitSetting = ReadDigitSetting.Digit
    let readSymbolSetting = ReadSymbolSetting.Ignore
    let readAlphabetSetting = ReadAlphabetSetting.JapaneseEnglish
    
    return synthesizeJapanese(
        plainText,
        speaker: speaker,
        commonParameters: commonParameters,
        emotionParameters: emotionParameters,
        tagModeSetting: tagModeSetting,
        readDigitSetting: readDigitSetting,
        readSymbolSetting: readSymbolSetting,
        readAlphabetSetting: readAlphabetSetting)
}


public func synthesizeJapanese(
    plainText: PlainText,
    speaker: SynthesisJapaneseSpeaker,
    commonParameters: SynthesisCommonParameters,
    emotionParameters: SynthesisEmotionParameters,
    tagModeSetting: TagModeSetting,
    readDigitSetting: ReadDigitSetting,
    readSymbolSetting: ReadSymbolSetting,
    readAlphabetSetting: ReadAlphabetSetting) -> Future<AVPlayerItem, ServiceError>
{
    let promise = Promise<AVPlayerItem, ServiceError>()
    
    let credential = SynthesisServiceCredential(
        id: Service.configuration.id,
        password: Service.configuration.password,
        userName: nil)
    let codec = SynthesisCodec.LinearPCM(352)
    
    let parameters = SynthesisAPI.PlainTextToSpeechParameters(
        credential: credential,
        plainText: plainText,
        language: SynthesisLanguage.Japanese,
        speaker: speaker,
        userDictionaryIDs: nil,
        commonParameters: commonParameters,
        emotionParameters: emotionParameters,
        tagModeSetting: tagModeSetting,
        japaneseReadDigitSetting: readDigitSetting,
        japaneseReadSymbolSetting: readSymbolSetting,
        japaneseReadAlphabetSetting: readAlphabetSetting,
        readDigitSetting: nil,
        codec: codec)
    
    request(SynthesisAPI.PlainTextToSpeech(parameters))
    .response { request, response, data, error in
        switch responseErrorHandling(request, response, data, error) {
        case .Success(let data):
            let tempDirURL = NSURL(string: NSTemporaryDirectory())!
            let fileName = "\(NSUUID().UUIDString).\(codec.fileNameExtension)"
            let filePath = tempDirURL.URLByAppendingPathComponent(fileName).URLString
            
            if NSFileManager.defaultManager().createFileAtPath(filePath, contents: data, attributes: nil) {
                let item = AVPlayerItem(URL: NSURL(fileURLWithPath: filePath))
                promise.success(item)
            } else {
                promise.failure(ServiceError.Unknown)
            }
        case .Failure(let error):
            promise.failure(ServiceError(code: error.code))
        }
    }
    
    return promise.future
}


public func synthesizeJapanese(
    plainText: PlainText,
    speaker: SynthesisJapaneseSpeaker,
    commonParameters: SynthesisCommonParameters,
    emotionParameters: SynthesisEmotionParameters,
    tagModeSetting: TagModeSetting,
    readDigitSetting: ReadDigitSetting,
    readSymbolSetting: ReadSymbolSetting,
    readAlphabetSetting: ReadAlphabetSetting,
    userName: String,
    userDictionaryIDs: [SynthesisUserDictionaryID]) -> Future<AVPlayerItem, ServiceError>
{
    let promise = Promise<AVPlayerItem, ServiceError>()
    
    let credential = SynthesisServiceCredential(
        id: Service.configuration.id,
        password: Service.configuration.password,
        userName: userName)
    let codec = SynthesisCodec.LinearPCM(352)
    
    let parameters = SynthesisAPI.PlainTextToSpeechParameters(
        credential: credential,
        plainText: plainText,
        language: SynthesisLanguage.Japanese,
        speaker: speaker,
        userDictionaryIDs: userDictionaryIDs,
        commonParameters: commonParameters,
        emotionParameters: emotionParameters,
        tagModeSetting: tagModeSetting,
        japaneseReadDigitSetting: readDigitSetting,
        japaneseReadSymbolSetting: readSymbolSetting,
        japaneseReadAlphabetSetting: readAlphabetSetting,
        readDigitSetting: nil,
        codec: codec)
    
    request(SynthesisAPI.PlainTextToSpeech(parameters))
    .response { request, response, data, error in
        switch responseErrorHandling(request, response, data, error) {
        case .Success(let data):
            let tempDirURL = NSURL(string: NSTemporaryDirectory())!
            let fileName = "\(NSUUID().UUIDString).\(codec.fileNameExtension)"
            let filePath = tempDirURL.URLByAppendingPathComponent(fileName).URLString
            
            if NSFileManager.defaultManager().createFileAtPath(filePath, contents: data, attributes: nil) {
                let item = AVPlayerItem(URL: NSURL(fileURLWithPath: filePath))
                promise.success(item)
            } else {
                promise.failure(ServiceError.Unknown)
            }
        case .Failure(let error):
            promise.failure(ServiceError(code: error.code))
        }
    }
    
    return promise.future
}
