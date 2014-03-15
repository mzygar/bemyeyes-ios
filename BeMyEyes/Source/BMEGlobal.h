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
#define BMEAPIUsername @"bemyeyes"
#define BMEAPIPassword @"detersmart"

#define BMESecuritySalt @"friepRlu7luziuwroagoustOatlebrIuspoa5luriahoeno0"

#define BMEErrorDomain @"org.bemyeyes.BeMyEyes"

#define BMEFacebookAppId @"771890076161460"

#define BMEMainControllerIdentifier @"Main"
#define BMEMainBlindControllerIdentifier @"MainBlind"
#define BMEMainHelperControllerIdentifier @"MainHelper"
#define BMEMenuControllerIdentifier @"Menu"

#define BMEDidLogOutNotification @"BMEDidLogOutNotification"

typedef NS_ENUM(NSInteger, BMERole) {
    BMERoleBlind = 0,
    BMERoleHelper,
};

#endif