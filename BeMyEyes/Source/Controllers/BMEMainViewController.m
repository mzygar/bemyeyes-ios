//
//  BMEMainViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 09/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEMainViewController.h"
#import "BMEClient.h"
#import "BMEUser.h"

@interface BMEMainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (assign, nonatomic, getter = isLoggedOut) BOOL loggedOut;
@end

@implementation BMEMainViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogOut:) name:BMEDidLogOutNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch ([BMEClient sharedClient].currentUser.role) {
        case BMERoleHelper:
            [self displayHelperView];
            break;
        case BMERoleBlind:
            [self displayBlindView];
            break;
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    if (self.isLoggedOut) {
        self.view.window.rootViewController = [self.view.window.rootViewController.storyboard instantiateInitialViewController];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)popController:(UIStoryboardSegue *)segue { }

- (void)displayHelperView {
    [self displayMainControllerWithIdentifier:BMEMainHelperControllerIdentifier];
}

- (void)displayBlindView {
    [self displayMainControllerWithIdentifier:BMEMainBlindControllerIdentifier];
}

- (void)displayMainControllerWithIdentifier:(NSString *)identifier {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    [self addChildViewController:controller];
    [self.view insertSubview:controller.view belowSubview:self.settingsButton];
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -
#pragma mark Notifications

- (void)didLogOut:(NSNotification *)notification {
    self.loggedOut = YES;
}

@end
