//
//  BMEClient.m
//  BeMyEyes
//
//  Created by Simon Støvring on 05/08/13.
//  Copyright (c) 2013 intuitaps. All rights reserved.
//

#import "BMEClient.h"
#import <AFNetworking/AFJSONRequestOperation.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCKeyValueObjectMapping/DCParserConfiguration.h>
#import <DCKeyValueObjectMapping/DCPropertyAggregator.h>
#import <DCKeyValueObjectMapping/DCObjectMapping.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "AESCrypt.h"
#import "BMERequest.h"
#import "BMEToken.h"
#import "BMEUser.h"
#import "BMEPointEntry.h"
#import "BMEFacebookInfo.h"
#import "BMERoleConverter.h"

#define BMEClientTokenKey @"BMEClientToken"
#define BMEClientCurrentUserKey @"BMEClientCurrentUser"
#define BMEClientTokenExpiryDateKey @"BMEClientTokenExpiryDate"

/**
 *  This is taken from Mattt Thompsons AFUrbanAirshipClient
 *  https://github.com/AFNetworking/AFUrbanAirshipClient
 */
NSString* BMENormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@interface BMEClient ()
@property (assign, nonatomic, getter = hasConfiguredFacebookLogin) BOOL configuredFacebookLogin;
@property (copy, nonatomic) void(^fbAuthCompletion)(BMEFacebookInfo *, NSError *);
@property (strong, nonatomic) ACAccountStore *accountStore;
@end

@implementation BMEClient

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    NSString *baseUrlStr = nil;
    switch ([GVUserDefaults standardUserDefaults].api) {
        case BMESettingsAPIDevelopment:
            baseUrlStr = BMEAPIDevelopmentBaseUrl;
            break;
        case BMESettingsAPIStaging:
            baseUrlStr = BMEAPIStagingBaseUrl;
            break;
        case BMESettingsAPIPublic:
            baseUrlStr = BMEAPIPublicBaseUrl;
            break;
        default:
            baseUrlStr = BMEAPIPublicBaseUrl;
            break;
    }
    
    NSLog(@"Use API: %@", baseUrlStr);
    
    NSURL *baseUrl = [NSURL URLWithString:baseUrlStr];
    if (self = [super initWithBaseURL:baseUrl]) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        self.parameterEncoding = AFJSONParameterEncoding;
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    
    return self;
}

+ (BMEClient *)sharedClient {
    static BMEClient *sharedClient = nil;
    
    if (sharedClient == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedClient = [[BMEClient alloc] init];
        });
    }
    
    return sharedClient;
}

#pragma mark -
#pragma mark Public Methods

- (void)setUsername:(NSString *)username password:(NSString *)password {
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

#pragma mark -
#pragma mark Users

- (void)createUserWithEmail:(NSString *)email password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion {
    NSAssert([email length] > 0, @"E-mail cannot be empty.");
    NSAssert([password length] > 0, @"Password cannot be empty.");
    NSAssert([firstName length] > 0, @"First name cannot be empty.");
    NSAssert([lastName length] > 0, @"Last name cannot be empty.");
    
    NSString *securePassword = [AESCrypt encrypt:password password:BMESecuritySalt];
    NSDictionary *parameters = @{ @"email" : email,
                                  @"password" : securePassword,
                                  @"first_name" : firstName,
                                  @"last_name" : lastName,
                                  @"role" : (role == BMERoleBlind) ? @"blind" : @"helper",
                                  @"languages" : @[ [[NSLocale preferredLanguages] objectAtIndex:0] ] };
    
    [self createUserWithParameters:parameters completion:completion];
}

- (void)createFacebookUserId:(long long)userId email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion {
    NSAssert([firstName length] > 0, @"First name cannot be empty.");
    NSAssert([lastName length] > 0, @"Last name cannot be empty.");

    NSDictionary *parameters = @{ @"user_id" : @(userId),
                                  @"email" : email,
                                  @"first_name" : firstName,
                                  @"last_name" : lastName,
                                  @"role" : (role == BMERoleBlind) ? @"blind" : @"helper",
                                  @"languages" : @[ [[NSLocale preferredLanguages] objectAtIndex:0] ] };
    
    [self createUserWithParameters:parameters completion:completion];
}

- (void)updateCurrentUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion {
    [self updateUserWithIdentifier:[self currentUser].identifier firstName:firstName lastName:lastName email:email completion:completion];
}

- (void)updateUserWithIdentifier:(NSString *)identifier firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion {
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (firstName) {
        [params setValue:firstName forKey:@"first_name"];
    }
    
    if (lastName) {
        [params setValue:lastName forKey:@"last_name"];
    }
    
    if (email) {
        [params setValue:email forKey:@"email"];
    }
    
    NSString *path = [NSString stringWithFormat:@"users/%@", identifier];
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BMEUser *currentUser = [self currentUser];
        [currentUser setValue:firstName forKeyPath:@"firstName"];
        [currentUser setValue:lastName forKeyPath:@"lastName"];
        [currentUser setValue:email forKeyPath:@"email"];
        [self storeCurrentUser:currentUser];
        
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password deviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *))success failure:(void (^)(NSError *))failure {
    NSAssert([email length] > 0, @"E-mail cannot be empty.");
    NSAssert([password length] > 0, @"Password cannot be empty.");
    
    NSString *securePassword = [AESCrypt encrypt:password password:BMESecuritySalt];
    NSDictionary *parameters = @{ @"email" : email,
                                  @"password" : securePassword,
                                  @"device_token" : deviceToken ? deviceToken : @"" };
    
    [self loginWithParameters:parameters success:success failure:failure];
}

- (void)loginWithEmail:(NSString *)email userId:(long long)userId deviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *))success failure:(void (^)(NSError *))failure {
    NSAssert([email length] > 0, @"E-mail cannot be empty.");
    NSAssert(userId > 0, @"User ID cannot be empty.");
    NSAssert([deviceToken length] > 0, @"Device token cannot be empty.");

    NSDictionary *parameters = @{ @"email" : email,
                                  @"user_id" : @(userId),
                                  @"device_token" : deviceToken };
    
    [self loginWithParameters:parameters success:success failure:failure];
}

- (void)loginUsingUserTokenWithDeviceToken:(NSString *)deviceToken completion:(void (^)(BOOL, NSError *))completion {
    NSDictionary *parameters = @{ @"token" : [self token],
                                  @"device_token" : deviceToken };
    [self putPath:@"users/login/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _loggedIn = YES;
        
        BMEUser *currentUser = [self mapUserFromRepresentation:[responseObject objectForKey:@"user"]];
        [self storeCurrentUser:currentUser];
        
        NSLog(@"Did log in using endpoint /users/login/token with parameters: %@", parameters);

        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *bmeError = [self errorWithRecoverySuggestionInvestigated:error];
        switch ([bmeError code]) {
            case BMEClientErrorUserNotFound:
            case BMEClientErrorUserFacebookUserNotFound:
            case BMEClientErrorUserTokenNotFound:
            case BMEClientErrorUserTokenExpired: {
                _loggedIn = NO;
                
                [self storeCurrentUser:nil];
                
                if (completion) {
                    completion(NO, bmeError);
                }
                break;
            }
            default:
                // The log in with token failed due to a network error (meaning that the user may be offline),
                // so we reuse the users stored user and assume that he has the rights to log in.
                _loggedIn = YES;
                
                if (completion) {
                    completion(YES, nil);
                }
                break;
        }
    }];
}

- (void)loginUsingFacebookWithDeviceToken:(NSString *)deviceToken success:(void (^)(BMEToken *))success loginFailure:(void (^)(NSError *))loginFailure accountFailure:(void (^)(NSError *))accountFailure {
    NSAssert([self.facebookAppId length] > 0, @"Facebook app ID must be set in order to login with Facebook.");
    
    [self authenticateWithFacebook:^(BMEFacebookInfo *fbInfo, NSError *error) {
        if (!error) {
            [self loginWithEmail:fbInfo.email userId:[fbInfo.userId longLongValue] deviceToken:deviceToken success:success failure:loginFailure];
        } else {
            if (accountFailure) {
                accountFailure(error);
            }
        }
    }];
}

- (void)logoutWithCompletion:(void (^)(BOOL, NSError *))completion {
    NSDictionary *parameters = @{ @"token" : [self token] };
    [self putPath:@"users/logout" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self resetLogin];
        
        _loggedIn = NO;
        
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)resetLogin {
    [self storeToken:nil];
    [self storeTokenExpiryDate:nil];
}

- (void)sendNewPasswordToEmail:(NSString *)email completion:(void (^)(BOOL success, NSError *error))completion {
    NSDictionary *params = @{ @"email" : email };
    [self postPath:@"auth/request-reset-password" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)updateUserInfoWithUTCOffset:(void (^)(BOOL success, NSError *error))completion {
    NSAssert([self isLoggedIn], @"User must be logged in before the info can be updated.");
    
    CGFloat seconds = (CGFloat)[[NSTimeZone systemTimeZone] secondsFromGMT];
    CGFloat utcOffset = seconds / 3600.0f;
    
    NSDictionary *params = @{ @"utc_offset" : [NSString stringWithFormat:@"%.0f", utcOffset] };
    
    NSString *path = [NSString stringWithFormat:@"users/info/%@", [self token]];
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, error);
        }
    }];
}

- (void)updateUserWithKnownLanguages:(NSArray *)languages completion:(void (^)(BOOL success, NSError *error))completion {
    NSAssert([self isLoggedIn], @"User must be logged in.");
    
    NSString *path = [NSString stringWithFormat:@"users/%@", [BMEClient sharedClient].currentUser.identifier];
    NSDictionary *params = @{ @"languages" : languages };
    
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BMEUser *currentUser = [self currentUser];
        [currentUser setValue:languages forKeyPath:@"languages"];
        [self storeCurrentUser:currentUser];
        
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, error);
        }
    }];
}

#pragma mark -
#pragma mark Requests

- (void)createRequestWithSuccess:(void (^)(BMERequest *))success failure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{ @"token" : [self token] };
    [self postPath:@"requests" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if (success) {
            success([self mapRequestFromRepresentation:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)loadRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *))success failure:(void (^)(NSError *))failure {
    NSString *path = [NSString stringWithFormat:@"requests/%@", shortId];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([self mapRequestFromRepresentation:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)answerRequestWithShortId:(NSString *)shortId success:(void (^)(BMERequest *request))success failure:(void (^)(NSError *error))failure {
    NSDictionary *parameters = @{ @"token" : [self token] };
    NSString *path = [NSString stringWithFormat:@"requests/%@/answer", shortId];
    [self putPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([self mapRequestFromRepresentation:responseObject]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)cancelAnswerForRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion {
    NSDictionary *parameters = @{ @"token" : [self token] };
    NSString *path = [NSString stringWithFormat:@"requests/%@/answer/cancel", shortId];
    [self putPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)disconnectFromRequestWithShortId:(NSString *)shortId completion:(void (^)(BOOL success, NSError *error))completion {
    NSDictionary *parameters = @{ @"token" : [self token] };
    NSString *path = [NSString stringWithFormat:@"requests/%@/disconnect", shortId];
    [self putPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)checkForPendingRequest:(void (^)(NSString *shortId, BOOL success, NSError *error))completion {
    NSAssert([self isLoggedIn], @"User must be logged in to check for pending requests.");
    
    NSString *path = [NSString stringWithFormat:@"helpers/waiting_request/%@", [BMEClient sharedClient].currentUser.identifier];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *shortId = [responseObject objectForKey:@"id"];
        if (completion) {
            completion(shortId, YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *bmeError = [self errorWithRecoverySuggestionInvestigated:error];
        if ([bmeError code] == BMEClientErrorRequestNotFound) {
            // The request was successful, but failed because there were no requests.
            // We consider this a success but return no short ID
            completion(nil, YES, nil);
        } else {
            completion(nil, NO, error);
        }
    }];
}

#pragma mark -
#pragma mark Abuse

- (void)reportAbuseForRequestWithId:(NSString *)identifier reason:(NSString *)reason completion:(void (^)(BOOL success, NSError *error))completion {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self token] forKey:@"token"];
    
    if (identifier) {
        [params setObject:identifier forKey:@"request_id"];
    }
    
    if (reason) {
        [params setObject:reason forKey:@"reason"];
    }
    
    [self postPath:@"abuse/report" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, error);
        }
    }];
}

#pragma mark -
#pragma mark Devices

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken production:(BOOL)isProduction {
    [self registerDeviceWithDeviceToken:deviceToken active:YES production:isProduction completion:nil];
}

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken production:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion {
    [self registerDeviceWithDeviceToken:deviceToken active:YES production:isProduction completion:completion];
}

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken active:(BOOL)isActive production:(BOOL)isProduction {
    [self registerDeviceWithDeviceToken:deviceToken production:isProduction completion:nil];
}

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken active:(BOOL)isActive production:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion {
    NSString *normalizedDeviceToken = BMENormalizedDeviceTokenStringWithDeviceToken(deviceToken);
    [self sendDeviceInfoToPath:@"devices/register" withDeviceToken:normalizedDeviceToken newToken:nil active:isActive productionOrAdHoc:isProduction completion:completion];
}

- (void)registerDeviceWithAbsoluteDeviceToken:(NSString *)deviceToken production:(BOOL)isProduction {
    [self registerDeviceWithAbsoluteDeviceToken:deviceToken active:YES production:isProduction completion:nil];
}

- (void)registerDeviceWithAbsoluteDeviceToken:(NSString *)deviceToken production:(BOOL)isProduction completion:(void (^)(BOOL success, NSError *error))completion {
    [self registerDeviceWithAbsoluteDeviceToken:deviceToken active:YES production:isProduction completion:completion];
}

- (void)registerDeviceWithAbsoluteDeviceToken:(NSString *)deviceToken active:(BOOL)isActive production:(BOOL)isProduction {
    [self registerDeviceWithAbsoluteDeviceToken:deviceToken active:isActive production:isProduction completion:nil];
}

- (void)registerDeviceWithAbsoluteDeviceToken:(NSString *)deviceToken active:(BOOL)isActive production:(BOOL)isProduction completion:(void (^)(BOOL success, NSError *error))completion {
    [self sendDeviceInfoToPath:@"devices/register" withDeviceToken:deviceToken newToken:nil active:isActive productionOrAdHoc:isProduction completion:completion];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken productionOrAdHoc:(BOOL)isProduction {
    [self updateDeviceWithDeviceToken:deviceToken newToken:nil active:YES production:isProduction completion:nil];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken productionOrAdHoc:(BOOL)isProduction completion:(void (^)(BOOL success, NSError *error))completion {
    [self updateDeviceWithDeviceToken:deviceToken newToken:nil active:YES production:isProduction completion:completion];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken active:(BOOL)isActive productionOrAdHoc:(BOOL)isProduction {
    [self updateDeviceWithDeviceToken:deviceToken newToken:nil active:isActive production:isProduction completion:nil];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken active:(BOOL)isActive productionOrAdHoc:(BOOL)isProduction completion:(void (^)(BOOL success, NSError *error))completion {
    [self updateDeviceWithDeviceToken:deviceToken newToken:nil active:isActive production:isProduction completion:completion];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken newToken:(NSString *)newToken active:(BOOL)isActive production:(BOOL)isProduction {
    [self updateDeviceWithDeviceToken:deviceToken newToken:newToken active:isActive production:isProduction completion:nil];
}

- (void)updateDeviceWithDeviceToken:(NSString *)deviceToken newToken:(NSString *)newToken active:(BOOL)isActive production:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion {
    [self sendDeviceInfoToPath:@"devices/update" withDeviceToken:deviceToken newToken:newToken active:isActive productionOrAdHoc:isProduction completion:completion];
}

#pragma mark -
#pragma mark Facebook

- (void)authenticateWithFacebook:(void (^)(BMEFacebookInfo *, NSError *))completion {
    self.fbAuthCompletion = completion;
    [self facebookRequestAccess];
}

#pragma mark -
#pragma mark Points

- (void)loadTotalPoint:(void(^)(NSUInteger point, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:@"users/helper_points_sum/%@", [self currentUser].identifier];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger sum = [[responseObject objectForKey:@"sum"] integerValue];
        if (completion) {
            completion(sum, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(0, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)loadPointForDays:(NSUInteger)days completion:(void (^)(NSArray *, NSError *))completion {
    NSString *path = [NSString stringWithFormat:@"users/helper_points/%@", [self currentUser].identifier];
    [self getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion([self mapPointEntryFromRepresentation:responseObject], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(nil, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

#pragma mark -
#pragma mark Public Accessors

- (BMEUser *)currentUser {
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:BMEClientCurrentUserKey];
    if (userData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
    
    return nil;
}

- (NSString *)token {
    return [[NSUserDefaults standardUserDefaults] objectForKey:BMEClientTokenKey];
}

- (NSDate *)tokenExpiryDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:BMEClientTokenExpiryDateKey];
}

- (BOOL)isTokenValid {
    return ([self token] != nil && [self tokenExpiryDate] != nil && [[self tokenExpiryDate] compare:[NSDate date]] == NSOrderedDescending);
}

#pragma mark -
#pragma mark Private Methods

- (void)sendDeviceInfoToPath:(NSString *)path withDeviceToken:(NSString *)deviceToken newToken:(NSString *)newToken active:(BOOL)isActive productionOrAdHoc:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion {
    NSString *alias = [UIDevice currentDevice].name;
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];

    NSDictionary *parameters = @{ @"device_token" : deviceToken,
                                  @"device_name" : alias,
                                  @"model" : model,
                                  @"system_version" : [NSString stringWithFormat:@"%@ %@", systemName, systemVersion],
                                  @"app_version" : appVersion,
                                  @"app_bundle_version" : appBundleVersion,
                                  @"locale" : locale,
                                  @"development" : isProduction ? @(NO) : @(YES),
                                  @"inactive" : @(!isActive) };
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if (newToken) {
        [mutableParameters setObject:newToken forKey:@"new_device_token"];
    }
    
    [self postPath:path parameters:mutableParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Device info sent to path %@ with parameters: %@", path, mutableParameters);
        
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed sending device info to path %@ with parameters: %@", path, mutableParameters);
        
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)createUserWithParameters:(NSDictionary *)params completion:(void (^)(BOOL success, NSError *error))completion {
    [self postPath:@"users" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)loginWithParameters:(NSDictionary *)params success:(void (^)(BMEToken *))success failure:(void (^)(NSError *error))failure {
    NSLog(@"Login with parameters: %@", params);
    [self postPath:@"users/login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BMEToken *token = [self mapTokenFromRepresentation:[responseObject objectForKey:@"token"]];
        [self storeToken:token.token];
        [self storeTokenExpiryDate:token.expiryDate];
        
        _loggedIn = YES;
        
        BMEUser *currentUser = [self mapUserFromRepresentation:[responseObject objectForKey:@"user"]];
        [self storeCurrentUser:currentUser];
        
        NSLog(@"Did log in using endpoints users/login with parameters: %@", params);
        NSLog(@"Received token after log in: %@", token.token);
        
        if (success) {
            success(token);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)facebookRequestAccess {
    NSDictionary *options = @{ ACFacebookAppIdKey: self.facebookAppId, ACFacebookPermissionsKey: @[ @"email" ] };
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [self.accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"Facebook: Did get access to account");
            ACAccount *account = [[self.accountStore accountsWithAccountType:accountType] firstObject];
            [self facebookRenewAccount:account];
        } else {
            NSLog(@"Facebook: Could not get access to account: %@", error);
            [self facebookAuthFailed:error];
        }
    }];
}

- (void)facebookRenewAccount:(ACAccount *)account {
    [self.accountStore renewCredentialsForAccount:account completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
        if (!error) {
            NSLog(@"Facebook: Did renew credentials");
            [self.accountStore saveAccount:account withCompletionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"Facebook: Did save account");
                    [self facebookGetInfoFromAccount:account];
                } else {
                    NSLog(@"Facebook: Could not save account: %@", error);
                    [self facebookAuthFailed:error];
                }
            }];
        } else {
            NSLog(@"Facebook: Could not renew credentials: %@", error);
            [self facebookAuthFailed:error];
        }
    }];
}

- (void)facebookGetInfoFromAccount:(ACAccount *)account {
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:nil];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error == nil && [urlResponse statusCode] == 200) {
            NSError *deserializationError;
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&deserializationError];
            if (userData != nil && deserializationError == nil) {
                NSLog(@"Facebook user data: %@", userData);
                [self facebookAuthSuccessWithUserData:userData];
            } else {
                NSLog(@"Facebook: Could not deserialize response from request to get info: %@", error);
                [self facebookAuthFailed:deserializationError];
            }
        } else {
            NSLog(@"Facebook: Could not perform request to get info: %@", error);
            [self facebookAuthFailed:error];
        }
    }];
}

- (void)facebookAuthFailed:(NSError *)error {
    if (self.fbAuthCompletion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fbAuthCompletion(nil, error);
            self.fbAuthCompletion = nil;
        });
    }
}

- (void)facebookAuthSuccessWithUserData:(NSDictionary *)userData {
    if (self.fbAuthCompletion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *userId = userData[@"id"];
            NSString *firstName = userData[@"first_name"];
            NSString *lastName = userData[@"last_name"];
            NSString *email = userData[@"email"];
            
            BMEFacebookInfo *fbInfo = [BMEFacebookInfo new];
            [fbInfo setValue:userId forKeyPath:@"userId"];
            [fbInfo setValue:email forKeyPath:@"email"];
            [fbInfo setValue:firstName forKeyPath:@"firstName"];
            [fbInfo setValue:lastName forKeyPath:@"lastName"];
            
            self.fbAuthCompletion(fbInfo, nil);
            self.fbAuthCompletion = nil;
        });
    }
}

- (BMERequest *)mapRequestFromRepresentation:(NSDictionary *)representation {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *identifierMapping = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"identifier" onClass:[BMERequest class]];
    [config addObjectMapping:identifierMapping];
    
    DCObjectMapping *openTokMapping = [DCObjectMapping mapKeyPath:@"opentok" toAttribute:@"openTok" onClass:[BMERequest class]];
    [config addObjectMapping:openTokMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BMERequest class] andConfiguration:config];
    return [parser parseDictionary:representation];
}

- (BMEToken *)mapTokenFromRepresentation:(NSDictionary *)representation {
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    NSDate *expiryDate = [formatter dateFromString:[representation objectForKey:@"expiry_time"]];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BMEToken class]];
    BMEToken *token = [parser parseDictionary:representation];
    [token setValue:expiryDate forKey:@"expiryDate"];
    return token;
}

- (BMEUser *)mapUserFromRepresentation:(NSDictionary *)representation {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
    DCObjectMapping *identifierMapping = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"identifier" onClass:[BMEUser class]];
    [config addObjectMapping:identifierMapping];
    
    id <DCValueConverter> roleConverter = [[BMERoleConverter alloc] init];
    DCObjectMapping *roleMapping = [DCObjectMapping mapKeyPath:@"role" toAttribute:@"role" onClass:[BMEUser class] converter:roleConverter];
    [config addObjectMapping:roleMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BMEUser class] andConfiguration:config];
    return [parser parseDictionary:representation];
}

- (NSArray *)mapPointEntryFromRepresentation:(NSArray *)representation {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    config.datePattern = @"y-M-d'T'H:m:s.SSS'Z'";
    
    DCObjectMapping *dateMapping = [DCObjectMapping mapKeyPath:@"log_time" toAttribute:@"date" onClass:[BMEPointEntry class]];
    [config addObjectMapping:dateMapping];
    
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BMEPointEntry class] andConfiguration:config];
    return [parser parseArray:representation];
}

- (NSError *)errorFromRepresentation:(NSDictionary *)representation {
    NSDictionary *errorDict = [representation objectForKey:@"error"];
    NSInteger code = [[errorDict objectForKey:@"code"] integerValue];
    NSString *message = [errorDict objectForKey:@"message"];
    
    return [NSError errorWithDomain:BMEErrorDomain code:code userInfo:@{ NSLocalizedDescriptionKey : message }];
}

- (void)storeCurrentUser:(BMEUser *)user {
    if (user) {
        NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:user];
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:BMEClientCurrentUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BMEClientCurrentUserKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)storeToken:(NSString *)token {
    if (token) {
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:BMEClientTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BMEClientTokenKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)storeTokenExpiryDate:(NSDate *)date {
    if (date) {
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:BMEClientTokenExpiryDateKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BMEClientTokenExpiryDateKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSError *)errorWithRecoverySuggestionInvestigated:(NSError *)error {
    NSString *recoverySuggestion = error.localizedRecoverySuggestion;
    if (recoverySuggestion) {
        NSData *data = [recoverySuggestion dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *parseError = nil;
        id parsed = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
        if (parseError) {
            return error;
        } else if ([parsed isKindOfClass:[NSDictionary class]] && [parsed objectForKey:@"error"]) {
            return [self errorFromRepresentation:parsed];
        }
    }
    
    return error;
}

- (ACAccountStore *)accountStore {
    if (!_accountStore) {
        _accountStore = [ACAccountStore new];
    }
    
    return _accountStore;
}

@end
