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
#import <HIPSocialAuth/HIPSocialAuthManager.h>
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

@interface BMEClient ()
@property (assign, nonatomic, getter = hasConfiguredFacebookLogin) BOOL configuredFacebookLogin;
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

- (void)setUsername:(NSString *)username password:(NSString *)password
{
    [self clearAuthorizationHeader];
    [self setAuthorizationHeaderWithUsername:username password:password];
}

#pragma mark -
#pragma mark Configurations

- (void)configureFacebookLogin {
    if (!self.hasConfiguredFacebookLogin) {
        self.configuredFacebookLogin = YES;

        [[HIPSocialAuthManager sharedManager] setupWithFacebookAppID:self.facebookAppId
                                              facebookAppPermissions:@[ @"email" ]
                                                facebookSchemeSuffix:nil
                                                  twitterConsumerKey:nil
                                               twitterConsumerSecret:nil];
    }
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
                                  @"role" : (role == BMERoleBlind) ? @"blind" : @"helper" };
    
    [self createUserWithParameters:parameters completion:completion];
}

- (void)createFacebookUserId:(NSInteger)userId email:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName role:(BMERole)role completion:(void (^)(BOOL success, NSError *error))completion {
    NSAssert([firstName length] > 0, @"First name cannot be empty.");
    NSAssert([lastName length] > 0, @"Last name cannot be empty.");

    NSDictionary *parameters = @{ @"user_id" : @(userId),
                                  @"email" : email,
                                  @"first_name" : firstName,
                                  @"last_name" : lastName,
                                  @"role" : (role == BMERoleBlind) ? @"blind" : @"helper" };
    
    [self createUserWithParameters:parameters completion:completion];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(BMEToken *))success failure:(void (^)(NSError *error))failure {
    NSAssert([email length] > 0, @"E-mail cannot be empty.");
    NSAssert([password length] > 0, @"Password cannot be empty.");
    
    NSString *securePassword = [AESCrypt encrypt:password password:BMESecuritySalt];
    NSDictionary *parameters = @{ @"email" : email, @"password" : securePassword };
    
    [self loginWithParameters:parameters success:success failure:failure];
}

- (void)loginWithEmail:(NSString *)email userId:(NSInteger)userId success:(void (^)(BMEToken *token))success failure:(void (^)(NSError *error))failure {
    NSAssert([email length] > 0, @"E-mail cannot be empty.");
    NSAssert(userId > 0, @"User ID cannot be empty.");

    NSDictionary *parameters = @{ @"email" : email, @"user_id" : @(userId) };
    
    [self loginWithParameters:parameters success:success failure:failure];
}

- (void)loginUsingTokenWithCompletion:(void (^)(BOOL, NSError *))completion {
    NSDictionary *parameters = @{ @"token" : [self token]  };
    [self putPath:@"users/login/token" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _loggedIn = YES;
        
        BMEUser *currentUser = [self mapUserFromRepresentation:[responseObject objectForKey:@"user"]];
        [self storeCurrentUser:currentUser];

        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _loggedIn = NO;
        
        [self storeCurrentUser:nil];
        
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (void)loginUsingFacebookWithSuccesss:(void (^)(BMEToken *))success loginFailure:(void (^)(NSError *))loginFailure accountFailure:(void (^)(NSError *))accountFailure {
    NSAssert([self.facebookAppId length] > 0, @"Facebook app ID must be set in order to login with Facebook.");
    
    [self configureFacebookLogin];
    
    [self authenticateWithFacebook:^(BMEFacebookInfo *fbInfo) {
        [self loginWithEmail:fbInfo.email userId:[fbInfo.userId integerValue] success:success failure:loginFailure];
    } failure:^(NSError *error) {
        if (accountFailure) {
            accountFailure(error);
        }
    }];
}

- (void)logoutWithCompletion:(void (^)(BOOL, NSError *))completion {
    NSDictionary *parameters = @{ @"token" : [self token] };
    [self putPath:@"users/logout" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self resetFacebookLogin];
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

- (void)resetFacebookLogin {
    [[HIPSocialAuthManager sharedManager] removeAccountOfType:HIPSocialAccountTypeFacebook];
    [[HIPSocialAuthManager sharedManager] resetCachedTokens];
}

- (void)resetLogin {
    [self storeToken:nil];
    [self storeTokenExpiryDate:nil];
}

#pragma mark -
#pragma mark Requests

- (void)createRequestWithSuccess:(void (^)(BMERequest *))success failure:(void (^)(NSError *))failure {
    NSDictionary *parameters = @{ @"token" : [self token] };
    [self postPath:@"requests" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark -
#pragma mark Devices

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken productionOrAdHoc:(BOOL)isProduction {
    [self registerDeviceWithDeviceToken:deviceToken productionOrAdHoc:isProduction completion:nil];
}

- (void)registerDeviceWithDeviceToken:(NSData *)deviceToken productionOrAdHoc:(BOOL)isProduction completion:(void (^)(BOOL, NSError *))completion {
    NSAssert([[self token] length] > 0, @"Cannot register device without an authentication token.");
    
    NSString *alias = [UIDevice currentDevice].name;
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *appBundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *model = [[UIDevice currentDevice] model];
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSString *normalizedDeviceToken = AFNormalizedDeviceTokenStringWithDeviceToken(deviceToken);
    
    NSDictionary *parameters = @{ @"token" : [self token],
                                  @"device_token" : normalizedDeviceToken,
                                  @"device_name" : alias,
                                  @"model" : model,
                                  @"system_version" : [NSString stringWithFormat:@"%@ %@", systemName, systemVersion],
                                  @"app_version" : appVersion,
                                  @"app_bundle_version" : appBundleVersion,
                                  @"locale" : locale,
                                  @"development" : isProduction ? @(NO) : @(YES) };
    [self postPath:@"devices/register" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completion) {
            completion(NO, [self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

#pragma mark -
#pragma mark Facebook

- (void)authenticateWithFacebook:(void (^)(BMEFacebookInfo *))success failure:(void (^)(NSError *))failure {
    if ([[HIPSocialAuthManager sharedManager] hasAuthenticatedAccountOfType:HIPSocialAccountTypeFacebook]) {
        [self resetFacebookLogin];
    }
    
    [[HIPSocialAuthManager sharedManager] authenticateAccountOfType:HIPSocialAccountTypeFacebook withHandler:^(HIPSocialAccount *account, NSDictionary *profileInfo, NSError *error) {
        if (!error) {
            NSNumber *userId = [profileInfo objectForKey:@"id"];
            NSString *email = [profileInfo objectForKey:@"email"];
            NSString *firstName = [profileInfo objectForKey:@"first_name"];
            NSString *lastName = [profileInfo objectForKey:@"last_name"];
            
            if (userId && email) {
                BMEFacebookInfo *fbInfo = [BMEFacebookInfo new];
                [fbInfo setValue:userId forKeyPath:@"userId"];
                [fbInfo setValue:email forKeyPath:@"email"];
                [fbInfo setValue:firstName forKeyPath:@"firstName"];
                [fbInfo setValue:lastName forKeyPath:@"lastName"];
                
                success(fbInfo);
            } else {
                [self resetFacebookLogin];
                
                if (failure) {
                    failure(error);
                }
            }
        } else {
            [self resetFacebookLogin];
            
            if (failure) {
                failure(error);
            }
        }
    }];
}

#pragma mark -
#pragma mark Points

- (void)loadTotalPoint:(void(^)(NSUInteger point, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:@"users/helper_points_sum/%i", [self currentUser].identifier];
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
    NSString *path = [NSString stringWithFormat:@"users/helper_points/%i", [self currentUser].identifier];
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
    [self postPath:@"users/login" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BMEToken *token = [self mapTokenFromRepresentation:[responseObject objectForKey:@"token"]];
        [self storeToken:token.token];
        [self storeTokenExpiryDate:token.expiryDate];
        
        _loggedIn = YES;
        
        BMEUser *currentUser = [self mapUserFromRepresentation:[responseObject objectForKey:@"user"]];
        [self storeCurrentUser:currentUser];
        
        if (success) {
            success(token);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure([self errorWithRecoverySuggestionInvestigated:error]);
        }
    }];
}

- (BMERequest *)mapRequestFromRepresentation:(NSDictionary *)representation {
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    
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
    config.datePattern = @"y-M-d'T'H:m:s'Z'";
    
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

/**
 *  This is taken from Mattt Thompsons AFUrbanAirshipClient
 *  https://github.com/AFNetworking/AFUrbanAirshipClient
 */
static NSString *AFNormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
