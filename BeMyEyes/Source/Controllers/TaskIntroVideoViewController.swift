//
//  TaskIntroVideoViewController.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 22/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class TaskIntroVideoViewController: IntroVideoViewController {

    override func finishedPlaying() {
        super.finishedPlaying()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
