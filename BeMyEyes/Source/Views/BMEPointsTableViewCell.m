//
//  BMEPointsTableViewCell.m
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointsTableViewCell.h"

#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface BMEPointsTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *pointsDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeFormatter;
@end

@implementation BMEPointsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

#pragma mark - Setters and Getters

- (void)setPointsDescription:(NSString *)pointsDescription
{
    if (pointsDescription != _pointsDescription) {
        _pointsDescription = pointsDescription;
        
        self.pointsDescriptionLabel.text = self.pointsDescription;
    }
}

- (void)setDate:(NSDate *)date
{
    if (date != _date) {
        _date = date;
        
        self.dateLabel.text = [self.timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:self.date];
    }
}

- (void)setPoints:(NSNumber *)points
{
    if (points != _points) {
        _points = points;
        
        self.pointsLabel.text = [NSString stringWithFormat:@"+%d points", self.points.integerValue];
    }
}

- (TTTTimeIntervalFormatter *)timeFormatter
{
    if (!_timeFormatter) {
        _timeFormatter = [TTTTimeIntervalFormatter new];
        _timeFormatter.usesIdiomaticDeicticExpressions = YES; // Allow 'yesterday' instead of '1 day ago'
    }
    return _timeFormatter;
}

@end
