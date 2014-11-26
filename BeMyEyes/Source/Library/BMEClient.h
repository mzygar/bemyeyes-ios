//
//  BMEClient.h
//  BeMyEyes
//
//  Created by Simon Støvring on 05/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "AFHTTPClient.h"
#import "BMEUserTask.h"
#import "BMEUser.h"
#import "BMEToken.h"

@class BMERequest, BMEFacebookInfo, BMECommunityStats;

enum {
    BMEClientErrorInvalidBody = 1000,
    BMEClientErrorUndefinedRole = 1001,
    BMEClientErrorInvalidPassword = 1002,
    BMEClientErrorNotPermitted = 1003,
    
    BMEClientErrorRequestNotFound = 2000,
    BMEClientErrorRequestSessionNotCreated = 2001,
    BMEClientErrorRequestAlreadyAnswered = 2002,
    BMEClientErrorRequestNotAnswered = 2003,
    BMEClientErrorRequestStopped = 2004,
    
    BMEClientErrorUserNotFound = 3000,
    BMEClientErrorUserUsernameTaken = 3001,
    BMEClientErrorUserEmailAlreadyRegistered = 3002,
    BMEClientErrorUserTokenNotFound = 3003,
    BMEClientErrorUserTokenExpired = 3004,
    BMEClientErrorUserIncorrectCredentials = 3005,
    BMEClientErrorUserFacebookUserNotFound = 3006,
};

extern NSString* BMENormalizedDeviceTokenStringWithDeviceToken(id deviceToken);

@interface BMEClient : AFHTTPClient

@property (readonly, nonatomic, getter = isLoggedIn) BOOL loggedIn;
@property (readonly, nonatomic) BMEUser *currentUser;
@property (copy, nonatomic) NSString *facebookAppId;

+ (BMEClient *)sharedClient;
- (void)setUsername:(NSString *)username password:(NSString *)password;

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion;
- (void)createFacebookUserId:(long long)userId email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateCurrentUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateUserWithIdentifier:(NSString *)identifier firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password deviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *token))success failure:(void (^)(NSError *error))failure;
- (void)loginWithEmail:(NSString *)email userId:(long long)userId deviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *token))success failure:(void (^)(NSError *error))failure;
- (void)loginUsingFacebookWithDeviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *token))success loginFailure:(void (^)(NSError *error))loginFailure accountFailure:(void (^)(NSError *error))accountFailure;
- (void)logoutWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)resetLogin;
- (void)verifyTokenAuthOnServerWithCompletion:(void (^)(BOOL))completion;
- (void)sendNewPasswordToEmail:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion;
- (void)updateUserInfoWithUTCOffset:(void (^)(BOOL success, NSError *error))completion;
- (void)updateUserWithKnownLanguages:(NSArray *)languages completion:(void (^)(BOOL success, NSError *error))completion;
- (void)loadAvailableLanguagesWithCompletion:(void(^)(NSArray *languages, NSError *error))completion;
- (void)updateUserWithTaskType:(BMEUserTaskType)taskType completion:(void (^)(BOOL success, NSError *error))completion;

- (void)createRequestWithSuccess:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)loadRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)answerRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)cancelAnswerForRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion;
- (void)disconnectFromRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion;
- (void)checkForPendingRequest:(void (^)(NSString *shortId, BOOL success, NSError *error))completion;

- (void)reportAbuseForRequestWithId:(NSString *)identifier reason:(NSString *)reason completion:(void (^)(BOOL success, NSError *error))completion;

- (void)upsertDeviceWithNewToken:(NSString *)newToken production:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion;


- (void)authenticateWithFacebook:(void(^)(BMEFacebookInfo *fbInfo, NSError *error))completion;

- (void)loadTotalPoint:(void(^)(NSUInteger point, NSError *error))completion;
- (void)loadPointForDays:(NSUInteger)days completion:(void(^)(NSArray *entries, NSError *error))completion;
- (void)loadUserStatsCompletion:(void (^)(BMEUser *, NSError *))completion;
- (void)loadCommunityStatsPointsCompletion:(void (^)(BMECommunityStats *, NSError *))completion;
- (void)loadUserTasksCompletion:(void (^)(BMEUser *, NSError *))completion;

- (NSString *)token;
- (NSDate *)tokenExpiryDate;
- (BOOL)isTokenValid;

@end
