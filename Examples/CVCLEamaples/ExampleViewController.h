//
//  CoverFlowViewController.h
//  CollectionViewSample
//
//  Created by 沢 辰洋 on 12/11/05.
//  Copyright (c) 2012年 沢 辰洋 All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExampleViewController : UICollectionViewController

@property (nonatomic, strong) UICollectionViewLayout *layout;
@property (nonatomic, copy) NSString *cellIdentifier;

- (void) setLayoutAtIndexPath:(NSIndexPath *)indexPath;

@end
