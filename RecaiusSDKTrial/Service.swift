//
//  Service.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation


/// Represent error of the service.
public enum ServiceError: ErrorType {
    
    case BadRequest
    case Unauthorized
    case Forbidden
    case NotFound
    case ServiceUnavailable
    case Unknown
    
    
    public var domain: String {
        return "jp.co.flect.RecaiusSDKTrial"
    }
    
    public var code: Int {
        switch self {
        case .BadRequest:
            return 400
        case .Unauthorized:
            return 401
        case .Forbidden:
            return 403
        case .NotFound:
            return 404
        case .ServiceUnavailable:
            return 503
        case .Unknown:
            return 999
        }
    }
    
    public var error: NSError {
        return NSError(domain: self.domain, code: self.code, userInfo: nil)
    }
    
}


/// Configuration of service.
public struct ServiceConfiguration {

    public let id: String
    public let password: String
    
    
    public init(id: String, password: String) {
        self.id = id
        self.password = password
    }
    
}


public class Service {

    internal static var configuration = ServiceConfiguration(id: "", password: "")
    
    
    public static func configure(configuration: ServiceConfiguration) {
        Service.configuration = configuration
    }

}
