//
//  RecaiusSDKTrialTests.swift
//  RecaiusSDKTrialTests
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import XCTest
@testable import RecaiusSDKTrial

class RecaiusSDKTrialTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let configuration = ServiceConfiguration(
            id: "YOUR SERVICE ID", password: "YOUR SERVICE PASSWORD")
        Service.configure(configuration)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSynthesizeJapanese() {
        let expectation = expectationWithDescription("Synthesize japanese test.")
        
        synthesizeJapanese("テスト", speaker: .Sakura)
        .onSuccess { item in
            expectation.fulfill()
        }.onFailure { error in
            XCTAssert(false)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
    func testRecognizeJapanese() {
        let expectation = expectationWithDescription("Recognize japanese test.")
        
        let URLString = NSBundle(forClass: self.dynamicType).pathForResource("test", ofType: "wav")
        let URL = NSURL(string: URLString!)!
        
        recognizeJapanese(URL, audioType: .LinearPCM, threshold: 300, resultCount: 3)
        .onSuccess { results in
            debugPrint(results)
            expectation.fulfill()
        }.onFailure { error in
            XCTAssert(false)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}
