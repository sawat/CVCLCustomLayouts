//
//  MyIconCell.m
//  CVCLEamaples
//
//  Created by ITmedia on 12/11/09.
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

@end
