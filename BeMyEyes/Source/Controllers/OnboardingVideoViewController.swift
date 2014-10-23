//
//  OnboardingVideoViewController.swift
//  BeMyEyes
//
//  Created by Tobias DM on 07/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class OnboardingVideoViewController: IntroVideoViewController {

    let videoToIntroHelperSegue = "VideoToIntroHelper"
    
    var role: BMERole?
    
    override func finishedPlaying() {
        super.finishedPlaying()
        
        self.performSegueWithIdentifier(videoToIntroHelperSegue, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == videoToIntroHelperSegue {
            if let signup = segue.destinationViewController as? BMESignUpViewController {
                if let role = role {
                    signup.role = role
                }
            }
        }
    }
}