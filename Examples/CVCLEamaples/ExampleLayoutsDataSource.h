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

- (NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)pageEnabledAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewLayout *)layoutAtIndexPath:(NSIndexPath *)indexPath;

@end
