//
//  CVCLHomeIconLayout.m
//  CVCLEamaples
//
//  Created by ITmedia on 12/11/09.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "CVCLHomeIconLayout.h"

@interface CVCLHomeIconLayout ()

@property (nonatomic, strong) NSArray *sectionLayouts;

@end

@implementation CVCLHomeIconLayout {
    NSInteger _gridColumns;
    NSInteger _gridRows;
    CGSize _prepareLayoutSize;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self setInitialValues];
    }
    return self;
}

- (id)initWithCellSize:(CGSize)cellSize {
    self = [self init];
    if (self) {
        self.cellSize = cellSize;
    }
    return self;
}

- (id)initWithCellSize:(CGSize)cellSize mergin:(CGFloat)mergin {
    self = [self init];
    if (self) {
        self.cellSize = cellSize;
        self.mergin = mergin;
    }
    return self;
}

- (void)setInitialValues {
    self.cellSize = CGSizeMake(80, 90);
    self.mergin = 0;
}

- (void)computeAllLayout {
    CGSize size = self.collectionView.bounds.size;
    _prepareLayoutSize = size;
    
    _gridColumns = (NSInteger)((size.width - self.mergin) / (self.cellSize.width + self.mergin));
    _gridRows = (NSInteger)((size.height -self.headerHeight - self.footerHeight - self.mergin) / (self.cellSize.height + self.mergin));
    
    NSMutableArray *newLayouts = [NSMutableArray arrayWithCapacity:self.collectionView.numberOfSections];
    for (int sec = 0; sec < self.collectionView.numberOfSections; sec++) {
        NSMutableArray *attrs = [NSMutableArray arrayWithCapacity:(_gridColumns * _gridRows)];
        
        for (int item = 0; item < [self.collectionView numberOfItemsInSection:sec] && item < (_gridColumns * _gridRows); item++) {
            [attrs addObject:[self prepareLayoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:sec]]];
        }
        
        if (self.headerHeight > 0) {
            [attrs addObject:[self prepareLayoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:sec]]];
        }
        if (self.footerHeight > 0) {
            [attrs addObject:[self prepareLayoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:sec]]];
        }
        
        [newLayouts addObject:attrs];
    }
    self.sectionLayouts = newLayouts;
}

- (void)prepareLayout {
    [self computeAllLayout];
}

- (CGSize)collectionViewContentSize {
    NSInteger sections = self.collectionView.numberOfSections;
    
    CGSize size = self.collectionView.bounds.size;
    size.width *= sections;
    
    return size;
}

- (UICollectionViewLayoutAttributes *)prepareLayoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    int col = indexPath.item % _gridColumns;
    int row = indexPath.item / _gridColumns;
    
    CGRect frame;
    frame.origin.x = self.mergin + self.cellSize.width * col + self.collectionView.bounds.size.width * indexPath.section;
    frame.origin.y = self.headerHeight + self.mergin + self.cellSize.height * row;
    frame.size = self.cellSize;
    
    attr.frame = frame;
    
    return attr;
}

- (UICollectionViewLayoutAttributes *)prepareLayoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    BOOL header = [kind isEqualToString:UICollectionElementKindSectionHeader];
    CGRect frame;
    frame.origin.x = self.collectionView.bounds.size.width * indexPath.section;
    frame.origin.y = header ? 0 : self.collectionView.bounds.size.height - self.footerHeight;
    frame.size.width = self.collectionView.bounds.size.width;
    frame.size.height = header ? self.headerHeight : self.footerHeight;
    
    attr.frame = frame;
    
    return attr;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger section = MIN(MAX(0, rect.origin.x / self.collectionView.bounds.size.width),self.sectionLayouts.count);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:(_gridColumns*_gridRows*2)];
    [array addObjectsFromArray:self.sectionLayouts[section]];

    if (section + 1 != self.sectionLayouts.count) {
        [array addObjectsFromArray:self.sectionLayouts[section+1]];
    }
    
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.sectionLayouts.count) {
        return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    }
    NSArray *array = self.sectionLayouts[indexPath.section];
    if (indexPath.item >= array.count) {
        return [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    }
    return [array objectAtIndex:indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    BOOL invalidate = !CGSizeEqualToSize(_prepareLayoutSize, self.collectionView.bounds.size);
    if (invalidate) {
        [self computeAllLayout];
    }
    return invalidate;
}


@end
