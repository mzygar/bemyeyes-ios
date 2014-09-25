//
//  BMEPointsTableViewCell.h
//  BeMyEyes
//
//  Created by Tobias DM on 23/09/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMEPointsTableViewCell : UITableViewCell

@property (strong, nonatomic) NSString *pointsDescription;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber *points;

@end
