//
//  FrontPageViewController_Tests.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 02/01/15.
//  Copyright (c) 2015 Be My Eyes. All rights reserved.
//

import UIKit
import XCTest

class FrontPageViewController_Tests: FBSnapshotTestCase {
        
    var frontPageVC: BMEFrontPageViewController?

    override func setUp() {
        super.setUp()
//        recordMode = true
        renderAsLayer = true
        
        frontPageVC = UIApplication.sharedApplication().keyWindow?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(BMEFrontPageControllerIdentifier) as? BMEFrontPageViewController
        frontPageVC?.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnAllDevices() {
        verifyViewOnAllDevicesAndLanguages(frontPageVC!)
    }
}
