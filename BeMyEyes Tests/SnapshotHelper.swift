//
//  SnapshotHelper.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 27/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

struct Device {
    let bounds: CGRect
    let description: String

    static func allDevices() -> [Device] {
        return [Device(bounds: CGRect(x: 0, y: 0, width: 320, height: 480), description: "iPhone 4"),
            Device(bounds: CGRect(x: 0, y: 0, width: 320, height: 568), description: "iPhone 5"),
            Device(bounds: CGRect(x: 0, y: 0, width: 375, height: 667), description: "iPhone 6"),
            Device(bounds: CGRect(x: 0, y: 0, width: 621, height: 1104), description: "iPhone 6+"),
            Device(bounds: CGRect(x: 0, y: 0, width: 768, height: 1024), description: "iPad")]
    }
}

extension FBSnapshotTestCase {

    func verifyView(view: UIView, identifier: String) {
        var error: NSError?
        let referenceImagesDirectory = "\(FB_REFERENCE_IMAGE_DIR)"
        let comparisonSuccess = compareSnapshotOfView(view, referenceImagesDirectory: referenceImagesDirectory, identifier: identifier, error: &error)
        var str = "Snapshot comparison failed"
        if let error = error {
            str += error.localizedDescription
        }
        XCTAssertTrue(comparisonSuccess, str)
        XCTAssertFalse(recordMode, "Test ran in record mode. Reference image is now saved. Disable record mode to perform an actual snapshot comparison!");
    }

    func verifyViewOnAllDevices(view: UIView, identifier: String = "") {
        for device in Device.allDevices() {
            view.frame = device.bounds
            
            verifyView(view, identifier: identifier + device.description)
        }
    }
}
