//
//  BMESignUpViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 22/02/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMESignUpViewController.h"

@interface BMESignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) UITextField *activeTextField;
@property (assign, nonatomic) CGSize keyboardSize;
@end

@implementation BMESignUpViewController

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.activeTextField = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)signUpButtonPressed:(id)sender {
    
}

- (void)scrollIfNecessary {
    CGRect rect = self.scrollView.frame;
    rect.size.height -= self.keyboardSize.height;
    
    CGRect textFieldFrame = [self.activeTextField convertRect:self.activeTextField.frame toView:self.scrollView];
    if (CGRectGetMaxY(textFieldFrame) > CGRectGetMaxY(rect)) {
        CGRect visibleRect = CGRectZero;
        visibleRect.origin = CGPointMake(0.0f, CGRectGetMinY(textFieldFrame));
        visibleRect.size = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(textFieldFrame) + 20.0f);
        
        CGPoint scrollOffset = CGPointMake(0.0f, CGRectGetMaxY(textFieldFrame) - CGRectGetMaxY(rect));
        [self.scrollView setContentOffset:scrollOffset animated:YES];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
    [self scrollIfNecessary];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect convertedKeyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    self.keyboardSize = convertedKeyboardFrame.size;
    
    [self scrollIfNecessary];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self.scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
