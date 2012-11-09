//
//  MasterViewController.m
//  CVCLEamaples
//
//  Created by 沢 辰洋 on 2012/11/07.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "MasterViewController.h"
#import "ExampleLayoutsDataSource.h"
#import "CoverFlowViewController.h"
#import "CVCLCoverFlowLayout.h"
#import "CVCLRevolverLayout.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = [ExampleLayoutsDataSource sharedInstance];
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
    [dest setLayoutAtIndexPath:selected];
}

@end
