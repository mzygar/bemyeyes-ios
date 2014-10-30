//
//  BMEPointLabel.m
//  BeMyEyes
//
//  Created by Simon Støvring on 13/04/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "BMEPointLabel.h"

#define BMEPointLabelTickAnimationDuration 3.0f

@interface BMEPointLabel ()
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (assign, nonatomic) CGFloat currentPoint;
@property (assign, nonatomic) CGFloat step;
@property (strong, nonatomic) UIColor *defaultTextColor;
@end

@implementation BMEPointLabel

#pragma mark -
#pragma mark Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.defaultTextColor = self.textColor;
    
    self.tickAnimationDuration = BMEPointLabelTickAnimationDuration;
    self.colors = @{ @(0.0f) : [UIColor redColor],
                     @(0.50f) : [UIColor yellowColor],
                     @(1.0f) : [UIColor greenColor] };
    
    self.point = 0;
    self.currentPoint = 0;
    [self displayPoint];
}

- (void)dealloc {
    [self removeDisplayLink];
    
    self.displayLink = nil;
    self.defaultTextColor = nil;
}

#pragma mark -
#pragma mark Public Methods

- (void)setPoint:(NSInteger)point {
    [self setPoint:point animated:NO];
}

- (void)setPoint:(NSInteger)point animated:(BOOL)animated {
    if (point != _point) {
        if (animated) {
            _currentPoint = _point;
            _point = point;
            
            [self animatePoint];
        } else {
            _currentPoint = point;
            _point = point;
            
            [self displayPoint];
        }
    }
}

#pragma mark -
#pragma mark Private Methods

- (void)tick:(id)sender {
    self.currentPoint += self.step;
    
    BOOL isDone = self.currentPoint >= self.point;
    if (isDone) {
        self.currentPoint = self.point;
        [self removeDisplayLink];
    }
    
    [self displayPoint];
    
    self.textColor = [self colorForPercentage:self.currentPoint / self.point];
    
    if (isDone) {
        [self finishedTickAnimation];
    }
}

- (NSString *)finalText {
    return [NSString stringWithFormat:@"%d", self.point];
}

- (void)displayPoint {
    self.text = self.finalText;
}

- (void)animatePoint {
    CGFloat change = fabsf(self.currentPoint - self.point);
    self.step = change / (60 * self.tickAnimationDuration);
    [self addDisplayLink];
}

- (void)addDisplayLink {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)removeDisplayLink {
    if (self.displayLink) {
        [self.displayLink invalidate];
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (void)finishedTickAnimation {
    [self performZoom:^{
        UIImage *colorImage = [self imageFromRect:self.bounds];
        UIImageView *colorImageView = [[UIImageView alloc] initWithImage:colorImage];
        [self addSubview:colorImageView];
        
        self.textColor = self.defaultTextColor;
        
        [UIView animateWithDuration:2.0f animations:^{
            colorImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [colorImageView removeFromSuperview];
        }];
    }];
}

- (void)performZoom:(void(^)(void))completion {
    NSMutableArray *imageViews = [NSMutableArray new];
    for (NSInteger i = 0; i < [self.text length]; i++) {
        NSRange range = NSMakeRange(i, 1);
        CGRect rect = [self boundingRectForCharacterRange:range];
        UIImageView *imageView = [UIImageView new];
        imageView.image = [self imageFromRect:rect];
        imageView.frame = [self.superview convertRect:rect fromView:self];
        [self.superview addSubview:imageView];
        
        [imageViews addObject:imageView];
    }
    
    UIColor *originalTextColor = self.textColor;
    self.textColor = [UIColor clearColor];
    
    CGFloat finishedDelay = 0.0f;
    for (NSInteger i = 0; i < [imageViews count]; i++) {
        UIImageView *imageView = imageViews[i];
        CGFloat delay = 0.10f * i;
        CGFloat duration = 0.30f;
        [UIView animateWithDuration:duration * 0.50f delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            imageView.transform = CGAffineTransformMakeScale(1.20f, 1.20f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration * 0.50f animations:^{
                imageView.transform = CGAffineTransformIdentity;
            }];
        }];
        
        CGFloat finishTime = delay + duration;
        finishedDelay = MAX(finishTime, finishedDelay);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(finishedDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIImageView *imageView in imageViews) {
            [imageView removeFromSuperview];
        }
        
        self.textColor = originalTextColor;
        
        if (completion) {
            completion();
        }
    });
}

- (UIColor *)colorForPercentage:(CGFloat)percentage {
    if (self.colors == nil || [self.colors count] == 0) {
        return self.textColor;
    }
    
    NSArray *keys = [[self.colors allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *equalKeys = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", @(percentage)]];
    if ([equalKeys count] > 0) {
        return [self.colors objectForKey:[equalKeys firstObject]];
    } else {
        NSArray *greaterKeys = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self > %@", @(percentage)]];
        NSArray *lesserKeys = [keys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self < %@", @(percentage)]];
        if ([greaterKeys count] > 0 && [lesserKeys count] > 0) {
            NSNumber *greaterKey = [greaterKeys firstObject];
            NSNumber *lesserKey = [lesserKeys lastObject];
            
            UIColor *greaterColor = [self.colors objectForKey:greaterKey];
            UIColor *lesserColor = [self.colors objectForKey:lesserKey];
            
            CGFloat greaterRed, greaterGreen, greaterBlue;
            CGFloat lesserRed, lesserGreen, lesserBlue;
            
            [greaterColor getRed:&greaterRed green:&greaterGreen blue:&greaterBlue alpha:NULL];
            [lesserColor getRed:&lesserRed green:&lesserGreen blue:&lesserBlue alpha:NULL];
            
            CGFloat colorPercentage = (percentage - [lesserKey floatValue]) / fabs([lesserKey floatValue] - [greaterKey floatValue]);
            
            CGFloat red = lesserRed * (1.0f - colorPercentage) + greaterRed * colorPercentage;
            CGFloat green = lesserGreen * (1.0f - colorPercentage) + greaterGreen * colorPercentage;
            CGFloat blue = lesserBlue * (1.0f - colorPercentage) + greaterBlue * colorPercentage;
            
            return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
        } else if ([greaterKeys count] > 0) {
            return [self.colors objectForKey:[greaterKeys firstObject]];
        } else if ([lesserKeys count] > 0) {
            return [self.colors objectForKey:[lesserKeys lastObject]];
        }
    }
    
    return self.textColor;
}

- (UIImage *)imageFromRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x, 0.0f);
    CGContextClipToRect(UIGraphicsGetCurrentContext(), rect);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:[self attributedText]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

@end
