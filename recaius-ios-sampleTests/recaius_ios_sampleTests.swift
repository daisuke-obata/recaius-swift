//
//  recaius_ios_sampleTests.swift
//  recaius-ios-sampleTests
//
//  Created by Miyake Akira on 2016/03/25.
//  Copyright © 2016年 Miyake Akira. All rights reserved.
//

import XCTest
@testable import recaius_ios_sample

class recaius_ios_sampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWikipediaGetExtract() {
        let expectation = expectationWithDescription("Get iPhone extract wiht Wikipedia API")
        
        Wikipedia.getExtract("アイフォーン")
        .onSuccess { extract in
            debugPrint(extract)
            expectation.fulfill()
        }.onFailure { error in
            XCTAssert(false)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)
    }
    
}
