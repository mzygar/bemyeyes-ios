//
//  PostCallViewController.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 28/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

class PostCallViewController: BMEBaseViewController, MKLocalizable {
    
    var requestIdentifier: String?
    private let reportAbuseSegue = "ReportAbuse"
    var user: BMEUser? = BMEClient.sharedClient().currentUser
    
	@IBOutlet weak var shareButton: Button!
    @IBOutlet weak var okButton: Button!
    @IBOutlet weak var reportAbuseButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MKLocalization.registerForLocalization(self)
    }
    
    func shouldLocalize() {
        
        if let role = user?.role {
            let messageKey: String = {
                switch role {
                    case .Blind:
                        return "POST_CALL_VIEW_CONTROLLER_MOTIVATIONAL_MESSAGE_BLIND"
                    case .Helper:
                        return "POST_CALL_VIEW_CONTROLLER_MOTIVATIONAL_MESSAGE_HELPER"
                }
            }()
            messageLabel.text = MKLocalizedFromTable(messageKey, "PostCallLocalizationTable")
			
			let (okButtonKey, shareButtonKey): (String, String) = {
                switch role {
                    case .Blind:
						return ("POST_CALL_VIEW_CONTROLLER_DISMISS_BUTTON_BLIND", "POST_CALL_VIEW_CONTROLLER_SHARE_BUTTON_BLIND")
                    case .Helper:
						return ("POST_CALL_VIEW_CONTROLLER_DISMISS_BUTTON_HELPER", "POST_CALL_VIEW_CONTROLLER_SHARE_BUTTON_HELPER")
                }
            }()
			
            okButton.title = MKLocalizedFromTable(okButtonKey, "PostCallLocalizationTable")
			shareButton.title = MKLocalizedFromTable(shareButtonKey, "PostCallLocalizationTable")
        }
        
        reportAbuseButton.setTitle(MKLocalizedFromTable("POST_CALL_VIEW_CONTROLLER_REPORT_ABUSE", "PostCallLocalizationTable"), forState: .Normal)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == reportAbuseSegue {
            if let vc = segue.destinationViewController as? BMEReportAbuseViewController {
                vc.requestIdentifier = self.requestIdentifier!
            }
        }
    }
    
	@IBAction func didTapShareButton(sender: AnyObject) {
		if let role = user?.role {
			let (fbMessageKey, twitterMessageKey, defaultMessageKey): (String, String, String) = {
				switch role {
				case .Blind:
					return (
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_FACEBOOK_BLIND",
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_TWITTER_BLIND",
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_DEFAULT_BLIND")
				case .Helper:
					return (
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_FACEBOOK_HELPER",
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_TWITTER_HELPER",
						"POST_CALL_VIEW_CONTROLLER_SHARE_MESSAGE_DEFAULT_HELPER")
				}
			}()
			
			let fbMessage = MKLocalizedFromTable(fbMessageKey, "PostCallLocalizationTable")
			let twitterMessage = MKLocalizedFromTable(twitterMessageKey, "PostCallLocalizationTable")
			let defaultMessage = MKLocalizedFromTable(defaultMessageKey, "PostCallLocalizationTable")
			let messageProvider = SocialTextProvider(facebookText: fbMessage, twitterText: twitterMessage, defaultText: defaultMessage)
			let url = NSURL(string: "https://itunes.apple.com/app/id" + BMEAppStoreId)!
			let controller = UIActivityViewController(activityItems: [ messageProvider, url ], applicationActivities: nil)
			if UIDevice.isiPad() && controller.respondsToSelector(Selector("popoverPresentationController")) {
				controller.popoverPresentationController?.sourceView = view
				controller.popoverPresentationController?.sourceRect = shareButton.frame
			}
			presentViewController(controller, animated: true, completion: nil)
		}
	}
	
    @IBAction func didTapOkButton(sender: Button) {
        if countElements(BMEAppStoreId) > 0 {
            Appirater.userDidSignificantEvent(true)
        }
        dismiss()
    }
    
    @IBAction func didTapReportButton(sender: UIButton) {
        performSegueWithIdentifier(reportAbuseSegue, sender: self)
    }
    
    private func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
