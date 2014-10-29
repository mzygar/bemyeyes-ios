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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeTextField = nil;
}

#pragma mark - Setters and Getters

- (void)setActiveTextField:(UITextField *)activeTextField
{
    if (activeTextField != _activeTextField) {
        _activeTextField = activeTextField;
        
        [self scrollIfNecessary];
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

- (void)scrollIfNecessary {
    CGRect textFieldFrame = [self.activeTextField convertRect:self.activeTextField.frame toView:self.scrollView];
    
    CGFloat textFieldTop = CGRectGetMinY(textFieldFrame);
    CGFloat topYScrollOffset = textFieldTop - 20.0f;
    CGFloat maxYScrollOffset = MAX((self.scrollView.contentSize.height + self.scrollView.contentInset.top + self.scrollView.contentInset.bottom) - self.scrollView.frame.size.height, 0);
    CGFloat yScrollOffset = MIN(topYScrollOffset, maxYScrollOffset);
    yScrollOffset = MAX(yScrollOffset, 0);
    
    if (yScrollOffset > 0) {
        CGPoint scrollOffset = CGPointMake(0.0f, yScrollOffset);
        [self.scrollView setContentOffset:scrollOffset animated:YES];
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

- (void)keyboardDidChange:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.viewController.view convertRect:keyboardFrame fromView:self.viewController.view.window];
    self.keyboardSize = convertedKeyboardFrame.size;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboardSize.height, 0);
    [self scrollIfNecessary];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    
    [self resetScrollIfNecessary];
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
