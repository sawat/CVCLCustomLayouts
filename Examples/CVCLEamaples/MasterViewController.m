//
//  MasterViewController.m
//  CVCLEamaples
//
//  Created by 沢 辰洋 on 2012/11/07.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "MasterViewController.h"
#import "CoverFlowViewController.h"
#import "CVCLCoverFlowLayout.h"
#import "CVCLRevolverLayout.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}

@property (nonatomic, strong) NSArray * layouts;

@end

@implementation MasterViewController

+ (UICollectionViewFlowLayout *)flowLayoutWithItemSize:(CGSize)itemSize minimumLineSpacing:(CGFloat)minimumLineSpacing scrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = scrollDirection;
    layout.itemSize =itemSize;
    layout.minimumInteritemSpacing = minimumLineSpacing;
    return layout;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.layouts = @[@[
            [MasterViewController flowLayoutWithItemSize:CGSizeMake(150, 50) minimumLineSpacing:10 scrollDirection:UICollectionViewScrollDirectionVertical],
            [MasterViewController flowLayoutWithItemSize:CGSizeMake(100, 100) minimumLineSpacing:5 scrollDirection:UICollectionViewScrollDirectionHorizontal],
        ], @[
            [[CVCLCoverFlowLayout alloc] init],
            [[CVCLCoverFlowLayout alloc] initWithCellSize:CGSizeMake(80, 200)],
            [[CVCLCoverFlowLayout alloc] initWithCellSize:CGSizeMake(160, 100)],
        ], @[
            [[CVCLRevolverLayout alloc] init],
        ]
    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showCollectionView" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    
    CoverFlowViewController *dest = segue.destinationViewController;
    dest.layout = self.layouts[selected.section][selected.row];
}

@end
