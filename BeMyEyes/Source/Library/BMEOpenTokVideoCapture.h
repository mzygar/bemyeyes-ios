//
//  BMEOpenTokVideo.h
//  BeMyEyes
//
//  Created by Tobias Due Munk on 08/11/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenTok/OpenTok.h>

@protocol OTVideoCapture;

@interface BMEOpenTokVideoCapture : NSObject
<AVCaptureVideoDataOutputSampleBufferDelegate, OTVideoCapture>
{
@protected
    dispatch_queue_t _capture_queue;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;

@property (nonatomic, assign) NSString* captureSessionPreset;
@property (readonly) NSArray* availableCaptureSessionPresets;

@property (nonatomic, assign) double activeFrameRate;
- (BOOL)isAvailableActiveFrameRate:(double)frameRate;

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (readonly) NSArray* availableCameraPositions;
- (BOOL)toggleCameraPosition;

@end
