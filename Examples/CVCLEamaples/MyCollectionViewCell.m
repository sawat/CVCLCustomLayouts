//
//  MyCollectionViewCell.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import "MyCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

@interface DeleteButtonView : UIView
@end

@interface MyCollectionViewCell ()
@property (nonatomic, weak) DeleteButtonView * deleteButtonView;
@end

#pragma mark -

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

        if ([self.layer animationForKey:animationKey] == nil) {
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            
            animation.duration = 0.5f;
            animation.repeatCount = HUGE_VAL;
            
            CGFloat digree = M_PI / 180 * 3;
            
            animation.values = @[@0, @(digree), @0, @(-digree), @(0)];
            
            [self.layer addAnimation:animation forKey:animationKey];
        }

        if (self.deleteButtonView == nil) {
            DeleteButtonView *view = [[DeleteButtonView alloc] initWithFrame:self.bounds];
            [self addSubview:view];
            self.deleteButtonView = view;
        }
        
    } else {
        [self.layer removeAnimationForKey:animationKey];
        [UIView animateWithDuration:0.1 animations:^{
            self.deleteButtonView.alpha = 0.0;
        } completion:^(BOOL complete){
            if (complete) {
                [self.deleteButtonView removeFromSuperview];
            }
        }];
    }
    
}

@end

@implementation DeleteButtonView

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(contex, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
    CGContextFillRect(contex, rect);
    
    // draw X mark
    CGContextSetStrokeColorWithColor(contex, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(contex, 10.0f);
    
    CGFloat w  = MIN(self.bounds.size.width, self.bounds.size.height) / 6;
    CGFloat x0 = self.bounds.size.width / 2  - w;
    CGFloat y0 = self.bounds.size.height / 2 - w;
    CGFloat x1 = self.bounds.size.width / 2  + w;
    CGFloat y1 = self.bounds.size.height / 2 + w;
    CGContextMoveToPoint(contex, x0, y0);
    CGContextAddLineToPoint(contex, x1, y1);
    CGContextMoveToPoint(contex, x0, y1);
    CGContextAddLineToPoint(contex, x1, y0);
    CGContextDrawPath(contex, kCGPathStroke);
}

@end
