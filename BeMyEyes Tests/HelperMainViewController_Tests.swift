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
//        recordMode = true
        renderAsLayer = true
        
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
        verifyViewOnAllDevicesAndLanguages(helperVC!)
    }
    
    func testCreatePromoScreenshots() {
        if let helperVC = helperVC {
            helperVC.user = BMEUser.idealUser()
            helperVC.stats = BMECommunityStats.idealStats()
        }
        verifyViewForPromoScreenshots(helperVC!.view)
    }
    
    func testStats() {
        if let helperVC = helperVC {
            helperVC.user = BMEUser.idealUser()
            var stats = BMECommunityStats()
            stats.sighted = 10432 // 10,432
            stats.blind = 595 // 595
            stats.helped = 2020000 // 2,020,000
            helperVC.stats = stats
        }
        verifyViewOnAllDevices(helperVC!.view)
    }
}
