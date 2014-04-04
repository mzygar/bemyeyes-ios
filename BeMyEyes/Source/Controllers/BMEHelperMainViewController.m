//
//  BMEHelperMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEHelperMainViewController.h"
#import "BMEPointGraphView.h"

@interface BMEHelperMainViewController ()
@property (weak, nonatomic) IBOutlet BMEPointGraphView *pointGraphView;
@end

@implementation BMEHelperMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawDemoGraph];
}

#pragma mark -
#pragma mark Private Methods

- (void)drawDemoGraph {
    NSDate *now = [NSDate date];
    NSUInteger dateAmount = 10;
    
    for (NSUInteger i = 0; i < dateAmount; i++) {
        NSDate *date = [now dateByAddingTimeInterval:-(24 * 3600 * (CGFloat)i)];
        NSUInteger points = arc4random_uniform(50);
        [self.pointGraphView addPoints:points atDate:date];
    }
    
    [self.pointGraphView draw];
}

@end
