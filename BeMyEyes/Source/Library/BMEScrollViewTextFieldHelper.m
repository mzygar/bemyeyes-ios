//
//  BMEScrollViewTextFieldHelper.m
//  BeMyEyes
//
//  Created by Tobias Due Munk on 29/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEScrollViewTextFieldHelper.h"

@interface BMEScrollViewTextFieldHelper () <UIScrollViewDelegate>

@property (weak, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) CGSize keyboardSize;
@property (assign, nonatomic, getter = hasScrolled) BOOL scrolled;

@end


@implementation BMEScrollViewTextFieldHelper


- (instancetype)initWithScrollview:(UIScrollView *)scrollView inViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.scrollView = scrollView;
        self.scrollView.delegate = self;
        
        self.viewController = viewController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeView = nil;
}

#pragma mark - Setters and Getters

- (void)setActiveView:(UIView *)activeTextField
{
    if (activeTextField != _activeView) {
        _activeView = activeTextField;
        
        [self scrollIfNecessaryAnimated:YES];
    }
}

#pragma mark - UIViewController status bar state

- (BOOL)prefersStatusBarHidden
{
    return self.hasScrolled ? YES : NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}


#pragma mark -

- (void)scrollIfNecessaryAnimated:(BOOL)animated {
    CGRect textFieldFrame = [self.activeView convertRect:self.activeView.frame toView:self.scrollView];
    
    CGFloat textFieldTop = CGRectGetMinY(textFieldFrame);
    CGFloat topYScrollOffset = textFieldTop - 20.0f;
    CGFloat maxYScrollOffset = MAX((self.scrollView.contentSize.height + self.scrollView.contentInset.top + self.scrollView.contentInset.bottom) - self.scrollView.frame.size.height, 0);
    CGFloat yScrollOffset = MIN(topYScrollOffset, maxYScrollOffset);
    yScrollOffset = MAX(yScrollOffset, 0);
    
    if (yScrollOffset > 0) {
        CGPoint scrollOffset = CGPointMake(0.0f, yScrollOffset);
        [self.scrollView setContentOffset:scrollOffset animated:animated];
    } else {
        [self resetScrollIfNecessary];
    }
}

- (void)resetScrollIfNecessary {
    if (self.hasScrolled) {
        [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    }
}

#pragma mark - Notifications

- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect oldKeyboardFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect oldConvertedKeyboardFrame = [self.viewController.view convertRect:oldKeyboardFrame fromView:self.viewController.view.window];
    
    CGRect newKeyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newConvertedKeyboardFrame = [self.viewController.view convertRect:newKeyboardFrame fromView:self.viewController.view.window];
    self.keyboardSize = newConvertedKeyboardFrame.size;
    
    BOOL wasShown = [self keyboardIsShownForRect:oldConvertedKeyboardFrame];
    BOOL willBeShown = [self keyboardIsShownForRect:newConvertedKeyboardFrame];
    
    CGFloat bottom = willBeShown ? self.keyboardSize.height : 0;
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = bottom;
    self.scrollView.contentInset = contentInset;
    
    UIEdgeInsets scrollIndicatorInsets = self.scrollView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = bottom;
    self.scrollView.contentInset = scrollIndicatorInsets;
    
    BOOL animate = NO; // Don't animate when called from notification block
    if (wasShown && willBeShown) {
        animate = YES; // If frame just changed, e.g. hide or show suggestion bar/QuickType bar
    }
    [self scrollIfNecessaryAnimated:animate];
}


#pragma mark - 

- (BOOL)keyboardIsShownForRect:(CGRect)rect {
    return rect.origin.y < [UIScreen mainScreen].bounds.size.height;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrolled = scrollView.contentOffset.y > 0;
}

#pragma mark - Setters and Getters

- (void)setScrolled:(BOOL)scrolled
{
    if (scrolled != _scrolled) {
        _scrolled = scrolled;
        
        [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
            [self.viewController setNeedsStatusBarAppearanceUpdate];
        } completion:nil];
    }
}

@end
