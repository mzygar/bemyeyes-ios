//
//  IntroVideoViewController.swift
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class IntroVideoViewController: VideoViewController {

    override func viewDidLoad() {
        BMECrashlyticsLoggingSwift.log("viewDidLoad A")
        super.viewDidLoad()
        BMECrashlyticsLoggingSwift.log("viewDidLoad B")
        moviePlayerController.scalingMode = .AspectFill
        if let videoPath = NSBundle.mainBundle().pathForResource("intro", ofType: "mp4") {
            BMECrashlyticsLoggingSwift.log("viewDidLoad C")
            let videoUrl = NSURL(fileURLWithPath: videoPath)
            moviePlayerController.contentURL = videoUrl
            moviePlayerController.play()
            BMECrashlyticsLoggingSwift.log("viewDidLoad D")
            BMECrashlyticsLoggingSwift.log("viewDidLoad E \( moviePlayerController.duration)")
        }
    }
}
