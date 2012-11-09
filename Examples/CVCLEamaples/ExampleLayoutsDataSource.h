//
//  ExampleLayoutsDataSource.h
//  CVCLEamaples
//
//  Created by ITmedia on 12/11/09.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExampleLayoutsDataSource : NSObject <UITableViewDataSource>

+ (ExampleLayoutsDataSource *)sharedInstance;

- (NSDictionary *)layoutDictAtIndexPath:(NSIndexPath *)indexPath;
- (void) applyLayoutWithCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath animation:(BOOL)animation;
- (NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath;
@end
