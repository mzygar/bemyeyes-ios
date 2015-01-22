//
//  DemoCallViewController.swift
//  BeMyEyes
//
//  Created by Simon Støvring on 22/01/15.
//  Copyright (c) 2015 Be My Eyes. All rights reserved.
//

import UIKit

class DemoCallViewController: BMEBaseViewController {

	let DemoCallFireNotificationAfterSeconds: NSTimeInterval = 2
	
	// MARK: - Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didAnswerDemoCall:"), name: BMEDidAnswerDemoCallNotification, object: nil)
    }
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		UIApplication.sharedApplication().cancelAllLocalNotifications()
	}
	
	// MARK: - Public methods
	
	class func NotificationIsDemoKey() -> String {
		return "BMEIsDemo"
	}
	
	// MARK: - Private methods
	
	@IBAction func cancelButtonPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	internal func didEnterBackground(notification: NSNotification) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("willEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
		
		let blindName = MKLocalizedFromTable("POST_CALL_VIEW_CONTROLLER_BLIND_NAME", "DemoCallLocalizationTable")
		let fireDate = NSDate().dateByAddingTimeInterval(DemoCallFireNotificationAfterSeconds)
		let notification = UILocalNotification()
		notification.fireDate = fireDate
		notification.alertBody = NSString(format: MKLocalized("PUSH_NOTIFICATION_ANSWER_REQUEST_MESSAGE"), "Someone")
		notification.userInfo = [ DemoCallViewController.NotificationIsDemoKey(): true ]
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	internal func willEnterForeground(notification: NSNotification) {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
		UIApplication.sharedApplication().cancelAllLocalNotifications()
	}
	
	internal func didAnswerDemoCall(notification: NSNotification) {
		NSLog("Did answer demo call")
	}
}
