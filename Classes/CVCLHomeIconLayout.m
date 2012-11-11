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
@property (nonatomic, strong) NSArray *headerLayouts;
@property (nonatomic, strong) NSArray *footerLayouts;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;
@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;

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
    
    NSInteger secNum = self.collectionView.numberOfSections;
    
    NSMutableArray *newLayouts = [NSMutableArray arrayWithCapacity:secNum];
    NSMutableArray *newHeaderLayouts = self.headerHeight > 0 ? [NSMutableArray arrayWithCapacity:secNum] : nil;
    NSMutableArray *newFooterLayouts = self.footerHeight > 0 ? [NSMutableArray arrayWithCapacity:secNum] : nil;
    
    for (int sec = 0; sec < secNum; sec++) {
        NSMutableArray *attrs = [NSMutableArray arrayWithCapacity:(_gridColumns * _gridRows)];
        
        if (self.headerHeight > 0) {
            [newHeaderLayouts addObject:[self prepareLayoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:sec]]];
        }
        if (self.footerHeight > 0) {
            [newFooterLayouts addObject:[self prepareLayoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:sec]]];
        }
        
        for (int item = 0; item < [self.collectionView numberOfItemsInSection:sec] && item < (_gridColumns * _gridRows); item++) {
            [attrs addObject:[self prepareLayoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:sec]]];
        }
        
        [newLayouts addObject:attrs];
    }
    self.sectionLayouts = newLayouts;
    self.headerLayouts = newHeaderLayouts;
    self.footerLayouts = newFooterLayouts;
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

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:(_gridColumns*_gridRows*2)];
    
    for (int section = MAX(0, rect.origin.x / self.collectionView.bounds.size.width),
         end = MIN(self.sectionLayouts.count, (rect.origin.x + rect.size.width ) / self.collectionView.bounds.size.width); section < end; section++) {
        if (self.headerLayouts) {
            [array addObject:self.headerLayouts[section]];
        }
        if (self.footerLayouts) {
            [array addObject:self.footerLayouts[section]];
        }
        [array addObjectsFromArray:self.sectionLayouts[section]];
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LOG(@"SupplementaryView: [%d-%d]", indexPath.section, indexPath.item);

    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.headerLayouts) {
        return self.headerLayouts[indexPath.section];
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter] && self.footerLayouts) {
        return self.footerLayouts[indexPath.section];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    BOOL invalidate = !CGSizeEqualToSize(_prepareLayoutSize, self.collectionView.bounds.size);
    if (invalidate) {
        [self computeAllLayout];
    }
    return invalidate;
}

#pragma mark -
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    // Keep track of insert and delete index paths
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        LOG(@"[%d-%d] -> [%d-%d] %d", update.indexPathBeforeUpdate.section, update.indexPathBeforeUpdate.item,
            update.indexPathAfterUpdate.section, update.indexPathAfterUpdate.item, update.updateAction);
        
        if (update.updateAction == UICollectionUpdateActionDelete)
        {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert)
        {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if ([self.insertIndexPaths containsObject:itemIndexPath]) {
        // only change attributes on inserted cells
        if (!attributes) {
            attributes = [self prepareLayoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.transform3D = CATransform3DTranslate(attributes.transform3D, 0, 0, 1);
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deleteIndexPaths containsObject:itemIndexPath]) {
        // only change attributes on inserted cells
        if (!attributes) {
            // 元の位置から
            attributes = [self prepareLayoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        
        // Configure attributes ...
        attributes.transform3D = CATransform3DScale(attributes.transform3D, 0, 0, 1);
    }
    LOG(@"Disappearing item: [%d-%d]", itemIndexPath.section, itemIndexPath.item);
    
    return attributes;
    
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    LOG(@"Appearing Supp: [%d-%d] %@", elementIndexPath.section, elementIndexPath.item, elementKind);
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    LOG(@"Disappearing Supp: [%d-%d] %@", elementIndexPath.section, elementIndexPath.item, elementKind);
    return [self layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:elementIndexPath];
}



@end
