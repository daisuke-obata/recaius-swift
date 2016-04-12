//
//  RecognitionAPI.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures


internal struct RecognitionAPIClient {
    
    internal static func login(credential: RecognitionServiceCredential, setting: RecognitionSetting) -> Future<NSUUID, ServiceError> {
        let promise = Promise<NSUUID, ServiceError>()
        
        let params = RecognitionAPI.LoginParameters(credential: credential, setting: setting)
        
        request(RecognitionAPI.Login(params))
            .responseUUID { (response) -> Void in
                switch response.result {
                case .Success(let UUID):
                    promise.success(UUID)
                case .Failure(let error):
                    promise.failure(ServiceError(code: error.code))
                }
        }
        
        return promise.future
    }
    
    
    internal static func logout(UUID: NSUUID) -> Future<Bool, ServiceError> {
        let promise = Promise<Bool, ServiceError>()
        
        let params = RecognitionAPI.LogoutParameters(UUID: UUID)
        
        request(RecognitionAPI.Logout(params))
            .response { (request, response, data, error) -> Void in
                switch responseErrorHandling(request, response, data, error) {
                case .Success(_):
                    promise.success(true)
                case .Failure(let error):
                    promise.failure(ServiceError(code: error.code))
                }
        }
        
        return promise.future
    }
    
    internal static func putVoice(UUID: NSUUID, voiceID: Int, voice: NSData) -> Future<[RecognitionNBestResult], ServiceError> {
        let promise = Promise<[RecognitionNBestResult], ServiceError>()
        
        let params = RecognitionAPI.PutVoiceParameters(UUID: UUID, voiceID: voiceID, voice: voice)
        
        request(RecognitionAPI.PutVoice(params))
            .responseRecognitionNBestResult { (response) -> Void in
                switch response.result {
                case .Success(let results):
                    promise.success(results)
                case .Failure(let error):
                    promise.failure(ServiceError(code: error.code))
                }
        }
        
        return promise.future
    }
    
    internal static func getResult(UUID: NSUUID) -> Future<[RecognitionNBestResult], ServiceError> {
        let promise = Promise<[RecognitionNBestResult], ServiceError>()
        
        let params = RecognitionAPI.GetResultParameters(UUID: UUID)
        
        request(RecognitionAPI.GetResult(params))
            .responseRecognitionNBestResult { (response) -> Void in
                switch response.result {
                case .Success(let results):
                    promise.success(results)
                case .Failure(let error):
                    promise.failure(ServiceError(code: error.code))
                }
        }
        
        return promise.future
    }
    
}


internal enum RecognitionAPI: URLRequestConvertible {
    
    internal struct LoginParameters {
        
        internal let credential: RecognitionServiceCredential
        internal let setting: RecognitionSetting
        
    }
    
    internal struct LogoutParameters {
        
        internal let UUID: NSUUID
        
    }
    
    internal struct PutVoiceParameters {
        
        internal let UUID: NSUUID
        internal let voiceID: Int
        internal let voice: NSData
        
    }
    
    internal struct GetResultParameters {
        
        internal let UUID: NSUUID
        
    }
    
    
    
    internal static let baseURLString = "https://try-api.recaius.jp/asr/v1"
    
    case Login(LoginParameters)
    case Logout(LogoutParameters)
    case PutVoice(PutVoiceParameters)
    case GetResult(GetResultParameters)
    
    
    internal var method: Alamofire.Method {
        switch self {
        case .Login(_):
            return .POST
        case .Logout(_):
            return .POST
        case .PutVoice(_):
            return .PUT
        case .GetResult(_):
            return .GET
        }
    }
    
    internal var path: String {
        switch self {
        case .Login(_):
            return "/login"
        case .Logout(let parameters):
            return "/\(parameters.UUID.UUIDString.lowercaseString)/logout"
        case .PutVoice(let parameters):
            return "/\(parameters.UUID.UUIDString.lowercaseString)/voice"
        case .GetResult(let parameters):
            return "/\(parameters.UUID.UUIDString.lowercaseString)/result"
        }
    }
    
    
    // MARK: - URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: RecognitionAPI.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .Login(let parameters):
            let body: [String: AnyObject] = [
                "id": parameters.credential.id,
                "password": parameters.credential.password,
                "model": parameters.setting.toDictionary()
            ]
            
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: body).0
        case .PutVoice(let parameters):
            let boundary = "---------------------------\(NSUUID().UUIDString)"
            let body = NSMutableData()
            
            var tempString: String
            
            tempString = ""
            tempString += "--\(boundary)\r\n"
            tempString += "Content-Disposition: form-data; name=\"voiceid\";\r\n"
            tempString += "\r\n"
            
            tempString += String(parameters.voiceID)
            tempString += "\r\n"
            body.appendData(tempString.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            tempString = ""
            tempString += "--\(boundary)\r\n"
            tempString += "Content-Disposition: form-data; name=\"voice\"; filename=\"test.wav\"\r\n"
            tempString += "Content-Type: application/octet-stream\r\n"
            tempString += "\r\n"
            body.appendData(tempString.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            body.appendData(parameters.voice)
            
            tempString = ""
            tempString += "\r\n"
            tempString += "--\(boundary)--\r\n"
            body.appendData(tempString.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            mutableURLRequest.HTTPBody = body
            mutableURLRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            mutableURLRequest.addValue(String(body.length), forHTTPHeaderField: "Content-Length")
            
            return mutableURLRequest
        default:
            return mutableURLRequest
        }
    }
    
}
