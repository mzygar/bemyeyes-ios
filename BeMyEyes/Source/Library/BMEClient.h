//
//  BMEClient.h
//  BeMyEyes
//
//  Created by Simon Støvring on 05/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "AFHTTPClient.h"

@class BMERequest, BMEToken, BMEUser, BMEFacebookInfo;

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

@interface BMEClient : AFHTTPClient

@property (readonly, nonatomic, getter = isLoggedIn) BOOL loggedIn;
@property (readonly, nonatomic) BMEUser *currentUser;
@property (copy, nonatomic) NSString *facebookAppId;

+ (BMEClient *)sharedClient;
- (void)setUsername:(NSString *)username password:(NSString *)password;

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion;
- (void)createFacebookUserId:(NSInteger)userId email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(BMEToken *token))success failure:(void (^)(NSError *error))failure;
- (void)loginWithEmail:(NSString *)email userId:(NSInteger)userId success:(void (^)(BMEToken *token))success failure:(void (^)(NSError *error))failure;
- (void)loginUsingTokenWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)loginUsingFacebookWithSuccesss:(void (^)(BMEToken *token))success loginFailure:(void (^)(NSError *error))loginFailure accountFailure:(void (^)(NSError *error))accountFailure;
- (void)logoutWithCompletion:(void (^)(BOOL success, NSError *error))completion;

- (void)createRequestWithSuccess:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)loadRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)answerRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure;
- (void)cancelAnswerForRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion;
- (void)disconnectFromRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion;

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken productionOrAdHoc:(BOOL)isProduction;
- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken productionOrAdHoc:(BOOL)isProduction completion:(void (^)(BOOL success, NSError *error))completion;

- (void)authenticateWithFacebook:(void(^)(BMEFacebookInfo *fbInfo))success failure:(void(^)(NSError *error))failure;

- (NSString *)token;
- (NSDate *)tokenExpiryDate;
- (BOOL)isTokenValid;

@end
