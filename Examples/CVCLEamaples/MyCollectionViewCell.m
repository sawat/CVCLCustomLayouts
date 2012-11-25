//
//  MyCollectionViewCell.m
//  CollectionViewSample
//
//  Created by 沢 辰洋 on 12/11/05.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "MyCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

@interface MyCollectionViewCell ()
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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    LOG_METHOD;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    [self.selectedBackgroundView setBackgroundColor:[UIColor blueColor]];
    
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
    _editing = editing;
}

@end

