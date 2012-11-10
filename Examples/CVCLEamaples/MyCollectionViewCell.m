//
//  MyCollectionViewCell.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import "MyCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>


@implementation MyCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    [self.titleLabel setBackgroundColor:color];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    static NSString * animationKey = @"editing";
    
    _editing = editing;
    
    if (editing) {

        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
        
        animation.duration = 0.5f;
        animation.repeatCount = HUGE_VAL;
        
        CGFloat digree = M_PI / 180 * 3;
        
        animation.values = @[@0, @(digree), @0, @(-digree), @(0)];
        
        [self.layer addAnimation:animation forKey:animationKey];
        
    } else {
        [self.layer removeAnimationForKey:animationKey];
    }
    
}

@end
