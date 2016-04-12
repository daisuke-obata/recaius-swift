//
//  RecognitionModel.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import SwiftyJSON


internal typealias Byte = UInt8


internal extension RecognitionResultType {
    
    internal var string: String {
        switch self {
        case .NBest(_):
            return "nbest"
        case .OneBest:
            return "one_best"
        case .Confnet:
            return "confnet"
        }
    }
    
}


internal extension PushToTalkSetting {
    
    internal var string: String {
        switch self {
        case .Active:
            return "true"
        case .Deactive:
            return "false"
        }
    }
    
}


internal extension DataLogSetting {
    
    internal var int: Int {
        switch self {
        case .Active(_):
            return 1
        case .Deactive:
            return 0
        }
    }
    
}


internal struct RecognitionSetting {
    
    internal let audioType: RecognitionAudioType
    internal let energyThreshold: EnergyThreshold
    internal let resultType: RecognitionResultType
    internal let recognizationModel: RecognitionModelCompatible
    internal let pushToTalkSetting: PushToTalkSetting
    internal let dataLogSetting: DataLogSetting
    
    
    internal init(
        audioType: RecognitionAudioType,
        threshold: EnergyThreshold,
        resultType: RecognitionResultType,
        model: RecognitionModelCompatible,
        pushToTalkSetting: PushToTalkSetting,
        dataLogSetting: DataLogSetting)
    {
        self.audioType = audioType
        self.energyThreshold = threshold
        self.resultType = resultType
        self.recognizationModel = model
        self.pushToTalkSetting = pushToTalkSetting
        self.dataLogSetting = dataLogSetting
    }
    
    
    internal func toDictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        dict["audiotype"] = audioType.contentType
        dict["energy_threshold"] = energyThreshold
        dict["resulttype"] = resultType.string
        if let count = resultType.count {
            dict["resultcount"] = count
        }
        dict["model_id"] = recognizationModel.id
        //        dict["pushtotalk"] = pushToTalkSetting.jsonString
        dict["datalog"] = dataLogSetting.int
        if let comment = dataLogSetting.comment {
            dict["comment"] = comment
        }
        
        return dict
    }
    
}


internal extension RecognitionNBestResult {
    
    internal init?(json: JSON) {
        if let type = json["type"].string {
            switch type {
            case "RESULT":
                if let result = json["result"].array {
                    var objects: [RecognitionNBestResultObject] = []
                    result.forEach({ (json) -> () in
                        if let object = RecognitionNBestResultObject(json: json) {
                            objects.append(object)
                        }
                    })
                    self = RecognitionNBestResult.RESULT(objects)
                } else {
                    return nil
                }
            case "TMP_RESULT":
                if let result = json["result"].string {
                    self = RecognitionNBestResult.TMP_RESULT(result)
                } else {
                    return nil
                }
            case "SOS":
                self = RecognitionNBestResult.SOS
            case "NO_DATA":
                self = RecognitionNBestResult.NO_DATA
            case "REJECT":
                self = RecognitionNBestResult.REJECT
            case "TIMEOUT":
                self = RecognitionNBestResult.TIMEOUT
            case "TOO_LONG":
                self = RecognitionNBestResult.TOO_LONG
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
}


internal extension RecognitionNBestResultObject.Word {
    
    internal init?(json: JSON) {
        if let str = json["str"].string,
            let confidence = json["confidence"].double,
            let yomi = json["yomi"].string,
            let begin = json["begin"].int,
            let end = json["end"].int
        {
            self.string = str
            self.confidence = confidence
            self.reading = yomi
            self.begin = begin
            self.end = end
        } else {
            return nil
        }
    }
    
}


internal extension RecognitionNBestResultObject {
    
    internal init?(json: JSON) {
        if let str = json["str"].string,
            let confidence = json["confidence"].double,
            let wordsJSON = json["words"].array
        {
            var words: [Word] = []
            wordsJSON.forEach({ (json) -> () in
                if let word = Word(json: json) {
                    words.append(word)
                }
            })
            
            self.string = str
            self.confidence = confidence
            self.words = words
        } else {
            return nil
        }
    }
    
}
