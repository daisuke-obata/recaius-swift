//
//  Common.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire


internal extension ServiceError {
    
    internal init?(error: NSError) {
        if error.domain != "jp.co.flect.VoiceProsessingServiceError" {
            return nil
        }
        self = ServiceError.init(code: error.code)
    }
    
    internal init(code: Int) {
        switch code {
        case 400:
            self = ServiceError.BadRequest
        case 401:
            self = ServiceError.Unauthorized
        case 403:
            self = ServiceError.Forbidden
        case 404:
            self = ServiceError.NotFound
        case 503:
            self = ServiceError.ServiceUnavailable
        default:
            self = ServiceError.Unknown
        }
    }
    
}


internal func responseErrorHandling(
    request: NSURLRequest?,
    _ response: NSHTTPURLResponse?,
      _ data: NSData?,
        _ error: NSError?
    ) -> Result<NSData, NSError> {
    if let error = error {
        return .Failure(error)
    }
    
    guard let validResponse = response else {
        return .Failure(ServiceError.Unknown.error)
    }
    
    switch validResponse.statusCode {
    case 400:
        return .Failure(ServiceError.BadRequest.error)
    case 401:
        return .Failure(ServiceError.Unauthorized.error)
    case 403:
        return .Failure(ServiceError.Forbidden.error)
    case 404:
        return .Failure(ServiceError.NotFound.error)
    case 503:
        return .Failure(ServiceError.ServiceUnavailable.error)
    default:
        if validResponse.statusCode >= 400 {
            return .Failure(ServiceError.Unknown.error)
        } else {
            if let data = data {
                return .Success(data)
            } else {
                return .Success(NSData())
            }
        }
    }
}


internal extension Request {
    
    internal static func UUIDResponseSerializer() -> ResponseSerializer<NSUUID, NSError> {
        return ResponseSerializer { request, response, data, error in
            switch responseErrorHandling(request, response, data, error) {
            case .Success(let data):
                let UUIDString = NSString(data: data, encoding: NSUTF8StringEncoding) as? String
                if let UUID = UUIDString.flatMap({ NSUUID(UUIDString: $0) }) {
                    return .Success(UUID)
                } else {
                    return .Failure(ServiceError.Unknown.error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
    
    internal func responseUUID(completionHandler: Response<NSUUID, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.UUIDResponseSerializer(), completionHandler: completionHandler)
    }
    
}
