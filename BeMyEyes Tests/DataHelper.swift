//
//  DataHelper.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 19/11/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import UIKit

extension BMEUser {
    
    class func idealUser() -> BMEUser {
        let user = BMEUser()
        if let image = UIImage(named: "ProfileSarah.png") {
            user.setValue(image, forKey: "profileImage")
        }
        user.setValue("Sara", forKey: "firstName")
        user.setValue(345, forKey: "totalPoints")
        user.setValue(13, forKey: "peopleHelped")
        
        let currentLevel = BMEUserLevel()
        currentLevel.title = "Trusted Helper"
        currentLevel.threshold = 200
        user.setValue(currentLevel, forKey: "currentLevel")
        
        let nextLevel = BMEUserLevel()
        nextLevel.threshold = 500
        user.setValue(nextLevel, forKey: "nextLevel")
      
        var point1 = BMEPointEntry()
        point1.setValue(30, forKey: "point")
        point1.setValue("finish_helping_request", forKey: "event")
        point1.setValue(NSDate().dateByAddingTimeInterval(-60*2), forKey: "date")
        var point2 = BMEPointEntry()
        point2.setValue(5, forKey: "point")
        point2.setValue("answer_push_message", forKey: "event")
        point2.setValue(NSDate().dateByAddingTimeInterval(-60*60*3), forKey: "date")
        var point3 = BMEPointEntry()
        point3.setValue(30, forKey: "point")
        point3.setValue("finish_helping_request", forKey: "event")
        point3.setValue(NSDate().dateByAddingTimeInterval(-60*60*24), forKey: "date")
        var point4 = BMEPointEntry()
        point4.setValue(30, forKey: "point")
        point4.setValue("finish_helping_request", forKey: "event")
        point4.setValue(NSDate().dateByAddingTimeInterval(-60*60*72), forKey: "date")
        user.setValue([point1, point2, point3, point4], forKey: "lastPointEntries")
        
        return user
    }
}

extension BMECommunityStats {
    
    class func idealStats() -> BMECommunityStats {
        var stats = BMECommunityStats()
        stats.sighted = 361
        stats.blind = 121
        stats.helped = 554
        return stats
    }
}


//@"signup"]) {
//    S_ENTRY_SIGNUP_DESCRIPTION;
//    String:@"answer_push_message"]) {
//        S_ENTRY_ANSWER_PUSH_MESSAGE_DESCRIPTION;
//        String:@"answer_push_message_technical_error"]
//        S_ENTRY_ANSWER_PUSH_MESSAGE_TECHNICAL_ERROR_DE
//        String:@"finish_helping_request"]) {
//            S_ENTRY_FINISH_HELPING_REQUEST_DESCRIPTION;
//            String:@"finish_10_helping_request_in_a_week"]
//            S_ENTRY_FINISH_10_HELPING_REQUESTS_IN_A_WEEK_D
//            String:@"finish_5_high_fives_in_a_week"]) {
//                S_ENTRY_FINISH_5_HIGH_FIVES_IN_A_WEEK_DESCRIPT
//                String:@"share_on_twitter"]) {
//                    S_ENTRY_SHARE_ON_TWITTER_DESCRIPTION;
//                    String:@"share_on_facebook"]) {
//                        S_ENTRY_SHARE_ON_FACEBOOK_DESCRIPTION;
//                        String:@"watch_video"]) {
//                            S_ENTRY_WATCH_VIDEO_DESCRIPTION;
