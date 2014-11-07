//
//  BMEScrollViewTextFieldHelper.h
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMEScrollViewTextFieldHelper : NSObject

@property (readonly, nonatomic, getter = hasScrolled) BOOL scrolled;
@property (strong, nonatomic) UIView *activeView;

- (instancetype)initWithScrollview:(UIScrollView *)scrollView inViewController:(UIViewController *)viewController;

- (BOOL)prefersStatusBarHidden;
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation;

@end
