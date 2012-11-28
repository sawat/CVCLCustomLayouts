//
//  MyIconCell.m
//  CVCLEamaples
//
//  Created by 沢 辰洋 on 12/11/09.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "MyIconCell.h"

#import <QuartzCore/QuartzCore.h>


@interface MyIconCell()

@property (weak, nonatomic) IBOutlet UIView *iconView;

@end

@implementation MyIconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iconView.layer.cornerRadius = 10;
}


- (void)setColor:(UIColor *)color {
    [self.iconView setBackgroundColor:color];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    static NSString * animationKey = @"editing";
    
    if (editing) {
        
        if ([self.layer animationForKey:animationKey] == nil) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            
            animation.duration = 0.5f;
            animation.repeatCount = HUGE_VAL;
            
            CGFloat digree = M_PI / 180 * 3;
            
            animation.values = @[@0, @(digree), @0, @(-digree), @(0)];
            
            [self.layer addAnimation:animation forKey:animationKey];
        }
        
    } else {
        [self.layer removeAnimationForKey:animationKey];
    }
    
}

@end
