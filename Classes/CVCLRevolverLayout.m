//
//  MyCollectionViewLayout.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CVCLRevolverLayout.h"


@interface CVCLRevolverLayoutAxisView : UICollectionReusableView
@end

@interface CVCLRevolverLayout () 

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) UIEdgeInsets layoutInsets;

@end

#pragma mark -

@implementation CVCLRevolverLayout {
    CGFloat _rotationRadius;
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
        self.cellInterval = self.cellSize.height;
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
    self.cellSize = CGSizeMake(320, 50);
    self.cellInterval = self.cellSize.height;
    [self registerClass:[CVCLRevolverLayoutAxisView class] forDecorationViewOfKind:@"Axis"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setInitialValues];
    }
    return self;    
}

- (NSInteger)count {
    return [self.collectionView numberOfItemsInSection:0];
}

- (UIEdgeInsets) layoutInsets {
    CGFloat h_2 = self.collectionView.bounds.size.height / 2;
    CGFloat cellH_2 = self.cellSize.height / 2;
    return UIEdgeInsetsMake(h_2 - cellH_2, 0, h_2 + cellH_2 - _cellInterval, 0);
}

- (CGSize)collectionViewContentSize {
    CGSize size = self.collectionView.bounds.size;
    size.height = self.count * self.cellInterval + self.cellSize.height;
    UIEdgeInsets insets = self.layoutInsets;
    size.height += insets.top + insets.bottom;
    return size;
}

- (void)prepareLayout {
    [self updateCenterRateThreshold:self.collectionView.bounds];
}

- (CGFloat)cellsVerticalInterval {
    UIEdgeInsets insets = self.layoutInsets;
    return (self.collectionViewContentSize.height - insets.top - insets.bottom) / self.count;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect {
    if (self.count == 0) return [NSArray array];
    
    CGFloat cw = [self cellsVerticalInterval];
    NSInteger minRow = MAX(0, (NSInteger)floor((self.collectionView.contentOffset.y - self.layoutInsets.top) / cw));

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];

    UIEdgeInsets insets = self.layoutInsets;
    for (int i=minRow, cn = self.count; i < cn && (i-1) * cw - insets.left < self.collectionView.contentOffset.y + self.collectionView.bounds.size.height; i++) {
        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }

    return array;
}

- (UICollectionViewLayoutAttributes *)axisDecorationViewLayoutAttributes {
    UICollectionViewLayoutAttributes *decrationViewAttr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"Axis" withIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    CGFloat centerY = self.collectionView.contentOffset.y + self.collectionView.bounds.size.height / 2 - self.cellSize.height / 2;
    decrationViewAttr.size = CGSizeMake(100, 100);
    decrationViewAttr.center = CGPointMake(0, centerY);
    decrationViewAttr.zIndex = self.count;
    return decrationViewAttr;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (NSIndexPath *indexPath in [self indexPathsForItemsInRect:rect]) {
        [array addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    UICollectionViewLayoutAttributes *decrationViewAttr;
    decrationViewAttr = [self axisDecorationViewLayoutAttributes];
    
    [array addObject:decrationViewAttr];
    
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat ch = [self cellsVerticalInterval];
    
    CGFloat cellOffsetY = indexPath.row * ch + self.layoutInsets.top;
    CGFloat rate = [self rateFowCellOffsetY:cellOffsetY];
    CGFloat centerY = self.collectionView.contentOffset.y + self.collectionView.bounds.size.height / 2 - self.cellSize.height / 2;
    
    CGRect frame;
    frame.origin.y = centerY + sin(rate * M_PI_2) * _rotationRadius - self.cellSize.height / 2;
    frame.origin.x = cos(rate * M_PI_2) * _rotationRadius - self.cellSize.width / 2;
    frame.size = self.cellSize;
    
    attr.frame = frame;
    attr.zIndex = -indexPath.row;

    attr.transform3D = [self transformWithCellOffsetY:cellOffsetY];
    
    return attr;
}

- (void)updateCenterRateThreshold:(CGRect)newBounds {
    CGSize size = self.collectionView.bounds.size;
    _rotationRadius = MIN(size.width, size.height) / 2;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    [self updateCenterRateThreshold:newBounds];
    return YES;
}

#pragma mark - Decration view

- (CGFloat)rateFowCellOffsetY:(CGFloat)cellOffsetY {
    CGFloat bh = self.collectionView.bounds.size.height / 2;
    CGFloat offsetFromCenter = cellOffsetY - (self.collectionView.contentOffset.y + self.collectionView.bounds.size.height / 2);
    CGFloat rate = offsetFromCenter / bh;
    return rate;
}

- (CATransform3D)transformWithCellOffsetY:(CGFloat)cellOffsetY {
    static const CGFloat zDistance = 1200.0f;
    
    CGFloat rate = [self rateFowCellOffsetY:cellOffsetY];
    
    CATransform3D t = CATransform3DIdentity;
    //視点の距離
    t.m34 = 1.0f / -zDistance;
    
    // Affine変換の連結は順番を変えると結果が変わるので注意（行列の積だから）

    //位置
    t = CATransform3DTranslate(t,
                               [self translateXForDistanceRate:rate],
                               [self translateYForDistanceRate:rate],
                               [self translateZForDistanceRate:rate]);

    //角度
    t = CATransform3DRotate(t,
                            [self angleForDistanceRate:rate],
                            0.0f,
                            0.0f,
                            1.0f);
    return t;
}

- (CGFloat)angleForDistanceRate:(CGFloat)rate {
    static const CGFloat baseAngle = M_PI * 90 / 180; //degree
    
    return rate * baseAngle;
}

- (CGFloat)translateXForDistanceRate:(CGFloat)rate {
    return 0;
}

- (CGFloat)translateYForDistanceRate:(CGFloat)rate {
    return 0;
}

- (CGFloat)translateZForDistanceRate:(CGFloat)rate {
    return 0;
}

@end


#pragma mark - DecorationView

@implementation CVCLRevolverLayoutAxisView
+ (void)initialize {
    LOG(@"initialize");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
    
}

@end
