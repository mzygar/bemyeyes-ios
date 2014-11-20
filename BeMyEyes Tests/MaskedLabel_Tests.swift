//
//  MaskedLabel_Tests.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 27/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit
import XCTest

class MaskedLabel_Tests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
//        recordMode = true
    }

    override func tearDown() {
        super.tearDown()
    }

    func testMaskedLabel() {
        let label = MaskedLabel()
        label.text = "Masked Label"
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 44)
        verifyView(label, identifier: "MaskedLabel")
    }
}
