//
//  CoverFlowViewController.m
//  CollectionViewSample
//
//  Created by ITmedia on 12/11/05.
//  Copyright (c) 2012年 ITmedia. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "MyCollectionViewCell.h"
#import "MyHeaderView.h"
#import "ExampleLayoutsDataSource.h"

@interface CoverFlowViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, copy) NSIndexPath *layoutIndexPath;
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
    
    self.toolbarItems = @[self.editButtonItem];
    
    if (self.layout) {
        [self.collectionView setCollectionViewLayout:self.layout animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setLayoutAtIndexPath:(NSIndexPath *)indexPath {
    [self setLayoutAtIndexPath:indexPath animation:NO];
}

- (void) setLayoutAtIndexPath:(NSIndexPath *)indexPath animation:(BOOL)animation {
    self.layoutIndexPath = indexPath;
    
    ExampleLayoutsDataSource *dataSource = [ExampleLayoutsDataSource sharedInstance];

    NSString *oldCellId = self.cellIdentifier;
    NSString *newCellId = [dataSource cellIdentifierAtIndexPath:indexPath];
    
    UICollectionViewLayout *layout = [dataSource layoutAtIndexPath:indexPath];
    [self.collectionView setCollectionViewLayout:layout animated:animation];
    self.collectionView.pagingEnabled = [dataSource pageEnabledAtIndexPath:indexPath];
    self.cellIdentifier = newCellId;
    
    self.title = [[ExampleLayoutsDataSource sharedInstance] titleForRowAtIndexPath:self.layoutIndexPath];
    
    if (![newCellId isEqualToString:oldCellId]) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView.collectionViewLayout invalidateLayout];
    }

}



- (IBAction)handleTapSegmentControl:(id)sender {
    UISegmentedControl *seg = sender;
    NSIndexPath *newIndexPath = nil;
    if (seg.selectedSegmentIndex == 0) {
        newIndexPath = [[ExampleLayoutsDataSource sharedInstance] previousIndexPath:self.layoutIndexPath];
    } else {
        newIndexPath = [[ExampleLayoutsDataSource sharedInstance] nextIndexPath:self.layoutIndexPath];
    }
    [self setLayoutAtIndexPath:newIndexPath animation:YES];
}

#pragma mark - 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];

    cell.titleLabel.text = [NSString stringWithFormat:@"%d-%d", indexPath.section, indexPath.row];
    CGFloat hue = (CGFloat)indexPath.row / [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    [cell setColor:[UIColor colorWithHue:hue saturation:0.5 brightness:1.0 alpha:1.0]];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MyHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        header.titleLabel.text = [NSString stringWithFormat:@"Section-%d", indexPath.section];
        return header;
    
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MyHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        header.titleLabel.text = [NSString stringWithFormat:@"Footer-%d", indexPath.section];
        return header;
    }
    
    return nil;
}


#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[[UIAlertView alloc] initWithTitle:@"Tap" message:[indexPath description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
