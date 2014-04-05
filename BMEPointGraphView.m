//
//  BMEPointGraphView.m
//  BeMyEyes
//
//  Created by Simon Støvring on 04/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointGraphView.h"
#import "BMEPointGraphEntry.h"

#define BMEPointGraphDefaultStrokeWidth 5.0f
#define BMEPointGraphDefaultStrokeColor [UIColor blackColor]
#define BMEPointGraphDefaultGradientStartColor [UIColor whiteColor]
#define BMEPointGraphDefaultGradientEndColor [UIColor blueColor]
#define BMEPointGraphDefaultGraphInsets UIEdgeInsetsMake(5.0f, -2.0f, 5.0f, -2.0f);

@interface BMEPointGraphView ()
@property (strong, nonatomic) NSMutableArray *entries;
@property (assign, nonatomic) CGFloat pixelsPerSecond;
@property (assign, nonatomic) CGFloat pixelsPerPoint;
@property (assign, nonatomic) CGSize adjustedSize;
@end

@implementation BMEPointGraphView

#pragma mark -
#pragma mark Lifecycle

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    self.strokeWidth = BMEPointGraphDefaultStrokeWidth;
    self.strokeColor = BMEPointGraphDefaultStrokeColor;
    self.gradientStartColor = BMEPointGraphDefaultGradientStartColor;
    self.gradientEndColor = BMEPointGraphDefaultGradientEndColor;
    self.calculatesMinimum = YES;
    self.calculatesMaximum = YES;
    self.graphInsets = BMEPointGraphDefaultGraphInsets;
}

- (void)drawRect:(CGRect)rect {
    [self clearDrawing];
    [self drawGradient];
    
    if ([self.entries count] > 0) {
        [self drawGraph];
    }
}

- (void)dealloc {
    self.entries = nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)addPoints:(NSUInteger)points atDate:(NSDate *)date {
    BMEPointGraphEntry *entry = [BMEPointGraphEntry entryWithPoints:points date:date];
    [self.entries addObject:entry];
}

- (void)draw {
    if ([self.entries count] > 0) {
        NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        [self.entries sortUsingDescriptors:@[ dateSortDescriptor ]];
        
        if (self.calculatesMaximum) {
            self.minimum = [[self.entries valueForKeyPath:@"@min.points"] unsignedIntegerValue];
        }
        
        if (self.calculatesMaximum) {
            self.maximum = [[self.entries valueForKeyPath:@"@max.points"] unsignedIntegerValue];
        }
        
        self.adjustedSize = CGSizeMake(CGRectGetWidth(self.bounds) - self.graphInsets.left - self.graphInsets.right,
                                       CGRectGetHeight(self.bounds) - self.graphInsets.top - self.graphInsets.bottom);
        
        NSTimeInterval timeDifference = [[self lastEntry].date timeIntervalSinceDate:[self firstEntry].date];
        self.pixelsPerSecond = self.adjustedSize.width / timeDifference;
        self.pixelsPerPoint = self.adjustedSize.height / (self.maximum - self.minimum);
    }
    
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Private Methods

- (void)drawGraph {
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), [self.strokeColor CGColor]);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint firstPoint = CGPointMake([self xForDate:[self firstEntry].date], [self yForPoints:[self firstEntry].points]);
    CGPathMoveToPoint(path, NULL, firstPoint.x, firstPoint.y);
    
    NSInteger entriesCount = [self.entries count];
    
    for (NSInteger i = 1; i < entriesCount; i++) {
        BMEPointGraphEntry *entry = self.entries[i];
        CGPoint point = CGPointMake([self xForDate:entry.date], [self yForPoints:entry.points]);
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
    }
    
    UIBezierPath *bezier = [UIBezierPath bezierPathWithCGPath:path];
    bezier.lineJoinStyle = kCGLineJoinRound;
    bezier.lineWidth = self.strokeWidth;
    [bezier stroke];
    
    CGPathRelease(path);
}

- (void)drawGradient {
    NSArray *gradientColors = @[ (id)[self.gradientStartColor CGColor], (id)[self.gradientEndColor CGColor] ];
    CGFloat gradientLocations[2];
    gradientLocations[0] = 0.0f;
    gradientLocations[1] = 1.0f;
    
    CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(rgbSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    CGColorSpaceRelease(rgbSpace);
    
    CGPoint gradientStart = CGPointZero;
    CGPoint gradientEnd = CGPointMake(0.0f, CGRectGetHeight(self.bounds));
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), gradient, gradientStart, gradientEnd, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
}

- (void)clearDrawing {
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.bounds);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [self.backgroundColor CGColor]);
    CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
}

- (CGFloat)xForDate:(NSDate *)date {
    return [date timeIntervalSinceDate:[self firstEntry].date] * self.pixelsPerSecond + self.graphInsets.left;
}

- (CGFloat)yForPoints:(NSUInteger)points {
	return self.adjustedSize.height - ((points - self.minimum) * self.pixelsPerPoint) + self.graphInsets.top;
}

- (BMEPointGraphEntry *)firstEntry {
    return [self.entries firstObject];
}

- (BMEPointGraphEntry *)lastEntry {
    return [self.entries lastObject];
}

- (NSMutableArray *)entries {
    if (!_entries) {
        _entries = [NSMutableArray new];
    }
    
    return _entries;
}

@end


