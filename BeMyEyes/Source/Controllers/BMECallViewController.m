//
//  BMECallViewController.m
//  BeMyEyes
//
//  Created by Simon Støvring on 23/03/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMECallViewController.h"
#import <Opentok/Opentok.h>
#import "BMEClient.h"
#import "BMEUser.h"
#import "BMERequest.h"
#import "BMESpeaker.h"

@interface BMECallViewController () <OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate>
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSString *sessionId;
@property (strong, nonatomic) NSString *token;

@property (strong, nonatomic) OTSession *session;
@property (strong, nonatomic) OTPublisher *publisher;
@property (strong, nonatomic) OTSubscriber *subscriber;
@property (strong, nonatomic) OTVideoView *videoView;

@property (assign, nonatomic, getter = isDisconnecting) BOOL disconnecting;
@end

@implementation BMECallViewController

#pragma mark -
#pragma mark Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    if (self.callMode == BMECallModeCreate) {
        [self createNewRequest];
    } else {
        [self answerRequestWithShortId:self.shortId];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self changeAudioCategoryToDefault];
}

- (void)dealloc {
    self.shortId = nil;
    self.sessionId = nil;
    self.token = nil;
    self.session = nil;
    self.publisher = nil;
    self.videoView = nil;
}

#pragma mark -
#pragma mark Private Methods

- (IBAction)cancelButtonPressed:(id)sender {
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_DISCONNECTING", @"BMECallViewController", @"Status when disconnecting");
    [self changeStatus:statusText];
    [self disconnect];
}

- (void)createNewRequest {
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_CREATING_REQUEST", @"BMECallViewController", @"Status when creating request");
    [self changeStatus:statusText];
    
    [[BMEClient sharedClient] createRequestWithSuccess:^(BMERequest *request) {
        self.shortId = request.shortId;
        self.sessionId = request.openTok.sessionId;
        self.token = request.openTok.token;
        [self connect];
    } failure:^(NSError *error) {
        NSString *title = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_TITLE", @"BMECallViewController", @"Title in alert showed when failed creating request");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_MESSAGE", @"BMECallViewController", @"Message in alert showed when failed creating request");
        NSString *cancel = NSLocalizedStringFromTable(@"ALERT_FAILED_CREATING_REQUEST_CANCEL", @"BMECallViewController", @"Cancel in alert showed when failed creating request");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
        [alertView show];
        
        NSLog(@"Request could not be created: %@", error);
        
        [self dismiss];
    }];
}

- (void)answerRequestWithShortId:(NSString *)shortId {
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_ANSWERING_REQUEST", @"BMECallViewController", @"Status when answering request");
    [self changeStatus:statusText];
    
    [[BMEClient sharedClient] answerRequestWithShortId:shortId success:^(BMERequest *request) {
        self.shortId = request.shortId;
        self.sessionId = request.openTok.sessionId;
        self.token = request.openTok.token;
        [self connect];
    } failure:^(NSError *error) {
        if ([error code] == BMEClientErrorRequestAlreadyAnswered) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_ANSWERED_TITLE", @"BMECallViewController", @"Title in alert view shown when failed answering request because the request has already been answered");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_ANSWERED_MESSAGE", @"BMECallViewController", @"Message in alert view shown when failed answering request because the request has already been answered");
            NSString *cancel = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_ANSWERED_CANCEL", @"BMECallViewController", @"Title of cancel button in alert view shown when failed answering request because the request has already been answered");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([error code] == BMEClientErrorRequestStopped) {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_STOPPED_TITLE", @"BMECallViewController", @"Title in alert view shown when failed answering request because the request has been stopped");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_STOPPED_MESSAGE", @"BMECallViewController", @"Message in alert view shown when failed answering request because the request has been stopped");
            NSString *cancel = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_REQUEST_STOPPED_CANCEL", @"BMECallViewController", @"Title of cancel button in alert view shown when failed answering request because the request has been stopped");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_UNKNOWN_TITLE", @"BMECallViewController", @"Title in alert view shown when failed answering request for an unknown reason");
            NSString *message = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_UNKNOWN_MESSAGE", @"BMECallViewController", @"Message in alert view shown when failed answering request for an unknown reason");
            NSString *cancel = NSLocalizedStringFromTable(@"ALERT_FAILED_ANSWERING_UNKNOWN_CANCEL", @"BMECallViewController", @"Title of cancel button in alert view shown when failed answering request for an unknown reason");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        NSLog(@"Request could not be answered: %@", error);
        
        [self dismiss];
    }];
}

- (void)connect {
    NSLog(@"Connect to session: %@", self.shortId);
    NSLog(@" - sessionId: %@", self.sessionId);
    NSLog(@" - token: %@", self.token);
    
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_CONNECTING", @"BMECallViewController", @"Status when connecting");
    [self changeStatus:statusText];
    
    self.session = [[OTSession alloc] initWithSessionId:self.sessionId delegate:self];
    [self.session connectWithApiKey:BMEOpenTokAPIKey token:self.token];
}

- (void)disconnect {
    self.disconnecting = YES;
    
    [self.videoView removeFromSuperview];
    self.videoView = nil;
    
    void(^requestCompletion)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        NSLog(@"Completion");
        if (self.publisher && self.publisher.session == self.session) {
            NSLog(@"Unpublish");
            [self.session unpublish:self.publisher];
        }
        
        if (self.subscriber && self.subscriber.session == self.session) {
            NSLog(@"Close");
            [self.subscriber close];
        }
        
        if (self.session.connection) {
            NSLog(@"Disconnect");
            [self.session disconnect];
        } else {
            NSLog(@"Dismiss right away");
            [self dismiss];
        }
    };
    
    if (!self.subscriber && [self isUserHelper]) {
        [[BMEClient sharedClient] cancelAnswerForRequestWithShortId:self.shortId completion:requestCompletion];
    } else {
        [[BMEClient sharedClient] disconnectFromRequestWithShortId:self.shortId completion:requestCompletion];
    }
}

- (void)publish {
    self.publisher = [[OTPublisher alloc] initWithDelegate:self name:[BMEClient sharedClient].currentUser.firstName];
    self.publisher.cameraPosition = AVCaptureDevicePositionBack;
    self.publisher.publishAudio = YES;
    self.publisher.publishVideo = [self isUserBlind];
    [self.session publish:self.publisher];
}

- (void)subscribeToStream:(OTStream *)stream {
    self.subscriber = [[OTSubscriber alloc] initWithStream:stream delegate:self];
    self.subscriber.subscribeToAudio = YES;
    self.subscriber.subscribeToVideo = ![self isUserBlind];
}

- (void)displayViewForPublisher:(OTPublisher *)publisher {
    [self displayVideoView:publisher.view];
}

- (void)displayViewForSubscriber:(OTSubscriber *)subscriber {
    [self displayVideoView:subscriber.view];
}

- (void)displayVideoView:(OTVideoView *)videoView {
    [self.videoContainerView addSubview:videoView];
    [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.videoContainerView);
    }];
    
    self.videoView = videoView;
    self.videoView.toolbarView.hidden = YES;
}

- (void)changeStatus:(NSString *)string {
    self.statusLabel.hidden = NO;
    self.statusLabel.text = string;
    
    [self.activityIndicatorView startAnimating];
    
    if ([self isUserBlind]) {
        [BMESpeaker speak:string];
    }
}

- (void)hideStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    });
}

- (void)dismiss {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)changeAudioCategoryToDefault {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"Could not change audio category to default: %@", error);
    }
}

- (BOOL)isUserBlind {
    return [BMEClient sharedClient].currentUser.role == BMERoleBlind;
}

- (BOOL)isUserHelper {
    return [BMEClient sharedClient].currentUser.role == BMERoleHelper;
}

#pragma mark -
#pragma mark Session Delegate

- (void)sessionDidConnect:(OTSession *)session {
    if (!self.isDisconnecting) {
        NSString *statusText = NSLocalizedStringFromTable(@"STATUS_CONNECTION_ESTABLISHED", @"BMECallViewController", @"Status when connection is established");
        [self changeStatus:statusText];
        [self publish];
    }
}

- (void)sessionDidDisconnect:(OTSession *)session {
    [self dismiss];
    [self changeAudioCategoryToDefault];
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
    NSLog(@"Session failed: %@", error);
    
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_SESSION_FAILED", @"BMECallViewController", @"Status when session failed");
    [self changeStatus:statusText];
    
    if (self.session) {
        [self disconnect];
    } else {
        [self dismiss];
    }
}

- (void)session:(OTSession *)session didReceiveStream:(OTStream *)stream {
    if (!self.isDisconnecting) {
        // Make sure we don't subscribe to our own stream
        if (![stream.connection.connectionId isEqualToString:session.connection.connectionId]) {
            [self subscribeToStream:stream];
        }
    }
}

- (void)session:(OTSession *)session didDropStream:(OTStream *)stream {
    if ([self.subscriber.stream.streamId isEqualToString:stream.streamId]) {
        [self.subscriber close];
    }
    
    if (!self.isDisconnecting) {
        // If we are not disconnecting ourselves,
        // then the other part has disconnected
        NSString *title = NSLocalizedStringFromTable(@"ALERT_OTHER_PART_DISCONNECTED_TITLE", @"BMECallViewController", @"Title in alert shown when other part has disconnected");
        NSString *message = NSLocalizedStringFromTable(@"ALERT_OTHER_PART_DISCONNECTED_MESSAGE", @"BMECallViewController", @"Message in alert shown when other part has disconnected");
        NSString *cancel = NSLocalizedStringFromTable(@"ALERT_OTHER_PART_DISCONNECTED_CANCEL", @"BMECallViewController", @"Title of cancel button in alert shown when other part has disconnected");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
        [alertView show];
        
        [self disconnect];
    }
}

- (void)session:(OTSession *)session didCreateConnection:(OTConnection *)connection {
    
}

- (void)session:(OTSession *)session didDropConnection:(OTConnection *)connection {
    
}

#pragma mark -
#pragma mark Publisher Delegate

- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *statusText = NSLocalizedStringFromTable(@"STATUS_FAILED_PUBLISHING", @"BMECallViewController", @"Status when failed publishing");
        [self changeStatus:statusText];
    });
    
    if (self.session.connection) {
        [self disconnect];
    } else {
        [self dismiss];
    }
}

#pragma mark -
#pragma mark Subscriber Delegate

- (void)subscriberDidConnectToStream:(OTSubscriber *)subscriber {
    [self hideStatus];
    
    if (!self.isDisconnecting) {
        if ([self isUserBlind]) {
            NSString *speech = NSLocalizedStringFromTable(@"SPEECH_DID_SUBSCRIBE", @"BMECallViewController", @"Speech when connected to other part");
            [BMESpeaker speak:speech];
        }
        
        if ([self isUserBlind]) {
            [self displayViewForPublisher:self.publisher];
        } else {
            [self displayViewForSubscriber:self.subscriber];
        }
    }
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error {
    NSString *statusText = NSLocalizedStringFromTable(@"STATUS_FAILED_SUBSCRIBING", @"BMECallViewController", @"Status when failed subscribing");
    [self changeStatus:statusText];
    
    if (self.session) {
        [self disconnect];
    } else {
        [self dismiss];
    }
}

@end
