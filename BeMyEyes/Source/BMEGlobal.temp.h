//
//  BMEGlobal.h
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#ifndef BMEGlobal_h
#define BMEGlobal_h

#define BMEAPIDevelopmentBaseUrl @"https://devapi.bemyeyes.org"
#define BMEAPIStagingBaseUrl @"https://stagingapi.bemyeyes.org"
#define BMEAPIPublicBaseUrl @"https://api.bemyeyes.org"

#define BMEAPIUsername @""
#define BMEAPIPassword @""

#define BMEOpenTokAPIKey @""

#define BMESecuritySalt @""

#define BMEFacebookAppId @""

#define BMEAppStoreId @""

#define BMEFeedbackRecipientEmail @"info@bemyeyes.org"
#define BMEFeedbackEmailSubject @"Feedback on Be My Eyes"

#define BMEPeopleHelpedBeforeAskingForMoreLanguages 3

#define BMEIsProductionOrAdHoc true

#define BMEErrorDomain @"org.bemyeyes.BeMyEyes"

#define BMEMainControllerIdentifier @"Main"
#define BMEMainBlindControllerIdentifier @"MainBlind"
#define BMEMainHelperControllerIdentifier @"MainHelper"
#define BMEMenuControllerIdentifier @"Menu"
#define BMECallControllerIdentifier @"Call"
#define BMESecretSettingsControllerIdentifier @"SecretSettings"

#define BMEDidLogOutNotification @"BMEDidLogOutNotification"
#define BMEDidUpdateProfileNotification @"BMEDidUpdateProfileNotification"
#define BMEDidUpdatePointNotification @"BMEDidUpdatePointNotification"

typedef NS_ENUM(NSInteger, BMERole) {
    BMERoleBlind = 0,
    BMERoleHelper,
};

#endif