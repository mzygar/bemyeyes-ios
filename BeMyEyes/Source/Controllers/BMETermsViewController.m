//
//  BMETermsViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 31/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETermsViewController.h"

#define BMETermsUrl @"http://bemyeyes.org/terms"

@interface BMETermsViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightConstraint;
@end

@implementation BMETermsViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = self.navigationBarHeightConstraint.constant;
    self.webView.hidden = YES;
    self.webView.scrollView.contentInset = insets;
    self.webView.scrollView.scrollIndicatorInsets = insets;
    
    NSURL *url = [NSURL URLWithString:BMETermsUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.activityIndicatorView startAnimating];
}

#pragma mark -
#pragma mark Web View Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.webView.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

@end
