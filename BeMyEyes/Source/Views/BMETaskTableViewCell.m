//
//  BMETaskTableViewCell.m
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMETaskTableViewCell.h"

@interface BMETaskTableViewCell()
@property (weak, nonatomic) IBOutlet MaskedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet MaskedLabel *detailLabel;
@end

@implementation BMETaskTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    // Set these in IB when possible (currently IB is buggy)
    self.titleLabel.color =
    self.detailLabel.color = [UIColor whiteColor];
    self.titleLabel.textInset =
    self.detailLabel.textInset = UIEdgeInsetsMake(5, 15, 5, 15);
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.detailLabel.font = [UIFont boldSystemFontOfSize:17.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Don't show selection
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *color = highlighted ? [UIColor lightTextColor] : [UIColor whiteColor];
    self.titleLabel.color =
    self.detailLabel.color = color;
}


#pragma mark - Setters and Getters

- (void)setTitle:(NSString *)title
{
    if (title != _title) {
        _title = title;
        
        self.titleLabel.text = self.title;
    }
}

- (void)setDetail:(NSString *)detail
{
    if (detail != _detail) {
        _detail = detail;
        
        self.detailLabel.text = self.detail;
    }
}

@end
