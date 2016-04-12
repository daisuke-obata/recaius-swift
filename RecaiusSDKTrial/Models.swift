//
//  Models.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation


/* Synthesis Service Models */

/// Authorization information Of RECAIUS synthesis service.
public struct SynthesisServiceCredential {
    
    public let id: String
    public let password: String
    
    /// You need to use a separate user dictionary. Not required when using only the group share of the user dictionary.
    public let userName: String?
    
    
    public init(id: String, password: String, userName: String?) {
        self.id = id
        self.password = password
        self.userName = userName
    }
    
}


public typealias PlainText = String

public typealias PhoneticText = String

public typealias SynthesisUserDictionaryID = String


/// Language that can be used in the synthesizing.
public enum SynthesisLanguage {
    
    case Japanese
    case AmericanEnglish
    case MandarinChinese
    case Korean
    case French
    
    
    /// Language value that formatted like ja_JP.
    public var value: String {
        switch self {
        case .Japanese:
            return "ja_JP"
        case .AmericanEnglish:
            return "en_US"
        case .MandarinChinese:
            return "zh_CN-en_US"
        case .Korean:
            return "ko_KR"
        case .French:
            return "fr_FR"
        }
    }
    
}


/// Protocol of speaker that can be used in the synthesizing.
public protocol SynthesisSpeakerCompatible {
    
    /// Speaker ID.
    var id: String { get }
    
}


/// Speaker of Japanese.
public enum SynthesisJapaneseSpeaker: SynthesisSpeakerCompatible {
    
    case Moe
    case Sakura
    case Itaru
    case Hirito
    
    
    public var id: String {
        switch self {
        case .Moe:
            return "ja_JP-F0005-U01T"
        case .Sakura:
            return "ja_JP-F0006-C53T"
        case .Itaru:
            return "ja_JP-M0001-H00T"
        case .Hirito:
            return "ja_JP-M0002-H01T"
        }
    }
    
}


// Speaker of American English.
public enum SynthesisAmericanEnglishSpeaker: SynthesisSpeakerCompatible {
    
    case Jane
    
    
    public var id: String {
        switch self {
        case .Jane:
            return "en_US-F0001-H00T"
        }
    }
    
}


// Speaker of Mandarin Chinese.
public enum SynthesisMandarinChineseSpeaker: SynthesisSpeakerCompatible {
    
    case Linley
    
    
    public var id: String {
        switch self {
        case .Linley:
            return "zh_CN-en_US-F0002-H00T"
        }
    }
    
}


// Speaker of Korean.
public enum SynthesisKoreanSpeaker: SynthesisSpeakerCompatible {
    
    case Miyoun
    
    
    public var id: String {
        switch self {
        case .Miyoun:
            return "ko_KR-F0001-H00T"
        }
    }
    
}


// Speaker of French.
public enum SynthesisFrenchSpeaker: SynthesisSpeakerCompatible {
    
    case Nicol
    
    
    public var id: String {
        switch self {
        case .Nicol:
            return "fr_FR-F0001-H00T"
        }
    }
    
}


/// Output format of speech synthesizing.
public enum SynthesisCodec {
    
    case ADPCM(Int)
    case OGG(Int)
    case LinearPCM(Int)
    case MPEG4(Int)
    
    
    public var contentType: String {
        switch self {
        case .ADPCM:
            return "audio/wav"
        case .OGG:
            return "audio/ogg"
        case .LinearPCM:
            return "audio/x-linear"
        case .MPEG4:
            return "audio/x-m4a"
        }
    }
    
    /// Output bit rate (unit: kbps)
    public var bitRate: Int {
        switch self {
        case .ADPCM(let bitRate):
            return bitRate
        case .OGG(let bitRate):
            return bitRate
        case .LinearPCM(let bitRate):
            return bitRate
        case .MPEG4(let bitRate):
            return bitRate
        }
    }
    
}


/// Speed read aloud. The default is 0. -10 3 times slower, will be three times faster at + 10.
public typealias SynthesisParameterSpeed = Int

/// The overall height of the voice to read aloud. The default is 0. -10 At about 0.4 octave lower, higher about 0.4 octave at + 10.
public typealias SynthesisParameterPitch = Int

/// The thickness of the voice to read aloud. The default is 0. You can set in four steps in each direction to narrow direction, be thicker than standard.
public typealias SynthesisParameterDepth = Int

/// Overall volume. The default is 0. In silence at -50, it defaults to three times the volume at + 50.
public typealias SynthesisParameterVolume = Int

/// Volume of only unvoiced voice read aloud. The default is 0. In the case of the speaker of the plural unit selection and fusion method of lang = ja_JP only you can use. Volume of unvoiced to 0 at -10, it defaults to three times the volume at + 10.
public typealias SynthesisParameterUPower = Int

/// Joy of the size of the read aloud. The default is 0. In the case of the corresponding speaker only enabled.
public typealias SynthesisParameterHappy = Int

/// Anger of the size of the read aloud. The default is 0. In the case of the corresponding speaker only enabled.
public typealias SynthesisParameterAngry = Int

/// Sorrow of the size of the read aloud. The default is 0. In the case of the corresponding speaker only enabled.
public typealias SynthesisParameterSad = Int

/// Fear of magnitude read aloud. The default is 0. In the case of the corresponding speaker only enabled.
public typealias SynthesisParameterFear = Int

/// Tenderness of a size that read aloud. The default is 0. In the case of the corresponding speaker only enabled.
public typealias SynthesisParameterTender = Int


/// Common parameters of synthesizing.
public struct SynthesisCommonParameters {
    
    public let speed: SynthesisParameterSpeed
    public let pitch: SynthesisParameterPitch
    public let depth: SynthesisParameterDepth
    public let volume: SynthesisParameterVolume
    public let uPower: SynthesisParameterUPower
    
    
    public init(
        speed: SynthesisParameterSpeed,
        pitch: SynthesisParameterPitch,
        depth: SynthesisParameterDepth,
        volume: SynthesisParameterVolume,
        uPower: SynthesisParameterUPower)
    {
        self.speed = speed
        self.pitch = pitch
        self.depth = depth
        self.volume = volume
        self.uPower = uPower
    }
    
}


/// Eotion parameters of synthesizing.
public struct SynthesisEmotionParameters {
    
    public let happy: SynthesisParameterHappy
    public let angry: SynthesisParameterAngry
    public let sad: SynthesisParameterAngry
    public let fear: SynthesisParameterFear
    public let tender: SynthesisParameterTender
    
    
    public init(
        happy: SynthesisParameterHappy,
        angry: SynthesisParameterAngry,
        sad: SynthesisParameterSad,
        fear: SynthesisParameterFear,
        tender: SynthesisParameterTender)
    {
        self.happy = happy
        self.angry = angry
        self.sad = sad
        self.fear = fear
        self.tender = tender
    }
    
}


/// Setting of whether to tab mode.
public enum TagModeSetting {
    
    case Active
    case Deactive
    
}


/**
 Setting of how to read the numbers.
 
 + Digest: Read the numbers as digits.
 + OneByOne: Read the number as one by one.
 */

public enum ReadDigitSetting {
    
    case Digit
    case OneByOne
    
}


/// Setting of how to read the synbols. Available only Japanese.
public enum ReadSymbolSetting {
    
    case Ignore
    case Read
    
}


/// Setting of how to read the alphabets. Available only Japanese.
public enum ReadAlphabetSetting {
    
    case JapaneseEnglish
    case Alphabet
    
}


/* Recognition Service Models */

/// Authorization information Of RECAIUS recognition service.
public struct RecognitionServiceCredential {
    
    public let id: String
    public let password: String
    
    public init(id: String, password: String) {
        self.id = id
        self.password = password
    }
    
}


/// It specifies the level of volume to determine the voice. Specify up to 0 to 1000.
public typealias EnergyThreshold = Int


/// The type of recognition result.
public enum RecognitionResultType {
    
    case NBest(Int)
    case OneBest
    case Confnet(Int)
    
    
    /// The number of candidates of the recognition result can be obtained.
    public var count: Int? {
        switch self {
        case .NBest(let count):
            return count
        default:
            return nil
        }
    }
    
}


/// The format of the recognization voice data.
public enum RecognitionAudioType {
    
    case LinearPCM
    case ADPCM
    case Speex
    
    
    public var contentType: String {
        switch self {
        case .LinearPCM:
            return "audio/x-linear"
        case .ADPCM:
            return "audio/x-adpcm"
        case .Speex:
            return "audio/speex"
        }
    }
    
    
    /// Init with string of ContentType.
    public init?(contentType: String) {
        switch contentType {
        case "audio/x-linear":
            self = RecognitionAudioType.LinearPCM
        case "audio/x-adpcm":
            self = RecognitionAudioType.ADPCM
        case "audio/speex":
            self = RecognitionAudioType.Speex
        default:
            return nil
        }
    }
    
}


/// Protocol of recognization model.
public protocol RecognitionModelCompatible {
    
    var id: Int { get }
    
}


/// Base of the model when registering the user word dictionary. In addition, it can also be used as a model to be used for recognition.
public enum BaseRecognitionModel: RecognitionModelCompatible {
    
    case Japanese
    case AmericanEnglish
    case MandarinChinese
    
    
    public var id: Int {
        switch self {
        case .Japanese:
            return 1
        case .AmericanEnglish:
            return 5
        case .MandarinChinese:
            return 7
        }
    }
    
}


/// Setting of whether to Push-to-Talk mode.
public enum PushToTalkSetting {
    
    case Active
    case Deactive
    
}


/// Setting of whether to save the recognized voice data.
public enum DataLogSetting {
    
    case Active(String)
    case Deactive
    
    
    /// The comment to be applied to the voice data to be saved on the server.
    public var comment: String? {
        switch self {
        case .Active(let comment):
            return comment
        case .Deactive:
            return nil
        }
    }
    
}


/// Recognization result of nbest format.
public enum RecognitionNBestResult {
    
    case RESULT([RecognitionNBestResultObject])
    case TMP_RESULT(String)
    case SOS
    case NO_DATA
    case REJECT
    case TIMEOUT
    case TOO_LONG
    
}


/// Object that type of speech recognition result of nbest format contains at the time of the RESULT.
public struct RecognitionNBestResultObject {
    
    public struct Word {
        
        public let string: String
        public let confidence: Double
        public let reading: String
        public let begin: Int
        public let end: Int
        
    }
    
    
    public let string: String
    public let confidence: Double
    public let words: [Word]
    
}
