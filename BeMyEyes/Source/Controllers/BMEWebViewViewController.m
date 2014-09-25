//
//  BMEWebViewViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/05/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEWebViewViewController.h"

@interface BMEWebViewViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightConstraint;
@end

@implementation BMEWebViewViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = self.navigationBarHeightConstraint.constant;
    self.webView.hidden = YES;
    self.webView.scrollView.contentInset = insets;
    self.webView.scrollView.scrollIndicatorInsets = insets;
}

#pragma mark -
#pragma mark Public Methods

- (void)loadURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark -
#pragma mark Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.webView.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

@end
