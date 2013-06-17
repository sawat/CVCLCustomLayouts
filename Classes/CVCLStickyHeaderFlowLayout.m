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
    
    BOOL vert = self.scrollDirection == UICollectionViewScrollDirectionVertical;
    
    CGFloat nextSecOffset = CGFLOAT_MAX;
    if (self.collectionView.numberOfSections - 1 != maximumSection) {
        NSIndexPath *nextSecIP = [NSIndexPath indexPathForItem:0 inSection:maximumSection+1];
        UICollectionViewLayoutAttributes *nextHeaderAttr = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:nextSecIP];
        nextSecOffset = vert ? nextHeaderAttr.frame.origin.y : nextHeaderAttr.frame.origin.x;
    }
    
    for (int sec = maximumSection; sec >= minimumSection; sec--) {
        UICollectionViewLayoutAttributes * at = [headerLayouts objectForKey:@(sec)];
        if ([at isKindOfClass:[NSNull class]]) {
            NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:sec];
            
            at = [super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:ip];
            [attrs addObject:at];
        }
        at.zIndex = 1024;
        CGRect frame = at.frame;
        if (vert) {
            if (frame.origin.y < offset.y) {
                frame.origin.y = offset.y;
            }
            if (CGRectGetMaxY(frame) > nextSecOffset) {
                frame.origin.y -= CGRectGetMaxY(frame) - nextSecOffset;
            }
            nextSecOffset = MIN(nextSecOffset,frame.origin.y);
        } else {
            if (frame.origin.x < offset.x) {
                frame.origin.x = offset.x;
            }
            if (CGRectGetMaxX(frame) > nextSecOffset) {
                frame.origin.x -= CGRectGetMaxX(frame) - nextSecOffset;
            }
            nextSecOffset = MIN(nextSecOffset,frame.origin.x);
        }
        at.frame = frame;
    }
    
    return attrs;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
