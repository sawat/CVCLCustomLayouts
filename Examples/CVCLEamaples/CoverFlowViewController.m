//
//  CoverFlowViewController.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "MyCollectionViewCell.h"
#import "CVCLCoverFlowLayout.h"

@interface CoverFlowViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation CoverFlowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.layout) {
        [self.collectionView setCollectionViewLayout:self.layout animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
    CGFloat hue = (CGFloat)indexPath.row / [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    cell.titleLabel.backgroundColor = [UIColor colorWithHue:hue saturation:0.5 brightness:1.0 alpha:1.0];
    return cell;
}

- (IBAction)handleFlowLayout:(id)sender {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [self.collectionView setCollectionViewLayout:layout animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    });
}
- (IBAction)handleCoverflow:(id)sender {
    [self.collectionView setCollectionViewLayout:[[CVCLCoverFlowLayout alloc] init] animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    });
}

#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}
@end
