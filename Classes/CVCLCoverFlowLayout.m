//
//  MyCollectionViewLayout.m
//  CollectionViewSample
//
//  Created by 沢 辰洋 on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CVCLCoverFlowLayout.h"

static NSString *kDecorationViewKindReflection = @"DecorationViewReflection";

@interface CVCLReflectionView : UICollectionReusableView
@property (nonatomic, copy) NSIndexPath * indexPath;
@property (nonatomic, strong) UIImageView * reflectionImageView;
@property (nonatomic, readonly) UICollectionView * parentCollectionView;
@property (nonatomic, readonly) UICollectionReusableView * relatedCell;
@end

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
    
    [self registerClass:[CVCLReflectionView class] forDecorationViewOfKind:kDecorationViewKindReflection];
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
    if (self.sectionIndexTable == nil) {
        [self prepareSectionIndexTable];
    }
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
        
        if (self.reflection) {
            [array addObject:[self layoutAttributesForDecorationViewOfKind:kDecorationViewKindReflection atIndexPath:indexPath]];
        }
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
    
    // カバーフローのセルやデコレーションビューと交差しない様に、手前に移動させる。
    // m34の設定をしないため、見た目上のサイズは変わらない
    attr.frame = frame;
    attr.transform3D = CATransform3DMakeTranslation(0, 0, 300);
    
    return attr;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    if (![decorationViewKind isEqualToString:kDecorationViewKindReflection]) {
        return nil;
    }
    
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind withIndexPath:indexPath];
    
    CGFloat cw = [self cellsHorizontalInterval];
    
    CGFloat cellOffsetX = [self totalIndexOfIndexPath:indexPath] * cw + self.layoutInsets.left;
    
    CGRect frame;
    frame.origin.x = cellOffsetX;
    frame.origin.y = (self.collectionView.bounds.size.height - self.cellSize.height) / 2.0;
    frame.size = self.cellSize;
    
    attr.frame = frame;
    
    attr.transform3D = [self transformWithCellOffsetX:cellOffsetX];
    attr.transform3D = CATransform3DTranslate(attr.transform3D, 0, self.cellSize.height, 0);
    
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
        return -1.0 - 2.0 * self.cellSize.width * (1.0 - cos((rate / _centerRateThreshold) * M_PI_2));
    }
    return -1.0 - 2.0 * self.cellSize.width;
}

#pragma mark - Update
- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [self prepareSectionIndexTable];
    [super prepareForCollectionViewUpdates:updateItems];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [self layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end

#pragma mark -

@implementation CVCLReflectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reflectionImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.reflectionImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.reflectionImageView.alpha = 0.5;
        [self addSubview:self.reflectionImageView];
    }
    return self;
}

- (UICollectionView *)parentCollectionView {
    return (UICollectionView *)self.superview;
}
- (UICollectionReusableView *)relatedCell {
    return [self.parentCollectionView cellForItemAtIndexPath:self.indexPath];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.indexPath = layoutAttributes.indexPath;
    self.reflectionImageView.image = [self reflectedImage:self.relatedCell withHeight:self.relatedCell.bounds.size.height];
}


CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	CGGradientRelease(grayScaleGradient);
	
	// return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (nil, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIView *)fromView withHeight:(NSUInteger)height
{
    if (!height) return nil;
    
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromView.bounds.size.width, height);
	
	// offset the context -
	// This is necessary because, by default, the layer created by a view for caching its content is flipped.
	// But when you actually access the layer content and have it rendered it is inverted.  Since we're only creating
	// a context the size of our reflection view (a fraction of the size of the main view) we have to translate the
	// context the delta in size, and render it.
	//
	CGFloat translateVertical= fromView.bounds.size.height - height;
	CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
	
	// render the layer into the bitmap context
	CALayer *layer = fromView.layer;
	[layer renderInContext:mainViewContentContext];
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	
	// convert the finished reflection image to a UIImage
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}


@end