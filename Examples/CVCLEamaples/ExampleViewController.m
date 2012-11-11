//
//  CoverFlowViewController.m
//  CollectionViewSample
//
//  Created by 沢 辰洋 on 12/11/05.
//  Copyright (c) 2012年 沢 辰洋 All rights reserved.
//

#import "ExampleViewController.h"
#import "MyCollectionViewCell.h"
#import "MyHeaderView.h"
#import "ExampleLayoutsDataSource.h"

static NSInteger kInitialItemsInSection = 30;

@interface ExampleViewController () <UICollectionViewDelegateFlowLayout>
@property (nonatomic, copy) NSIndexPath *layoutIndexPath;
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation ExampleViewController

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
    self.items = [NSMutableArray array];
    for (int sec=0; sec<2; sec++) {
        NSMutableArray *sectionItems = [NSMutableArray arrayWithCapacity:kInitialItemsInSection];
        for (int item = 0; item < kInitialItemsInSection; item++) {
            [sectionItems addObject:@(item)];
        }
        [self.items addObject:sectionItems];
    }
    
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
    return self.items.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];

    NSInteger itemNumber  = [[self.items[indexPath.section] objectAtIndex:indexPath.row] intValue];
    cell.titleLabel.text = [NSString stringWithFormat:@"%d-%d", indexPath.section, itemNumber];
    CGFloat hue = (float)itemNumber / kInitialItemsInSection;
    [cell setColor:[UIColor colorWithHue:hue saturation:0.5 brightness:1.0 alpha:1.0]];
    
    [cell setEditing:self.editing animated:NO];
    
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    for (MyCollectionViewCell *cell in [self.collectionView visibleCells]) {
        [cell setEditing:editing animated:animated];
    }
}

#pragma mark -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.editing) {
        [self.items[indexPath.section] removeObjectAtIndex:indexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Tap" message:[indexPath description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

@end
