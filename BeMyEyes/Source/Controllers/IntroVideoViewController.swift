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
        super.viewDidLoad()
        let isIpad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        moviePlayerController.scalingMode = isIpad ? .AspectFit : .AspectFill
        if let videoPath = NSBundle.mainBundle().pathForResource("intro", ofType: "mp4") {
            let videoUrl = NSURL(fileURLWithPath: videoPath)
            moviePlayerController.contentURL = videoUrl
            moviePlayerController.play()
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        navigationController?.popViewControllerAnimated(false)
        return true
    }
}
