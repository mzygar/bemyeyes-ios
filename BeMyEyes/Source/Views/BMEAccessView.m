//
//  BMEAccessView.m
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEAccessView.h"
#import "BeMyEyes-Swift.h"

@interface BMEAccessView()

@property (strong, nonatomic) RadioButton *radioButton;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;

@end

@implementation BMEAccessView

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.radioButton.selected = self.selected;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.radioButton.highlighted = self.highlighted;
    self.backgroundColor = highlighted ? [[UIColor lightTextColor] colorWithAlphaComponent:0.1] : nil;
}

#pragma mark - Setters and Getters

- (RadioButton *)radioButton
{
    if (!_radioButton) {
        _radioButton = [RadioButton new];
        _radioButton.userInteractionEnabled = NO;
        [self addSubview:_radioButton];
        _radioButton.keepLeftInset.equal =
        _radioButton.keepTopInset.equal = 15;
        _radioButton.keepBottomInset.equal = KeepFitting(15);
        _radioButton.keepSize.equal = 60;
    }
    return _radioButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
        _titleLabel.keepLeftOffsetTo(self.radioButton).equal =
        _titleLabel.keepTopInset.equal = 15;
        _titleLabel.keepRightInset.min = 15;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [UILabel new];
        _messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textColor = [UIColor whiteColor];
        [self addSubview:_messageLabel];
        _messageLabel.keepLeftAlignTo(self.titleLabel).equal = 0;
        _messageLabel.keepTopOffsetTo(self.titleLabel).equal = 2;
        _messageLabel.keepRightInset.min =
        _messageLabel.keepBottomInset.min = 15;
    }
    return _messageLabel;
}


#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    return [self.titleLabel.text stringByAppendingFormat:@". %@", self.messageLabel.text];
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitButton;
}


@end

