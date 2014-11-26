//
//  BMEFrontPageViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEFrontPageViewController.h"
#import "BMEPointLabel.h"
#import "BMECommunityStats.h"

@interface BMEFrontPageViewController ()
@property (weak, nonatomic) IBOutlet UIView *logoContainer;
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *askForRoleLabel;
@property (weak, nonatomic) IBOutlet Button *sightedRoleButton;
@property (weak, nonatomic) IBOutlet Button *blindRoleButton;
@property (weak, nonatomic) IBOutlet UIButton *alreadyRegisteredButton;
@property (weak, nonatomic) IBOutlet UIView *communityStatsView;
@property (weak, nonatomic) IBOutlet UILabel *communityStatsLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityHelpedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityHelpedLabel;
@property (strong, nonatomic) NSArray *_accessibilityElements;

@property (assign, nonatomic) BMERole role;
@end

static NSString *const BMEHelperSegue = @"Helper";
static NSString *const BMEBlindSegue = @"Blind";
static NSString *const BMELoginSegue = @"Login";

@implementation BMEFrontPageViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    self.sightedRoleButton.font = [UIFont boldSystemFontOfSize:24];
    self.blindRoleButton.font = [UIFont boldSystemFontOfSize:24];
    
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
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLoginIfPossible:) name:BMEGoToLoginIfPossibleNotification object:nil];
}

- (void)shouldLocalize {
    self.appNameLabel.text = MKLocalizedFromTable(BME_FRONT_PAGE_APP_NAME, BMEFrontPageLocalizationTable);
    
    self.askForRoleLabel.text = MKLocalizedFromTable(BME_FRONT_PAGE_ASK_FOR_ROLE, BMEFrontPageLocalizationTable);
    
    self.sightedRoleButton.title = MKLocalizedFromTable(BME_FRONT_PAGE_SIGHTED_ROLE, BMEFrontPageLocalizationTable);
    self.blindRoleButton.title = MKLocalizedFromTable(BME_FRONT_PAGE_BLIND_ROLE, BMEFrontPageLocalizationTable);
    [self.alreadyRegisteredButton setTitle:MKLocalizedFromTable(BME_FRONT_PAGE_ALREADY_REGISTERED, BMEFrontPageLocalizationTable) forState:UIControlStateNormal];
    
    self.communityStatsLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_DESCRIPTION, BMEHelperMainLocalizationTable);
    self.descriptionCommunitySightedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_SIGHTED, BMEHelperMainLocalizationTable);
    self.descriptionCommunityBlindLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_BLIND, BMEHelperMainLocalizationTable);
    self.descriptionCommunityHelpedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_HELPED, BMEHelperMainLocalizationTable);
    
    [self updateToCommunityStats:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)didTapSighted:(id)sender {
    [self performHelperSegue];
}

- (IBAction)didTapBlind:(id)sender {
    [self performBlindSegue];
}

- (void)performHelperSegue {
    [self performSegueWithIdentifier:BMEHelperSegue sender:self];
}

- (void)performBlindSegue {
    [self performSegueWithIdentifier:BMEBlindSegue sender:self];
}

- (void)performLoginSegue {
    [self performSegueWithIdentifier:BMELoginSegue sender:self];
}


#pragma mark - Private

- (void)updateToCommunityStats:(BMECommunityStats *)stats
{
    if (stats) {
        [self.pointsCommunityBlindLabel setPoint:stats.blind.integerValue animated:YES];
        [self.pointsCommunitySightedLabel setPoint:stats.sighted.integerValue animated:YES];
        [self.pointsCommunityHelpedLabel setPoint:stats.helped.integerValue animated:NO];
    }
    
    self.communityStatsView.accessibilityLabel = [NSString stringWithFormat:@"%@. %@ %@. %@ %@. %@ %@.", self.communityStatsLabel.text, self.pointsCommunitySightedLabel.finalText, self.descriptionCommunitySightedLabel.text, self.pointsCommunityBlindLabel.finalText, self.descriptionCommunityBlindLabel.text, self.pointsCommunityHelpedLabel.finalText, self.descriptionCommunityHelpedLabel.text];
}


#pragma mark - Notifications

- (void)goToLoginIfPossible:(NSNotification *)notification {
    [self performLoginSegue];
}

@end
