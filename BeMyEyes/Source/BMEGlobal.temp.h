//
//  BMEGlobal.h
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#ifndef BMEGlobal_h
#define BMEGlobal_h

#define BMEAPIBaseUrl @"http://devapi.bemyeyes.org/"
#define BMEAPIUsername @""
#define BMEAPIPassword @""

#define BMEOpenTokAPIKey @""

#define BMESecuritySalt @""

#define BMEFacebookAppId @""

#define BMEIsProductionOrAdHoc true

#define BMEErrorDomain @"org.bemyeyes.BeMyEyes"

#define BMEMainControllerIdentifier @"Main"
#define BMEMainBlindControllerIdentifier @"MainBlind"
#define BMEMainHelperControllerIdentifier @"MainHelper"
#define BMEMenuControllerIdentifier @"Menu"
#define BMECallControllerIdentifier @"Call"

#define BMEDidLogOutNotification @"BMEDidLogOutNotification"

typedef NS_ENUM(NSInteger, BMERole) {
    BMERoleBlind = 0,
    BMERoleHelper,
};

#endif