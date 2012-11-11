//
//  MyCollectionViewCell.h
//  CollectionViewSample
//
//  Created by 沢 辰洋 on 12/11/05.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (readonly) BOOL editing;

- (void)setColor:(UIColor *)color;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end
