//
//  BMEBaseViewController.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

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
