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
#import "BMEPointEntry.h"
#import "BMEPointLabel.h"
#import "BMEPointGraphView.h"
#import "BMEAppDelegate.h"
#import "NSDate+BMESnoozeRelativeDate.h"

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

@interface BMEHelperMainViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;

@property (weak, nonatomic) IBOutlet UILabel *pointDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointTitleLabel;
@property (weak, nonatomic) IBOutlet BMEPointLabel *pointLabel;
@property (weak, nonatomic) IBOutlet BMEPointGraphView *pointGraphView;
@property (weak, nonatomic) IBOutlet UILabel *failedLoadingPointLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryLoadingPointButton;

@property (weak, nonatomic) IBOutlet UILabel *snoozeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *snoozeStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *snoozeSliderView;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView0;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView25;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView50;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView75;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeStepImageView100;
@property (weak, nonatomic) IBOutlet UIImageView *snoozeThumbImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitleLabelLeadingMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitleLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreTitlePointSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep0CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep25CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep50CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep75CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeStep100CenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeThumbCenterMarginXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeThumbWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snoozeSliderLineWidthConstraint;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pointActivityIndicator;

@property (assign, nonatomic) NSUInteger totalPoint;
@property (strong, nonatomic) NSArray *pointEntries;

@property (strong, nonatomic) NSString *greetingFormat;

@property (assign, nonatomic) BOOL failedLoadingPoints;
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
     
    self.pointLabel.colors = @{ @(0.0f) : [UIColor colorWithRed:220.0f/255.0f green:38.0f/255.0f blue:38.0f/255.0f alpha:1.0f],
                                @(0.50f) : [UIColor colorWithRed:252.0f/255.0f green:197.0f/255.0f blue:46.0f/255.0f alpha:1.0f],
                                @(1.0f) : [UIColor colorWithRed:117.0f/255.0f green:197.0f/255.0f blue:27.0f/255.0f alpha:1.0f] };
 
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    [self displayGreeting];
    
    [self snapSnoozeSliderToStep:BMESnoozeStep0 animated:NO];
    
    [self reloadPoints];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.pointEntries = nil;
    self.greetingFormat = nil;
}

- (void)shouldLocalize {
    self.snoozeTitleLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_SNOOZE_HEADLINE, BMEHelperMainLocalizationTable);
    self.pointDescriptionLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_POINT_DESCRIPTION, BMEHelperMainLocalizationTable);
    self.pointTitleLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_POINT_TITLE, BMEHelperMainLocalizationTable);
    self.failedLoadingPointLabel.text = MKLocalizedFromTable(BME_HELPER_MAIN_LOADING_POINT_FAILED, BMEHelperMainLocalizationTable);
    [self.retryLoadingPointButton setTitle:MKLocalizedFromTable(BME_HELPER_MAIN_RETRY_LOADING_POINT, BMEHelperMainLocalizationTable) forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)retryLoadingPointsButtonPressed:(id)sender {
    [self reloadPoints];
}

- (void)displayGreeting {
    if (!self.greetingFormat) {
        self.greetingFormat = [self randomGreetingFormat];
    }
    
    if (self.greetingFormat) {
        NSString *name = [BMEClient sharedClient].currentUser.firstName;
        self.greetingLabel.text = [NSString stringWithFormat:self.greetingFormat, name];
    } else {
        self.greetingLabel.text = nil;
    }
}

- (NSString *)randomGreetingFormat {
    NSArray *greetingFormats = @[ MKLocalizedFromTable(BME_HELPER_MAIN_GREETING_1, BMEHelperMainLocalizationTable),
                                  MKLocalizedFromTable(BME_HELPER_MAIN_GREETING_2, BMEHelperMainLocalizationTable),
                                  MKLocalizedFromTable(BME_HELPER_MAIN_GREETING_3, BMEHelperMainLocalizationTable),
                                  MKLocalizedFromTable(BME_HELPER_MAIN_GREETING_4, BMEHelperMainLocalizationTable),
                                  MKLocalizedFromTable(BME_HELPER_MAIN_GREETING_5, BMEHelperMainLocalizationTable) ];
    if (greetingFormats) {
        NSString *greetingFormat = greetingFormats[arc4random() % [greetingFormats count]];
        return greetingFormat;
    }
    
    return nil;
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

- (void)layoutPoint {
    NSString *pointText = [NSString stringWithFormat:@"%i", self.totalPoint];
    CGRect pointRect = [pointText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : self.pointLabel.font } context:nil];
    self.pointLabelWidthConstraint.constant = CGRectGetWidth(pointRect) * 1.20f; // Add extra width for zoom animation
    [self.view layoutIfNeeded];
    
    CGFloat totalWidth = self.scoreTitleLabelWidthConstraint.constant + self.scoreTitlePointSpaceConstraint.constant + self.pointLabelWidthConstraint.constant;
    self.scoreTitleLabelLeadingMarginConstraint.constant = (CGRectGetWidth(self.view.bounds) - totalWidth) * 0.50f;
    [self.view layoutIfNeeded];
}

- (void)reloadPoints {
    [self.pointActivityIndicator startAnimating];
    [UIView animateWithDuration:0.30f animations:^{
        self.failedLoadingPointLabel.alpha = 0.0f;
        self.retryLoadingPointButton.alpha = 0.0f;
        self.pointTitleLabel.alpha = 0.0f;
        self.pointLabel.alpha = 0.0f;
        self.pointGraphView.alpha = 0.0f;
    }];
    
    // Assume we didn't fail
    self.failedLoadingPoints = NO;
    
    __block BOOL totalLoaded = NO;
    __block BOOL daysLoaded = NO;
    
    void(^completion)(void) = ^{
        [self.pointActivityIndicator stopAnimating];
        
        if (self.failedLoadingPoints) {
            [self showFailedLoadingPoint];
        } else if (totalLoaded && daysLoaded) {
            [self showPoint];
        }
    };
    
    [[BMEClient sharedClient] loadTotalPoint:^(NSUInteger points, NSError *error) {
        if (error) {
            NSLog(@"Could not load total point: %@", error);
            
            self.failedLoadingPoints = YES;
        } else {
            totalLoaded = YES;
            self.totalPoint = points;
        }
        
        completion();
    }];
    
    [[BMEClient sharedClient] loadPointForDays:30 completion:^(NSArray *entries, NSError *error) {
        if (error) {
            NSLog(@"Could not load point for days: %@", error);
            
            self.failedLoadingPoints = YES;
        } else {
            daysLoaded = YES;
            self.pointEntries = entries;
        }
        
        completion();
    }];
}

- (void)showPoint {
    for (BMEPointEntry *pointEntry in self.pointEntries) {
        [self.pointGraphView addPoint:pointEntry.point atDate:pointEntry.date];
    }
    
    [self.pointGraphView draw];
    [self.pointLabel setPoint:self.totalPoint animated:YES];
    [self layoutPoint];

    self.pointDescriptionLabel.alpha = 0.0f;
    self.pointTitleLabel.alpha = 0.0f;
    self.pointLabel.alpha = 0.0f;
    self.pointGraphView.alpha = 0.0f;
    
    self.pointTitleLabel.hidden = NO;
    self.pointLabel.hidden = NO;
    self.pointGraphView.hidden = NO;
    
    [UIView animateWithDuration:0.30f animations:^{
        self.pointDescriptionLabel.alpha = 1.0f;
        self.pointTitleLabel.alpha = 1.0f;
        self.pointLabel.alpha = 1.0f;
        self.pointGraphView.alpha = 1.0f;
        self.failedLoadingPointLabel.alpha = 0.0f;
        self.retryLoadingPointButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.failedLoadingPointLabel.hidden = YES;
        self.retryLoadingPointButton.hidden = YES;
    }];
}

- (void)showFailedLoadingPoint {
    self.failedLoadingPointLabel.alpha = 0.0f;
    self.failedLoadingPointLabel.hidden = NO;
    
    self.retryLoadingPointButton.alpha = 0.0f;
    self.retryLoadingPointButton.hidden = NO;
    
    [UILabel animateWithDuration:0.30f animations:^{
        self.pointDescriptionLabel.alpha = 0.0f;
        self.pointTitleLabel.alpha = 0.0f;
        self.pointLabel.alpha = 0.0f;
        self.pointGraphView.alpha = 0.0f;
        self.failedLoadingPointLabel.alpha = 1.0f;
        self.retryLoadingPointButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.pointTitleLabel.hidden = YES;
        self.pointLabel.hidden = YES;
        self.pointGraphView.hidden = YES;
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
    [self displayGreeting];
}

- (void)didUpdatePoint:(NSNotification *)notification {
    [self reloadPoints];
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (self.failedLoadingPoints) {
        [self reloadPoints];
    }
}

@end
