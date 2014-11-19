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
                XCTFail("...with error: " + error.localizedDescription)
            }
            let user = BMEClient.sharedClient().currentUser
            XCTAssert(user != nil, "No current user")
            XCTAssert(user.email == email, "Wrong email")
            XCTAssert(user.firstName == firstName, "Wrong first name")
            XCTAssert(user.lastName == lastName, "Wrong last name")
            XCTAssert(user.role == role, "Wrong role")
            let token = BMEClient.sharedClient().token()
            XCTAssert(token != nil, "No token")
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testLogin() {
        let expectation = expectationWithDescription("Login")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { (success, error) in
            BMEClient.sharedClient().loginWithEmail(email, password: password, deviceToken: nil, success: { token in
                expectation.fulfill()
                let user = BMEClient.sharedClient().currentUser
                XCTAssert(user != nil, "No current user")
                XCTAssert(user.email == email, "Wrong email")
                XCTAssert(user.firstName == firstName, "Wrong first name")
                XCTAssert(user.lastName == lastName, "Wrong last name")
                XCTAssert(user.role == role, "Wrong role")
                let token = BMEClient.sharedClient().token()
                XCTAssert(token != nil, "No token")
            }, failure: { (error) -> Void in
                XCTFail("Failed log in: " + error.localizedDescription)
                expectation.fulfill()
            })
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testLogout() {
        let expectation = expectationWithDescription("Logout")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { (success, error) in
            BMEClient.sharedClient().logoutWithCompletion(){ success, error in
                expectation.fulfill()
                XCTAssert(success, "Failed log out")
                if let error = error {
                    XCTFail("...with error: " + error.localizedDescription)
                }
                let user = BMEClient.sharedClient().currentUser
                XCTAssert(user == nil, "Shouldn't have current user")
            } 
        }
        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
    func testInsertDeviceToken() {
        let expectation = expectationWithDescription("Insert token")
        let (email, firstName, lastName, password, role) = newUser()
        BMEClient.sharedClient().createUserWithEmail(email, password: password, firstName: firstName, lastName: lastName, role: role) { success, error in
            let newToken = "0f744707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bbad78"
            BMEClient.sharedClient().upsertDeviceWithNewToken(newToken, production: false, completion: { (success, error) in
                expectation.fulfill()
                XCTAssert(success, "Failed insert")
                if let error = error {
                    XCTFail("...with error: " + error.localizedDescription)
                }
                XCTAssert(GVUserDefaults.standardUserDefaults().deviceToken == newToken, "Wrong token")
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
