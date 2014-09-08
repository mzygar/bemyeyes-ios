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

- (void)testExample
{
   NSString *normalizedDeviceToken = @"1234";
    // Register new device token
    [[BMEClient sharedClient] registerDeviceWithAbsoluteDeviceToken:normalizedDeviceToken active:YES production:BMEIsProductionOrAdHoc completion:^(BOOL success, NSError *error) {
        
        if (error) {
            XCTFail (@"Failed registering device: %@", error);
        }
    }];
}

@end
