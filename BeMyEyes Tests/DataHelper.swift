//
//  DataHelper.swift
//  BeMyEyes
//
//  Created by Tobias Due Munk on 19/11/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

extension BMEUser {
    
    class func idealUser() -> BMEUser {
        let user = BMEUser()
        user.setValue("Sarah", forKey: "firstName")
        user.setValue(330, forKey: "totalPoints")
        
        let currentLevel = BMEUserLevel()
        currentLevel.title = "Trusted Helper"
        currentLevel.threshold = 200
        user.setValue(currentLevel, forKey: "currentLevel")
        
        let nextLevel = BMEUserLevel()
        nextLevel.threshold = 500
        user.setValue(nextLevel, forKey: "nextLevel")
        
        return user
    }
}
