//
//  FacebookHelper.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

import Foundation

@objc class FacebookHelper {
   
    @objc class func urlForId(id: Int) -> NSURL? {
        let urlString = "https://graph.facebook.com/\(id)/picture?type=large"
        return NSURL(string: urlString)
    }
}
