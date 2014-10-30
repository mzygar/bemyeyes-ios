//
//  BMEPointLabel.h
//  BeMyEyes
//
//  Created by Simon Støvring on 13/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMEPointLabel : UILabel

@property (assign, nonatomic) NSInteger point;
@property (assign, nonatomic) NSTimeInterval tickAnimationDuration;
@property (copy, nonatomic) NSDictionary *colors;

- (NSString *)finalText;
- (void)setPoint:(NSInteger)point animated:(BOOL)animted;

@end
