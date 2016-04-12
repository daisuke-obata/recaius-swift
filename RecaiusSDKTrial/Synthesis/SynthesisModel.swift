//
//  SynthesisModel.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation


internal extension TagModeSetting {
    
    internal var int: Int {
        switch self {
        case .Active:
            return 1
        case .Deactive:
            return 0
        }
    }
    
}


internal extension ReadDigitSetting {
    
    internal var int: Int {
        switch self {
        case .Digit:
            return 0
        case .OneByOne:
            return 1
        }
    }
    
}


internal extension ReadSymbolSetting {
    
    internal var int: Int {
        switch self {
        case .Ignore:
            return 0
        case .Read:
            return 1
        }
    }
    
}


internal extension ReadAlphabetSetting {
    
    internal var int: Int {
        switch self {
        case .JapaneseEnglish:
            return 0
        case .Alphabet:
            return 1
        }
    }
    
}


internal extension SynthesisCodec {
    
    internal var fileNameExtension: String {
        switch self {
        case .ADPCM(_):
            return "wav"
        case .OGG(_):
            return "ogg"
        case .LinearPCM(_):
            return "wav"
        case .MPEG4(_):
            return "m4a"
        }
    }
    
}
