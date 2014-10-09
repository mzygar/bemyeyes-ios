//
//  BMEAccessView.h
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;

@interface BMEAccessView : UIControl

@property (readonly, nonatomic) RadioButton *radioButton;
@property (readonly, nonatomic) UILabel *titleLabel;
@property (readonly, nonatomic) UILabel *messageLabel;

@end
