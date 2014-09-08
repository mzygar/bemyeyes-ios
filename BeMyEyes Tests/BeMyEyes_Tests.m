//
//  BeMyEyes_Tests.m
//  BeMyEyes Tests
//
//  Created by Klaus Hebsgaard on 07/09/2014.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BMEGlobal.h"
#import "BMEClient.h"

@interface BeMyEyes_Tests : XCTestCase

@end

@implementation BeMyEyes_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterDevice
{
   NSString *normalizedDeviceToken = @"1234";
    // Register new device token
    [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:normalizedDeviceToken active:YES production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
        
        if (error) {
            XCTFail (@"Failed registering device: %@", error);
        }
    }];
}
- (void)testCreateUserWithEmail
{
    NSString *email = @"someone@example.com";
    NSString *password = @"Password1";
    NSString *firstName = @"FirstName";
    NSString *lastName = @"LastName";
    [[BMEClient sharedClient] createUserWithEmail:email password:password firstName:firstName lastName:lastName role:BMERoleHelper completion:^(BOOL success, NSError *error) {
        XCTAssertTrue(success && !error);
    }];
}

- (void)testCreateUserAndLogin
{
    NSString *normalizedDeviceToken = @"1234";
    NSString *email = @"someone@example.com";
    NSString *password = @"Password1";
    NSString *firstName = @"FirstName";
    NSString *lastName = @"LastName";
    // Register new device token
    [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:normalizedDeviceToken active:YES production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
        
        if (error) {
            XCTFail (@"Failed registering device: %@", error);
            NSLog(@"Failed registering device: %@", error);
        }
    }];
    
    [[BMEClient sharedClient] createUserWithEmail:email password:password firstName:firstName lastName:lastName role:BMERoleHelper completion:^(BOOL success, NSError *error) {
        XCTAssertTrue(success && !error);
    }];
    
    [[BMEClient sharedClient] loginWithEmail:email password:password deviceToken:normalizedDeviceToken success:^(BMEToken *token) {
        //XCTSuccess(@"");
    } failure:^(NSError *error) {
        XCTFail("Unable to login");
        NSLog(@"Unable to login");
        }
     ];
}

     
@end
