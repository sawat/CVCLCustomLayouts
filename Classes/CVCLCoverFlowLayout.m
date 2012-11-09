//
//  MyCollectionViewLayout.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CVCLCoverFlowLayout.h"

@interface CVCLCoverFlowLayout () 

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;
@property (nonatomic, strong) NSArray *sectionIndexTable;

@end

@implementation CVCLCoverFlowLayout {
    CGFloat _centerRateThreshold;
    NSInteger _count;
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
        self.cellInterval = self.cellSize.width / 3;
    }
    return self;
}

- (id)initWithCellSize:(CGSize)cellSize cellInterval:(CGFloat)cellInterval {
    self = [self init];
    if (self) {
        self.cellSize = cellSize;
        self.cellInterval = cellInterval;
    }
    return self;
}

- (void)setInitialValues {
    self.cellSize = CGSizeMake(100, 100);
    self.cellInterval = self.cellSize.width / 3;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setInitialValues];
    }
    return self;
}

- (void)prepareLayout {
    [self updateCenterRateThreshold:self.collectionView.bounds];
    [self prepareSectionIndexTable];
}

- (void)prepareSectionIndexTable {
    int count = 0;
    int sn = self.collectionView.numberOfSections;
    NSMutableArray *table = [NSMutableArray arrayWithCapacity:sn+1];
    
    for (int i=0; i<sn; i++) {
        [table addObject:@(count)];
        count += [self.collectionView numberOfItemsInSection:i];
    }
    [table addObject:@(count)];
    _count = count;
    self.sectionIndexTable = table;
    LOG(@"table: %@", self.sectionIndexTable);
}

- (NSInteger)count {
    return _count;
}

- (NSInteger)totalIndexOfIndexPath:(NSIndexPath *)indexPath {
    return [self.sectionIndexTable[indexPath.section] intValue] + indexPath.row;
}
- (NSInteger)sectionOfTotalIndex:(NSInteger)totalIndex {
    int section = 0;
    for (NSNumber *ti in self.sectionIndexTable) {
        if (ti.intValue > totalIndex) {
            return section - 1;
        }
        section++;
    }
    return NSNotFound;
}
- (NSIndexPath *)indexPathOfTotalIndex:(NSInteger)totalIndex {
    NSInteger section = [self sectionOfTotalIndex:totalIndex];
    
    if (section == NSNotFound) {
        return nil;
    }
    
    return [NSIndexPath indexPathForRow:(totalIndex-[self.sectionIndexTable[section] intValue]) inSection:section];
}

- (NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row + 1 == [self.collectionView numberOfItemsInSection:indexPath.section]) {
        if (indexPath.section + 1 == [self.collectionView numberOfSections]) {
            return nil;
        } else {
            return [NSIndexPath indexPathForRow:0 inSection:indexPath.section+1];
        }
    } else {
        return [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    }
}

- (UIEdgeInsets) layoutInsets {
    CGFloat w_2 = self.collectionView.bounds.size.width / 2;
    CGFloat cellW_2 = self.cellSize.width / 2;
    return UIEdgeInsetsMake(0, w_2 - cellW_2, 0, w_2 + cellW_2 - _cellInterval);
}

- (CGSize)collectionViewContentSize {
    CGSize size = self.collectionView.bounds.size;
    size.width = self.count * self.cellInterval + self.cellSize.width;
    UIEdgeInsets insets = self.layoutInsets;
    size.width += insets.left + insets.right;
    return size;
}

- (CGFloat)cellsHorizontalInterval {
    UIEdgeInsets insets = self.layoutInsets;
    return (self.collectionViewContentSize.width - insets.left - insets.right) / self.count;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
    CGFloat cw = [self cellsHorizontalInterval];
    NSInteger minRow = MAX(0, (NSInteger)floor((rect.origin.x - self.layoutInsets.left) / cw));

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    UIEdgeInsets insets = self.layoutInsets;
    NSIndexPath *indexPath = [self indexPathOfTotalIndex:minRow];
    
    for (int i=minRow; indexPath && (i-1) * cw - insets.left < rect.origin.x + rect.size.width; i++) {
        [array addObject:indexPath];
        indexPath = [self nextIndexPath:indexPath];
    }
    return array;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    int section = NSNotFound;
    for (NSIndexPath *indexPath in [self indexPathsForItemsInRect:rect]) {
        if (indexPath.section != section) {
            [array addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath]];
            [array addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath]];
            section = indexPath.section;
        }
        [array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat cw = [self cellsHorizontalInterval];
    
    CGFloat cellOffsetX = [self totalIndexOfIndexPath:indexPath] * cw + self.layoutInsets.left;
    
    CGRect frame;
    frame.origin.x = cellOffsetX;
    frame.origin.y = (self.collectionView.bounds.size.height - self.cellSize.height) / 2.0;
    frame.size = self.cellSize;
    
    attr.frame = frame;

    attr.transform3D = [self transformWithCellOffsetX:cellOffsetX];
    
    return attr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];

    CGRect frame;
    frame.size = CGSizeMake(self.collectionView.bounds.size.width, 30);
    frame.origin.x = self.collectionView.contentOffset.x;
    frame.origin.y = [kind isEqualToString:UICollectionElementKindSectionHeader] ? 0 : self.collectionView.bounds.size.height - frame.size.height;
    
    NSInteger totalIndex  = [self.sectionIndexTable[indexPath.section] intValue];
    CGFloat sectionX = totalIndex * [self cellsHorizontalInterval] + self.layoutInsets.left;
    // セクション0のヘッダーは左詰め、それ以外はセクションの開始位置を考慮する
    if (indexPath.section != 0 && frame.origin.x < sectionX) {
        frame.origin.x = sectionX;
    }

    NSInteger next  = [self.sectionIndexTable[indexPath.section+1] intValue];
    CGFloat nextSectionX = next * [self cellsHorizontalInterval] + self.layoutInsets.left;
    // 次のセクションが画面に入っている場合
    if (indexPath.section != self.collectionView.numberOfSections-1 && frame.origin.x + frame.size.width > nextSectionX) {
        // 
        if (frame.origin.x == sectionX) {
            frame.size.width -= frame.origin.x + frame.size.width - nextSectionX;
        } else {
            frame.origin.x -= frame.origin.x + frame.size.width - nextSectionX;
        }
    }
    
    attr.frame = frame;
    
    return attr;
}

- (void)updateCenterRateThreshold:(CGRect)newBounds {
    _centerRateThreshold = _cellInterval / self.collectionView.bounds.size.width;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    [self updateCenterRateThreshold:newBounds];
    return YES;
}


#pragma mark - Functions

- (CGFloat)rateFowCellOffsetX:(CGFloat)cellOffsetX {
    CGFloat bw = self.collectionView.bounds.size.width;
    CGFloat offsetFromCenter = cellOffsetX + self.cellSize.width/2 - (self.collectionView.contentOffset.x + bw /2);
    CGFloat rate = offsetFromCenter / bw;
    return MIN(MAX(-1.0, rate), 1.0);
}

- (CATransform3D)transformWithCellOffsetX:(CGFloat)cellOffsetX {
    static const CGFloat zDistance = 800.0f;
    
    CGFloat rate = [self rateFowCellOffsetX:cellOffsetX];
    
    CATransform3D t = CATransform3DIdentity;
    //視点の距離
    t.m34 = 1.0f / -zDistance;
    
    // Affine変換の連結は順番を変えると結果が変わるので注意（行列の積だから）

    //位置
    t = CATransform3DTranslate(t,
                               [self translateXForDistanceRate:rate],
                               0.0f,
                               [self translateZForDistanceRate:rate]);
    //角度
    t = CATransform3DRotate(t,
                            [self angleForDistanceRate:rate],
                            0.0f,
                            1.0f,
                            0.0f);

    return t;
}

- (CGFloat)angleForDistanceRate:(CGFloat)rate {
    static const CGFloat baseAngle = - M_PI * 80 / 180; //degree
    
    if (fabsf(rate) > _centerRateThreshold) {
        return copysignf(1.0f, rate) * baseAngle;
    }
    return (rate /_centerRateThreshold) * baseAngle;
}

- (CGFloat)translateXForDistanceRate:(CGFloat)rate {
    
    if (fabsf(rate) < _centerRateThreshold) {
        return (rate / _centerRateThreshold) * self.cellSize.width / 2;
    }
    return copysignf(1.0, rate) * self.cellSize.width / 2;
}
- (CGFloat)translateZForDistanceRate:(CGFloat)rate {
    
    if (fabsf(rate) < _centerRateThreshold) {
        return 2 * self.cellSize.width * cos((rate / _centerRateThreshold) * M_PI_2);
    }
    return 0;
}

@end
