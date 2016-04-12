//
//  Recognition.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures


public func recognizeJapanese(
    URL: NSURL,
    audioType: RecognitionAudioType,
    threshold: EnergyThreshold,
    resultCount: Int) -> Future<[RecognitionNBestResult], ServiceError>
{
    let model = BaseRecognitionModel.Japanese
    let pushToTalkSetting = PushToTalkSetting.Deactive
    let dataLogSetting = DataLogSetting.Deactive
    
    return recognizeJapanese(
        URL,
        audioType: audioType,
        threshold: threshold,
        resultCount: resultCount,
        model: model,
        pushToTalkSetting: pushToTalkSetting,
        dataLogSetting: dataLogSetting)
}


public func recognizeJapanese(
    URL: NSURL,
    audioType: RecognitionAudioType,
    threshold: EnergyThreshold,
    resultCount: Int,
    model: RecognitionModelCompatible,
    pushToTalkSetting: PushToTalkSetting,
    dataLogSetting: DataLogSetting) -> Future<[RecognitionNBestResult], ServiceError>
{
    let promise = Promise<[RecognitionNBestResult], ServiceError>()
    
    let resultType = RecognitionResultType.NBest(resultCount)
    
    let credential = RecognitionServiceCredential(
        id: Service.configuration.id,
        password: Service.configuration.password)
    
    let setting = RecognitionSetting(
        audioType: audioType,
        threshold: threshold,
        resultType: resultType,
        model: model,
        pushToTalkSetting: pushToTalkSetting,
        dataLogSetting: dataLogSetting)
    
    RecognitionAPIClient.login(credential, setting: setting)
        .onSuccess { UUID in
            
            if let processor = FileURLAudioDataProcessor(URL: URL) {
                
                processor.getArrayOfData(16384).enumerate()
                    .map({ (index, voice) -> Future<[RecognitionNBestResult], ServiceError> in
                        return RecognitionAPIClient.putVoice(UUID, voiceID: index + 1, voice: voice)
                    })
                    .sequence()
                    .onSuccess{ arrayOfResults in
                        
                        Queue.global.after(TimeInterval.In(3.0), block: { () -> Void in
                            RecognitionAPIClient.getResult(UUID)
                                .onSuccess { results in
                                    
                                    RecognitionAPIClient.logout(UUID)
                                    
                                    promise.success(results)
                                    
                                }.onFailure { error in
                                    promise.failure(error)
                            }
                        })
                        
                    }.onFailure { error in
                        promise.failure(error)
                }
                
            } else {
                promise.failure(ServiceError.Unknown)
            }
            
        }.onFailure { error in
            promise.failure(error)
    }
    
    return promise.future
}
