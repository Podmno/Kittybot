//
//  SupporterCoreTests.swift
//  SupporterCoreTests
//
//  Created by Ki MNO on 2024/4/1.
//

import XCTest
@testable import SupporterCore

class SupporterCoreTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
    }
    
    func testFLManager() throws {
        //let manager = DLManager()
        //manager.logParser("[download] 100% of  215.78KiB in 00:00:00 at 3.69MiB/s ")
        let manager = DLManager()
        manager.setupTask(task: DLManagerTask())
        manager.parseFileName("New ouput: [download] Destination: /Users/kimno/Downloads/【FF14】老主顾-阿梅莉安丝……欸，真的是她吗？ [BV1Km411r74P].f30032.mp4")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
