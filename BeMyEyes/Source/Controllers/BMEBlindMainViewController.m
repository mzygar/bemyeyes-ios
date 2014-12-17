//
//  BMEBlindMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEBlindMainViewController.h"
#import "BMEAppDelegate.h"
#import "BMEPointLabel.h"
#import "BMECommunityStats.h"

#define BMEBlindMainCallSegue @"Call"

@interface BMEBlindMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *connectToCommunityButton;
@property (weak, nonatomic) IBOutlet UIView *communityStatsView;
@property (weak, nonatomic) IBOutlet UILabel *communityStatsLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityHelpedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityHelpedLabel;
@end

@implementation BMEBlindMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.connectToCommunityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.pointsCommunitySightedLabel.colors =
    self.pointsCommunityBlindLabel.colors =
    self.pointsCommunityHelpedLabel.colors = @{ @(0.0f) : [UIColor lightTextColor],
                                                @(1.0f) : [UIColor whiteColor] };
    
    [[BMEClient sharedClient] loadCommunityStatsPointsCompletion:^(BMECommunityStats *stats, NSError *error) {
        if (error) {
            NSLog(@"Could not load point for days: %@", error);
        }
        [self updateToCommunityStats:stats];
        self.communityStatsView.isAccessibilityElement = YES;
    }];
}

- (void)shouldLocalize {
    [self.connectToCommunityButton setTitle:MKLocalizedFromTable(BME_BLIND_MAIN_CONNECT_TO_COMMUNITY, BMEBlindMainLocalizationTable) forState:UIControlStateNormal];
    
    self.communityStatsLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_DESCRIPTION, BMEHelperMainLocalizationTable);
    self.descriptionCommunitySightedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_SIGHTED, BMEHelperMainLocalizationTable);
    self.descriptionCommunityBlindLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_BLIND, BMEHelperMainLocalizationTable);
    self.descriptionCommunityHelpedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_HELPED, BMEHelperMainLocalizationTable);
    
    [self updateToCommunityStats:nil];
}


#pragma mark -
#pragma mark Private Methods

- (IBAction)connectToCommunityButtonPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:BMEInitiateCallIfPossibleNotification object:self];
}


#pragma mark - Stats

- (void)updateToCommunityStats:(BMECommunityStats *)stats
{
    if (stats) {
        [self.pointsCommunityBlindLabel setPoint:stats.blind.integerValue animated:YES];
        [self.pointsCommunitySightedLabel setPoint:stats.sighted.integerValue animated:YES];
        [self.pointsCommunityHelpedLabel setPoint:stats.helped.integerValue animated:NO];
    }
    
    self.communityStatsView.accessibilityLabel = [NSString stringWithFormat:@"%@. %@ %@. %@ %@. %@ %@.", self.communityStatsLabel.text, self.pointsCommunitySightedLabel.finalText, self.descriptionCommunitySightedLabel.text, self.pointsCommunityBlindLabel.finalText, self.descriptionCommunityBlindLabel.text, self.pointsCommunityHelpedLabel.finalText, self.descriptionCommunityHelpedLabel.text];
}

@end
