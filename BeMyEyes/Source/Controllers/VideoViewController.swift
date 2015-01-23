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

class VideoViewController: BaseViewController {
    
    @IBOutlet weak var doneButton: UIButton?
    
    lazy var moviePlayerController: MPMoviePlayerController = {
        let moviePlayerController = MPMoviePlayerController()
        moviePlayerController.controlStyle = .None
        return moviePlayerController
    }()
    
    var didFinishPlaying: (() -> ())?
    
    let defaultAudioCategory = AVAudioSession.sharedInstance().category
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let movieView = moviePlayerController.view {
            movieView.frame = view.bounds
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ignoreMuteSwitch()
        if moviePlayerController.playbackState != .Playing {
            moviePlayerController.play()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishedPlaying", name:  MPMoviePlayerPlaybackDidFinishNotification, object: nil)
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
