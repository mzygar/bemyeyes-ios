//
//  UIView+Layout.m
//  BeMyEyes
//
//  Created by Tobias DM on 08/10/14.
//  Copyright (c) 2014 Be My Eyes. All rights reserved.
//

#import "UIView+Layout.h"


@interface UIView (Layout)

- (UIView *)newSpacerTopView:(UIView *)view;
- (UIView *)newSpacerBottomView:(UIView *)view;
- (UIView *)newHorizontalSpacerBetweenView:(UIView *)v1 :(UIView *)v2;
- (UIView *)newSpacer;

@end



@implementation NSArray (Layout)

- (NSArray *)horizontallySpaceInView:(UIView *)inView
{
    for (UIView *view in self) {
        [inView addSubview:view];
        
        [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    UIView *firstSpacer, *lastSpacer;
    NSMutableArray *betweenSpacers = [NSMutableArray new];
    NSUInteger i = 0;
    for (UIView *view in self) {
        
        if (view == self.firstObject) {
            firstSpacer = [inView newSpacerTopView:view];
            
            UIView *nextView = self[i+1];
            UIView *spacer = [inView newHorizontalSpacerBetweenView:view :nextView];
            [betweenSpacers addObject:spacer];
        } else if (view == self.lastObject) {
            lastSpacer = [inView newSpacerBottomView:view];
        } else {
            UIView *nextView = self[i+1];
            UIView *spacer = [inView newHorizontalSpacerBetweenView:view :nextView];
            [betweenSpacers addObject:spacer];
        }
        i++;
    }
    
    firstSpacer.keepHeightTo(lastSpacer).equal = 1;
    [betweenSpacers keepHeightsEqual];
    firstSpacer.keepHeightTo(betweenSpacers.firstObject).equal = 2;
    
    NSMutableArray *spacers = @[firstSpacer].mutableCopy;
    [spacers addObjectsFromArray:betweenSpacers];
    [spacers addObject:lastSpacer];
    return spacers.copy;
}

@end





@implementation UIView (Layout)


#pragma mark -

- (UIView *)newSpacerTopView:(UIView *)view
{
    UIView *spacer = [self newHorizontalSpacer];
    spacer.keepTopInset.equal =
    spacer.keepBottomOffsetTo(view).equal = 0;
    return spacer;
}

- (UIView *)newSpacerBottomView:(UIView *)view
{
    UIView *spacer = [self newHorizontalSpacer];
    spacer.keepBottomInset.equal =
    spacer.keepTopOffsetTo(view).equal = 0;
    return spacer;
}

- (UIView *)newHorizontalSpacerBetweenView:(UIView *)v1 :(UIView *)v2
{
    UIView *spacer = [self newHorizontalSpacer];
    spacer.keepTopOffsetTo(v1).equal =
    spacer.keepBottomOffsetTo(v2).equal = 0;
    return spacer;
}

- (UIView *)newHorizontalSpacer
{
    UIView *spacer = [self newSpacer];
    spacer.keepWidth.equal = 5;
    [spacer keepHorizontallyCentered];
    return spacer;
}

- (UIView *)newSpacer
{
    UIView *spacer = [UIView new];
    [self addSubview:spacer];
    return spacer;
}

@end
