//
//  RecognitionNBestResutlResponseSerializer.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON


internal extension Request {
    
    internal static func RecognitionNBestResutlResponseSerializer() -> ResponseSerializer<[RecognitionNBestResult], NSError> {
        return ResponseSerializer { request, response, data, error in
            switch responseErrorHandling(request, response, data, error) {
            case .Success(let data):
                if response.flatMap({ $0.statusCode }) == 204 {
                    return .Success([])
                } else {
                    let json = JSON(data: data)
                    
                    if json.isEmpty {
                        return .Success([])
                    } else if let arrayOfJSON = json.array {
                        var results: [RecognitionNBestResult] = []
                        arrayOfJSON.forEach({ (json) -> () in
                            if let result = RecognitionNBestResult(json: json) {
                                results.append(result)
                            }
                        })
                        
                        return .Success(results)
                    } else {
                        return .Failure(ServiceError.Unknown.error)
                    }
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
    }
    
    internal func responseRecognitionNBestResult(completionHandler: Response<[RecognitionNBestResult], NSError> -> Void) -> Self {
        return response(responseSerializer: Request.RecognitionNBestResutlResponseSerializer(), completionHandler: completionHandler)
    }
    
}