//
//  CoverFlowViewController.h
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverFlowViewController : UICollectionViewController

@property (nonatomic, strong) UICollectionViewLayout *layout;
@property (nonatomic, copy) NSString *cellIdentifier;

- (void) setLayoutAtIndexPath:(NSIndexPath *)indexPath;

@end
