//
//  ClientTest.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 18/11/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit
import XCTest

class ClientTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func newUser() -> (email: String, firstName: String, lastName: String, password: String, role: BMERole) {
        let email = "iOSAppTest_" + String.random() + "@tt.com"
        let firstName = "iOS App"
        let lastName = "Tester"
        let password = "12345678"
        let role = BMERole.Blind
        return (email, firstName, lastName, password, role)
    }
    
    func testSignup() {
        let expectation = expectationWithDescription("Signup")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { (success, error) in
            expectation.fulfill()
            XCTAssert(success, "Failed sign up")
            if let error = error {
                XCTAssert(success, "...with error: " + error.localizedDescription)
            }
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testLogin() {
        let expectation = expectationWithDescription("Login")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { (success, error) in
            BMEClient.sharedClient().loginWithEmail(email, password: password, deviceToken: nil, success: { (token) -> Void in
                expectation.fulfill()
                }, failure: { (error) -> Void in
                    XCTFail("Failed log in: " + error.localizedDescription)
                    expectation.fulfill()
            })
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testInsertDeviceToken() {
        let expectation = expectationWithDescription("Insert token")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { (success, error) in
            
            let newToken = "adfjsk234hj432k23j"
            BMEClient.sharedClient().upsertDeviceWithNewToken(newToken, currentToken: nil, production: false, completion: { (success, error) in
                expectation.fulfill()
                XCTAssert(success, "Failed insert")
                if let error = error {
                    XCTAssert(success, "...with error: " + error.localizedDescription)
                }
            })
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }

}


extension String {
    
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
    
    static func random(length: Int = 6) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let lettersLength = countElements(letters)
        var randomString = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(lettersLength)))
            let letter = letters[index]
            randomString += letter
        }
        println(randomString)
        return randomString
    }
}
