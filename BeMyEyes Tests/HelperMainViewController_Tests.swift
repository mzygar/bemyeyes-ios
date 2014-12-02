//
//  HelperMainViewController_Tests.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 27/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit
import XCTest

class HelperMainViewController_Tests: FBSnapshotTestCase {
    
    var helperVC: BMEHelperMainViewController?
    
    override func setUp() {
        super.setUp()
        recordMode = false
        
        helperVC = UIApplication.sharedApplication().keyWindow?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(BMEMainHelperControllerIdentifier) as? BMEHelperMainViewController
        helperVC?.viewDidLoad()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnAllDevices() {
        if let helperVC = helperVC {
            helperVC.user = BMEUser.idealUser()
            helperVC.stats = BMECommunityStats.idealStats()
        }
        verifyViewOnAllDevices(helperVC!.view)
    }
    
    func testCreatePromoScreenshots() {
        if let helperVC = helperVC {
            helperVC.user = BMEUser.idealUser()
            helperVC.stats = BMECommunityStats.idealStats()
        }
        verifyViewForPromoScreenshots(helperVC!.view)
    }
}
