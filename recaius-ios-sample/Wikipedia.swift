//
//  Wikipedia.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation

import Alamofire
import BrightFutures
import SwiftyJSON


internal class Wikipedia {

    internal static func getExtract(title: String) -> Future<String?, NSError> {
        
        let promise = Promise<String?, NSError>()
        
        
        if let URL = NSURL(string: "https://ja.wikipedia.org/w/api.php") {
            
            let params: [String: AnyObject] = [
                "action": "query",
                "prop": "extracts|info",
                "format": "json",
                "exintro": true,
                "explaintext": true,
                "inprop": "url",
                "redirects": true,
                "converttitles": true,
                "titles": title
            ]
            
            request(.GET, URL, parameters: params)
                .responseJSON { response in
                    switch response.result {
                    case .Success(let data):
                        let json = JSON(data)
                        
                        var extract: String? = nil
                        if let pages = json["query"]["pages"].dictionary {
                            for (_, subJson): (String, JSON) in pages {
                                extract = subJson["extract"].string
                            }
                        }
                        
                        promise.success(extract)
                    case .Failure(let error):
                        promise.failure(error)
                    }
            }
            
        } else {
            promise.failure(NSError(domain: "", code: 0, userInfo: nil))
            
        }
        
        
        return promise.future
    }

}
