//
//  BMEHelperMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEHelperMainViewController.h"
#import "BMEPointLabel.h"
#import "BMEPointGraphView.h"

@interface BMEHelperMainViewController ()
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointLabel;
@property (weak, nonatomic) IBOutlet BMEPointGraphView *pointGraphView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitleLabelLeadingMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitlePointSpaceConstraint;

@property (assign, nonatomic) NSUInteger totalPoint;
@end

@implementation BMEHelperMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.pointLabel.colors = @{ @(0.0f) : [UIColor colorWithRed:220.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f],
                                @(0.50f) : [UIColor colorWithRed:252.0f/255.0f green:197.0f/255.0f blue:46.0f/255.0f alpha:1.0f],
                                @(1.0f) : [UIColor colorWithRed:117.0f/255.0f green:197.0f/255.0f blue:27.0f/255.0f alpha:1.0f] };
 
    [self demoPoint];
    [self layoutPoint];
}

#pragma mark -
#pragma mark Private Methods

- (void)demoPoint {
    NSDate *now = [NSDate date];
    NSUInteger dateAmount = 10;
    
    NSUInteger total = 0;
    for (NSUInteger i = 0; i < dateAmount; i++) {
        NSDate *date = [now dateByAddingTimeInterval:-(24 * 3600 * (CGFloat)i)];
        NSUInteger points = arc4random_uniform(50);
        total += points;
        [self.pointGraphView addPoints:points atDate:date];
    }
    
    [self.pointGraphView draw];
    
    [self.pointLabel setPoint:total animated:YES];
    
    self.totalPoint = total;
}

- (void)layoutPoint {
    NSString *pointText = [NSString stringWithFormat:@"%i", self.totalPoint];
    CGRect pointRect = [pointText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.pointLabel.font } context:nil];
    self.pointLabelWidthConstraint.constant = CGRectGetWidth(pointRect) * 1.20f; // Add extra width for zoom animation
    [self.view layoutIfNeeded];
    
    CGFloat totalWidth = self.scoreTitleLabelWidthConstraint.constant + self.scoreTitlePointSpaceConstraint.constant + self.pointLabelWidthConstraint.constant;
    self.scoreTitleLabelLeadingMarginConstraint.constant = (CGRectGetWidth(self.view.bounds) - totalWidth) * 0.50f;
    [self.view layoutIfNeeded];
}

@end
