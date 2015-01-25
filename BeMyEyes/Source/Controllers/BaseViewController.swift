//
//  BMEBaseViewController.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

/** 
    Similar functionality as BMEBaseViewController. Reason for duplicating functionality in a swift version is to avoid a bug in .viewDidLoad. Here super.viewDidLoad() actually calls subclass instead of super, when the app runs in release mode.
*/
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        // Don't call super.viewDidLoad(), to avoid crash issue on shipped builds
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        let isIpad = UIDevice.currentDevice().userInterfaceIdiom == .Pad;
        return Int((isIpad ? UIInterfaceOrientationMask.All : .Portrait).rawValue);
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Fade
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    @IBAction func backButtonPressed(AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
