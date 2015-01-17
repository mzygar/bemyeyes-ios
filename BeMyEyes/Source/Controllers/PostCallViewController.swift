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
            
            let dismissButtonKey: String = {
                switch role {
                    case .Blind:
                        return "POST_CALL_VIEW_CONTROLLER_DISMISS_BUTTON_BLIND"
                    case .Helper:
                        return "POST_CALL_VIEW_CONTROLLER_DISMISS_BUTTON_HELPER"
                }
            }()
            okButton.title = MKLocalizedFromTable(dismissButtonKey, "PostCallLocalizationTable")
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
