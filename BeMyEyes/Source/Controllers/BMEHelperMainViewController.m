//
//  BMEHelperMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 15/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEHelperMainViewController.h"
#import "BMEClient.h"
#import "BMEUser.h"
#import "BMEUserLevel.h"
#import "BMEPointEntry.h"
#import "BMECommunityStats.h"
#import "BMEPointLabel.h"
#import "BMEPointGraphView.h"
#import "BMEAppDelegate.h"
#import "NSDate+BMESnoozeRelativeDate.h"
#import "BMEPointsTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BeMyEyes-Swift.h"

#define BMEHelperSnoozeAmount0 0.0f
#define BMEHelperSnoozeAmount25 3600.0f
#define BMEHelperSnoozeAmount50 6 * 3600.0f
#define BMEHelperSnoozeAmount75 24 * 3600.0f
#define BMEHelperSnoozeAmount100 7 * 24 * 3600.0f

typedef NS_ENUM(NSInteger, BMESnoozeStep) {
    BMESnoozeStep0 = 0,
    BMESnoozeStep25,
    BMESnoozeStep50,
    BMESnoozeStep75,
    BMESnoozeStep100
};

@interface BMEHelperMainViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsHelpedPersonsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsHelpedPersonsDescriptionLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsTotalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *failedLoadingPointLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryLoadingPointButton;
@property (weak, nonatomic) IBOutlet PointsBarView *pointsBarView;

@property (weak, nonatomic) IBOutlet UILabel *snoozeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *snoozeStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *snoozeSliderView;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView0;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView25;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView50;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView75;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView100;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeThumbImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep0CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep25CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep50CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep75CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep100CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeThumbCenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeThumbWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeSliderLineWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *communityStatsContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *communityStatsBottomConstraint;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunitySightedLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityBlindLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointsCommunityHelpedLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionCommunityHelpedLabel;

@property (strong, nonatomic) NSArray *pointEntries;

@property (assign, nonatomic) BOOL failedLoadingPoints;

@property (assign, nonatomic) BOOL scrolled;

@end

@implementation BMEHelperMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateProfile:) name:BMEDidUpdateProfileNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdatePoint:) name:BMEDidUpdatePointNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MKLocalization registerForLocalization:self];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        self.tableView.estimatedRowHeight = self.tableView.rowHeight;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
     
    self.pointsHelpedPersonsLabel.colors =
    self.pointsTotalLabel.colors = @{ @(0.0f) : [UIColor lightTextColor],
                                      @(1.0f) : [UIColor whiteColor] };
    self.pointsCommunitySightedLabel.colors =
    self.pointsCommunityBlindLabel.colors =
    self.pointsCommunityHelpedLabel.colors = @{ @(0.0f) : [UIColor darkTextColor],
                                                @(1.0f) : [UIColor blackColor] };
 
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    [self updateToProfile];
    
    [self snapSnoozeSliderToStep:BMESnoozeStep0 animated:NO];
    
    [self updatePointsAnimated:NO];
    [self reloadPoints];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.pointEntries = nil;
}

- (void)shouldLocalize {
//    self.snoozeTitleLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_SNOOZE_HEADLINE, BMEHelperMainLocalizationTable);
    self.pointsTotalDescriptionLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_TOTAL_POINT_DESCRIPTION, BMEHelperMainLocalizationTable);
    self.pointsHelpedPersonsDescriptionLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_HELPED_POINT_DESCRIPTION, BMEHelperMainLocalizationTable);
    self.descriptionCommunitySightedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_SIGHTED, BMEHelperMainLocalizationTable);
    self.descriptionCommunityBlindLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_BLIND, BMEHelperMainLocalizationTable);
    self.descriptionCommunityHelpedLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_COMMUNITY_NETWORK_HELPED, BMEHelperMainLocalizationTable);
    self.failedLoadingPointLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_LOADING_POINT_FAILED, BMEHelperMainLocalizationTable);
    [self.retryLoadingPointButton setTitle:MKLocalizedFromTable(BME_HELPER_MAIN_RETRY_LOADING_POINT, BMEHelperMainLocalizationTable) forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat communityHeight = self.communityStatsContainer.frame.size.height;
    CGFloat contentHeight = self.tableView.contentSize.height;
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat bottomInset = 0;
    CGFloat hiddenHeight = contentHeight - (viewHeight - communityHeight);
    if (0 < hiddenHeight) {
        bottomInset = viewHeight - contentHeight + hiddenHeight/2;
    }
    
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom = bottomInset;
    self.tableView.contentInset = contentInsets;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = bottomInset;
    self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden
{
    return self.scrolled;
}

#pragma mark - Setters and Getters

- (void)setScrolled:(BOOL)scrolled
{
    if (scrolled != _scrolled) {
        _scrolled = scrolled;
        
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)retryLoadingPointsButtonPressed:(id)sender {
    [self reloadPoints];
}

- (void)updateToProfile {
    BMEUser *user = [BMEClient sharedClient].currentUser;
    NSString *name = user.firstName;
    self.nameLabel.text = name;

    self.profileImageView.image = nil;
    NSNumber *facebookId = (NSNumber *)user.userId;
    if (facebookId) {
        NSURL *url = [FacebookHelper urlForId:facebookId.integerValue];
        [self.profileImageView sd_setImageWithURL:url];
    } else {
        [self.profileImageView sd_cancelCurrentImageLoad];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint pos = [gestureRecognizer locationInView:self.snoozeSliderView];
        CGFloat newPos = pos.x - self.snoozeThumbWidthConstraint.constant * 0.50f;
        self.snoozeThumbCenterMarginXConstraint.constant = MIN(MAX(newPos, self.snoozeStep0CenterMarginXConstraint.constant), self.snoozeStep100CenterMarginXConstraint.constant);
        [self.view layoutIfNeeded];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateFailed ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self snapSnoozeSliderThumb:YES];
    }
}

- (void)snapSnoozeSliderThumb:(BOOL)animated {
    CGFloat pos = self.snoozeThumbCenterMarginXConstraint.constant;
    CGFloat lineWidth = self.snoozeSliderLineWidthConstraint.constant;
    if (pos < lineWidth * 0.125f) {
        [self snapSnoozeSliderToStep:BMESnoozeStep0 animated:animated];
    } else if (pos < lineWidth * 0.375f) {
        [self snapSnoozeSliderToStep:BMESnoozeStep25 animated:animated];
    } else if (pos < lineWidth * 0.625f) {
        [self snapSnoozeSliderToStep:BMESnoozeStep50 animated:animated];
    } else if (pos < lineWidth * 0.875f) {
        [self snapSnoozeSliderToStep:BMESnoozeStep75 animated:animated];
    } else {
        [self snapSnoozeSliderToStep:BMESnoozeStep100 animated:animated];
    }
}

- (void)snapSnoozeSliderToStep:(BMESnoozeStep)step animated:(BOOL)animated {
    CGFloat snappedPos = 0.0f;
    NSTimeInterval snoozeAmount = 0.0f;
    switch (step) {
        case BMESnoozeStep0:
            snappedPos = self.snoozeStep0CenterMarginXConstraint.constant;
            snoozeAmount = BMEHelperSnoozeAmount0;
            break;
        case BMESnoozeStep25:
            snappedPos = self.snoozeStep25CenterMarginXConstraint.constant;
            snoozeAmount = BMEHelperSnoozeAmount25;
            break;
        case BMESnoozeStep50:
            snappedPos = self.snoozeStep50CenterMarginXConstraint.constant;
            snoozeAmount = BMEHelperSnoozeAmount50;
            break;
        case BMESnoozeStep75:
            snappedPos = self.snoozeStep75CenterMarginXConstraint.constant;
            snoozeAmount = BMEHelperSnoozeAmount75;
            break;
        case BMESnoozeStep100:
            snappedPos = self.snoozeStep100CenterMarginXConstraint.constant;
            snoozeAmount = BMEHelperSnoozeAmount100;
            break;
        default:
            break;
    }
    
    if (snoozeAmount > 0) {
        NSString *snoozeAmountText = [[NSDate dateWithTimeIntervalSinceNow:snoozeAmount] BMESnoozeRelativeDate];
        self.snoozeStatusLabel.text = MKLocalizedFromTableWithFormat(BME_HELPER_MAIN_SNOOZE_STATUS_TEXT, BMEHelperMainLocalizationTable, snoozeAmountText);
    } else {
        self.snoozeStatusLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_SNOOZE_STATUS_NOT_SNOOZING_TEXT, BMEHelperMainLocalizationTable);
    }
    
    self.snoozeThumbCenterMarginXConstraint.constant = snappedPos;
    
    if (animated) {
        [UIView animateWithDuration:0.30f delay:0.0f usingSpringWithDamping:0.60f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)updatePointsAnimated:(BOOL)animated {
    BMEUser *user = [BMEClient sharedClient].currentUser;
    self.levelLabel.text = MKLocalizedFromTable(user.currentLevel.localizableKeyForTitle, BMEHelperMainLocalizationTable);
    
    [self.pointsHelpedPersonsLabel setPoint:user.peopleHelped.integerValue animated:YES];
    [self.pointsTotalLabel setPoint:user.totalPoints.integerValue animated:YES];
    
    self.pointsBarView.text = [NSString stringWithFormat:MKLocalizedFromTable(BME_HELPER_MAIN_LEVEL_POINTS_NEXT_DESCRIPTION, BMEHelperMainLocalizationTable), user.pointsToNextLevel];
    self.pointsBarView.progress = user.levelProgress;
    
    self.pointEntries = user.lastPointEntries;
    [self.tableView reloadData];
}

- (void)reloadPoints {
    [[BMEClient sharedClient] loadUserStatsCompletion:^(BMEUser *user, NSError *error) {
        if (error) {
            NSLog(@"Could not load total point: %@", error);
        } else {
            [self updatePointsAnimated:YES];
        }
    }];
    
    [[BMEClient sharedClient] loadCommunityStatsPointsCompletion:^(BMECommunityStats *stats, NSError *error) {
        if (error) {
            NSLog(@"Could not load point for days: %@", error);
        } else {
            [self.pointsCommunityBlindLabel setPoint:stats.blind.integerValue animated:YES];
            [self.pointsCommunitySightedLabel setPoint:stats.sighted.integerValue animated:YES];
            [self.pointsCommunityHelpedLabel setPoint:stats.helped.integerValue animated:YES];
        }
    }];
}

#pragma mark -
#pragma mark Gesture Recognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint pos = [gestureRecognizer locationInView:self.snoozeSliderView];
    return CGRectContainsPoint(self.snoozeThumbImageView.frame, pos);
}

#pragma mark -
#pragma mark Notifications

- (void)didUpdateProfile:(NSNotification *)notification {
    [self updateToProfile];
}

- (void)didUpdatePoint:(NSNotification *)notification {
    [self reloadPoints];
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (self.failedLoadingPoints) {
        [self reloadPoints];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat distanceFromTop = scrollView.contentOffset.y;
    self.communityStatsBottomConstraint.constant = MIN(0, -distanceFromTop);
    
    self.scrolled = distanceFromTop > 20;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMEPointsTableViewCell *cell = (BMEPointsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PointsCellID"];
    
    BMEPointEntry *pointEntry = self.pointEntries[indexPath.row];
    
    cell.pointsDescription = MKLocalizedFromTable(pointEntry.localizableKeyForTitle, BMEHelperMainLocalizationTable);
    cell.date = pointEntry.date;
    cell.points = @(pointEntry.point);
    
    return cell;
}

@end
