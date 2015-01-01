//
//  BMEPointsTableViewCell.m
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointsTableViewCell.h"

#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface BMEPointsTableViewCell() <MKLocalizable>
@property (weak, nonatomic) IBOutlet UILabel *pointsDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) TTTTimeIntervalFormatter *timeFormatter;
@end

@implementation BMEPointsTableViewCell

- (void)awakeFromNib {
    // Fix backgroundColor not being set to clearColor from Storyboard on iPad.
    self.backgroundColor = [UIColor clearColor];
    // Register for localization
    [MKLocalization registerForLocalization:self];
}

- (void)shouldLocalize {
    [self updateDateLabel];
    [self updatePointsLabel];
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
    _date = date;
    [self updateDateLabel];
}

- (void)setPoints:(NSNumber *)points
{
    _points = points;
    [self updatePointsLabel];
}

- (TTTTimeIntervalFormatter *)timeFormatter
{
    if (!_timeFormatter) {
        _timeFormatter = [TTTTimeIntervalFormatter new];
        _timeFormatter.usesIdiomaticDeicticExpressions = YES; // Allow 'yesterday' instead of '1 day ago'
    }
    return _timeFormatter;
}


#pragma mark -

- (void)updateDateLabel {
    self.dateLabel.text = _date ? [self.timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:self.date] : nil;
}

- (void)updatePointsLabel {
    self.pointsLabel.text = [NSString stringWithFormat:MKLocalizedFromTable(BME_SETTINGS_TASK_POINTS, BMESettingsLocalizationTable), self.points.integerValue];
}

@end
