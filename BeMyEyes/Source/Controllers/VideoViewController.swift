//
//  VideoViewController.swift
//  BeMyEyes
//
//  Created by Tobias DM on 07/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class VideoViewController: BMEBaseViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    lazy var moviePlayerController: MPMoviePlayerController = {
        BMECrashlyticsLoggingSwift.log("moviePlayerController 1")
        let moviePlayerController = MPMoviePlayerController()
        moviePlayerController.controlStyle = .None
        return moviePlayerController
    }()
    
    var didFinishPlaying: (() -> ())?
    
    let defaultAudioCategory = AVAudioSession.sharedInstance().category
    
    override func viewDidLoad() {
        BMECrashlyticsLoggingSwift.log("viewDidLoad 1")
//        super.viewDidLoad() Don't call super.viewDidLoad(), to avoid crash issue on shipped builds
        BMECrashlyticsLoggingSwift.log("viewDidLoad 2")
        if let movieView = moviePlayerController.view {
            BMECrashlyticsLoggingSwift.log("viewDidLoad 3")
            view.insertSubview(movieView, belowSubview: doneButton)
            BMECrashlyticsLoggingSwift.log("viewDidLoad 4")
        }
    }
    
    override func viewDidLayoutSubviews() {
        BMECrashlyticsLoggingSwift.log("viewDidLayoutSubviews 1")
        super.viewDidLayoutSubviews()
        BMECrashlyticsLoggingSwift.log("viewDidLayoutSubviews 2")
        if let movieView = moviePlayerController.view {
            BMECrashlyticsLoggingSwift.log("viewDidLayoutSubviews 3")
            movieView.frame = view.bounds
            BMECrashlyticsLoggingSwift.log("viewDidLayoutSubviews 4")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        BMECrashlyticsLoggingSwift.log("viewDidAppear 1")
        super.viewDidAppear(animated)
        BMECrashlyticsLoggingSwift.log("viewDidAppear 2")
        ignoreMuteSwitch()
        BMECrashlyticsLoggingSwift.log("viewDidAppear 3")
        if moviePlayerController.playbackState != .Playing {
            BMECrashlyticsLoggingSwift.log("viewDidAppear 4")
            moviePlayerController.play()
        }
        BMECrashlyticsLoggingSwift.log("viewDidAppear 5")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedPlaying", name:  MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        BMECrashlyticsLoggingSwift.log("viewDidAppear 6")
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self) // Don't call finishedPlaying()
        moviePlayerController.stop()
        resetAudioCategory()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension VideoViewController {
    
    func finishedPlaying() {
        if let didFinishPlaying = didFinishPlaying {
            didFinishPlaying()
        }
    }
    
    func ignoreMuteSwitch() {
        self.useAudioCategory(AVAudioSessionCategoryPlayback)
    }
    
    func resetAudioCategory() {
        self.useAudioCategory(defaultAudioCategory)
    }
    
    func useAudioCategory(audioCategory: String) {
        var error: NSError? = nil
        let success = AVAudioSession.sharedInstance().setCategory(audioCategory, error: &error)
        if !success {
            if let error = error {
                println("Could not set audio category to '%@': %@", audioCategory, error)
            }
        }
    }
}
