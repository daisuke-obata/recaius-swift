//
//  AudioDataProcessing.swift
//  recaius-ios-sample
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import Foundation
import AudioToolbox


internal struct FileURLAudioDataProcessor {
    
    internal let URL: NSURL
    internal let data: NSData
    
    internal init?(URL: NSURL) {
        self.URL = URL
        
        var error: OSStatus = noErr
        var propertySize: UInt32 = 0
        
        var audioFileID: AudioFileID = nil
        var fileFormat = AudioStreamBasicDescription()
        var fileDataSize: UInt64 = 0
        var audioData: UnsafeMutablePointer<Byte>
        
        // Get audil file id.
        error = AudioFileOpenURL(URL, .ReadPermission, 0, &audioFileID)
        if error != noErr {
            return nil
        }
        
        // Property size of AudioStreamBasicDescription Type.
        propertySize = UInt32(strideofValue(fileFormat))
        
        // Get filet format.
        error = AudioFileGetProperty(audioFileID, kAudioFilePropertyDataFormat, &propertySize, &fileFormat)
        if error != noErr {
            return nil
        }
        
        // Get property size from fileDataSize.
        propertySize = UInt32(sizeofValue(fileDataSize))
        
        // Get file data size.
        error = AudioFileGetProperty(audioFileID, kAudioFilePropertyAudioDataByteCount, &propertySize, &fileDataSize)
        if error != noErr {
            return nil
        }
        
        // Get count of bytes from file data size.
        var countOfBytes = UInt32(fileDataSize);
        
        // Get audio data.
        audioData = UnsafeMutablePointer<Byte>.alloc(Int(countOfBytes))
        error = AudioFileReadBytes(audioFileID, false, 0, &countOfBytes, audioData)
        if error != noErr {
            AudioFileClose(audioFileID)
            return nil
        } else {
            self.data = NSData(bytes: audioData, length: Int(fileDataSize))
            audioData.dealloc(Int(countOfBytes))
            audioData = nil
            
            AudioFileClose(audioFileID)
        }
        
    }
    
    func getArrayOfData(intervalLength: Int) -> [NSData] {
        var arrayOfData: [NSData] = []
        let dataLength = data.length
        
        for i in 0..<(dataLength / intervalLength) {
            var bytes: UnsafeMutablePointer<Byte>
            
            let range = NSRange.init(location: intervalLength * i, length: intervalLength)
            
            bytes = UnsafeMutablePointer<Byte>.alloc(intervalLength)
            data.getBytes(bytes, range: range)
            
            let byteData = NSData(bytes: bytes, length: intervalLength)
            arrayOfData.append(byteData)
            
            bytes.dealloc(intervalLength)
        }
        
        return arrayOfData
    }
    
}
