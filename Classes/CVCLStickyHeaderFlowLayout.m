//
//  CVCLStickyHeaderFlowLayout.m
//  CVCLEamaples
//
//  Created by ITmedia on 2013/06/17.
//  Copyright (c) 2013年 沢 辰洋. All rights reserved.
//

#import "CVCLStickyHeaderFlowLayout.h"

@implementation CVCLStickyHeaderFlowLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attr = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    
    return attr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attrs = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    CGPoint offset = self.collectionView.contentOffset;
    
    NSMutableDictionary *headerLayouts = [NSMutableDictionary dictionary];
    
    int minimumSection = NSIntegerMax;
    int maximumSection = -1;
    
    for (UICollectionViewLayoutAttributes *at in attrs) {
        NSIndexPath *indexPath = at.indexPath;
        int currentSection = indexPath.section;
        BOOL newSection = [headerLayouts objectForKey:@(indexPath.section)] == nil;
        minimumSection = MIN(minimumSection, currentSection);
        maximumSection = MAX(maximumSection, currentSection);

        if (at.representedElementCategory == UICollectionElementCategorySupplementaryView
            && [at.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            [headerLayouts setObject:at forKey:@(currentSection)];
        } else if (newSection) {
            [headerLayouts setObject:[NSNull null] forKey:@(currentSection)];
        }
    }
    
    CGFloat minimumOffset = CGFLOAT_MAX;
    BOOL vert = self.scrollDirection == UICollectionViewScrollDirectionVertical;
    
    for (int sec = maximumSection; sec >= minimumSection; sec--) {
        UICollectionViewLayoutAttributes * at = [headerLayouts objectForKey:@(sec)];
        if ([at isKindOfClass:[NSNull class]]) {
            at = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:sec]];
            at.zIndex = 1024;
            CGRect frame = at.frame;
            
            if (vert) {
                frame.origin.y = offset.y;
                if (CGRectGetMaxY(frame) > minimumOffset) {
                    frame.origin.y -= CGRectGetMaxY(frame) - minimumOffset;
                }
            } else {
                frame.origin.x = offset.x;
                if (CGRectGetMaxX(frame) > minimumOffset) {
                    frame.origin.x -= CGRectGetMaxX(frame) - minimumOffset;
                }
            }
            
            at.frame = frame;
            if (CGRectIntersectsRect(at.frame, rect)) {
                [attrs addObject:at];
            }

        } else {
            at.zIndex = 1024;
            CGRect frame = at.frame;
            if (vert) {
                if (frame.origin.y < offset.y) {
                    frame.origin.y = offset.y;
                }
                minimumOffset = MIN(minimumOffset,frame.origin.y);
            } else {
                if (frame.origin.x < offset.x) {
                    frame.origin.x = offset.x;
                }
                minimumOffset = MIN(minimumOffset,frame.origin.x);
            }
            
            at.frame = frame;
        }
    }
    
    return attrs;
}

//
//- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
//    
//    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
//    UICollectionView * const cv = self.collectionView;
//    CGPoint const contentOffset = cv.contentOffset;
//    
//    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
//    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
//        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
//            [missingSections addIndex:layoutAttributes.indexPath.section];
//        }
//    }
//    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
//        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
//            [missingSections removeIndex:layoutAttributes.indexPath.section];
//        }
//    }
//    
//    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
//        
//        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
//        
//        [answer addObject:layoutAttributes];
//        
//    }];
//    
//    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
//        
//        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
//            
//            NSInteger section = layoutAttributes.indexPath.section;
//            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
//            
//            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
//            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
//            
//            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
//            UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
//            
//            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
//            CGPoint origin = layoutAttributes.frame.origin;
//            origin.y = MIN(
//                           MAX(
//                               contentOffset.y,
//                               (CGRectGetMinY(firstCellAttrs.frame) - headerHeight)
//                               ),
//                           (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight)
//                           );
//            
//            layoutAttributes.zIndex = 1024;
//            layoutAttributes.frame = (CGRect){
//                .origin = origin,
//                .size = layoutAttributes.frame.size
//            };
//            
//        }
//        
//    }
//    
//    return answer;
//    
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
