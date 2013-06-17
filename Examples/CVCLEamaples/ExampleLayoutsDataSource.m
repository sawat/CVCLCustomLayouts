//
//  ExampleLayoutsDataSource.m
//  CVCLEamaples
//
//  Created by 沢 辰洋 on 12/11/09.
//  Copyright (c) 2012年 沢 辰洋. All rights reserved.
//

#import "ExampleLayoutsDataSource.h"
#import "CVCLCoverFlowLayout.h"
#import "CVCLRevolverLayout.h"
#import "CVCLHomeIconLayout.h"
#import "CVCLStickyHeaderFlowLayout.h"

static NSString * const kSectionTitle = @"sectionTitle";
static NSString * const kRows = @"rows";
static NSString * const kRowTitle = @"rowTitle";
static NSString * const kLayout = @"layout";
static NSString * const kPaging = @"paging";
static NSString * const kCellIdentifier = @"cellId";

@interface ExampleLayoutsDataSource ()
@property (nonatomic, strong) NSArray *sections;
@end

@implementation ExampleLayoutsDataSource

+ (ExampleLayoutsDataSource *)sharedInstance {
    static ExampleLayoutsDataSource * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


+ (UICollectionViewFlowLayout *)flowLayoutWithItemSize:(CGSize)itemSize minimumLineSpacing:(CGFloat)minimumLineSpacing scrollDirection:(UICollectionViewScrollDirection)scrollDirection {

    return [self flowLayoutWithItemSize:itemSize minimumLineSpacing:minimumLineSpacing scrollDirection:scrollDirection class:[UICollectionViewFlowLayout class]];
}

+ (UICollectionViewFlowLayout *)flowLayoutWithItemSize:(CGSize)itemSize minimumLineSpacing:(CGFloat)minimumLineSpacing scrollDirection:(UICollectionViewScrollDirection)scrollDirection class:(Class)layoutClass {
    UICollectionViewFlowLayout *layout = [[layoutClass alloc] init];
    layout.scrollDirection = scrollDirection;
    layout.itemSize =itemSize;
    layout.minimumInteritemSpacing = minimumLineSpacing;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    if (scrollDirection == UICollectionViewScrollDirectionVertical) {
        layout.headerReferenceSize = CGSizeMake(320, 30);
        layout.footerReferenceSize = CGSizeMake(320, 60);
    } else {
        layout.headerReferenceSize = CGSizeMake(40, 60);
        layout.footerReferenceSize = CGSizeMake(40, 60);
    }
    return layout;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        CVCLCoverFlowLayout *layoutWithDeco = [[CVCLCoverFlowLayout alloc] initWithCellSize:CGSizeMake(150, 150)];
        layoutWithDeco.reflection = YES;
        
        CVCLHomeIconLayout *iconLayout2 = [[CVCLHomeIconLayout alloc] init];
        iconLayout2.headerHeight = 30;
        iconLayout2.footerHeight = 40;
        iconLayout2.cellSize = CGSizeMake(64, 72);
        
        self.sections = @[
          @{kSectionTitle : @"FlowLayout",
            kRows: @[ @{kRowTitle:@"Verical",  kLayout: [ExampleLayoutsDataSource flowLayoutWithItemSize:CGSizeMake(145, 50) minimumLineSpacing:10 scrollDirection:UICollectionViewScrollDirectionVertical]}, @{kRowTitle:@"Horizontal",  kLayout: [ExampleLayoutsDataSource flowLayoutWithItemSize:CGSizeMake(105, 35) minimumLineSpacing:10 scrollDirection:UICollectionViewScrollDirectionHorizontal], kPaging:@YES}],
            },
          @{kSectionTitle : @"CoverFlow",
            kRows: @[ @{kRowTitle:@"CoverFlow 1", kLayout:[[CVCLCoverFlowLayout alloc] init]}, @{kRowTitle:@"CoverFlow 2", kLayout:[[CVCLCoverFlowLayout alloc] initWithCellSize:CGSizeMake(80, 200)]}, @{kRowTitle:@"CoverFlow 3", kLayout:[[CVCLCoverFlowLayout alloc] initWithCellSize:CGSizeMake(160, 100)]}, @{kRowTitle:@"CoverFlow with DecorationView", kLayout:layoutWithDeco}],
            },
          @{kSectionTitle : @"Revolver",
            kRows: @[ @{kRowTitle:@"Revolver 1", kLayout:[[CVCLRevolverLayout alloc] init]}],
            },
          @{kSectionTitle : @"Homescreen Icons",
            kRows: @[ @{kRowTitle:@"Icons", kLayout:[[CVCLHomeIconLayout alloc] init], kCellIdentifier:@"IconCell", kPaging:@YES},
                      @{kRowTitle:@"Icons with Header/Footer", kLayout:iconLayout2, kCellIdentifier:@"IconCell", kPaging:@YES}],
            },
          @{kSectionTitle : @"Sticky Header FlowLayout",
            kRows: @[ @{kRowTitle:@"Verical",  kLayout: [ExampleLayoutsDataSource flowLayoutWithItemSize:CGSizeMake(93, 50) minimumLineSpacing:10 scrollDirection:UICollectionViewScrollDirectionVertical class:[CVCLStickyHeaderFlowLayout class]]}, @{kRowTitle:@"Horizontal",  kLayout: [ExampleLayoutsDataSource flowLayoutWithItemSize:CGSizeMake(100, 100) minimumLineSpacing:10 scrollDirection:UICollectionViewScrollDirectionHorizontal class:[CVCLStickyHeaderFlowLayout class]], kPaging:@NO}],
            },
        ];
    }
    return self;
}

- (NSDictionary *)layoutDictAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.sections[indexPath.section] objectForKey:kRows] objectAtIndex:indexPath.row];
}

- (NSString *)titleForHeaderInSection:(NSInteger)section {
    return [self.sections[section] objectForKey:kSectionTitle];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self layoutDictAtIndexPath:indexPath] objectForKey:kRowTitle];
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    return [[self layoutDictAtIndexPath:indexPath] objectForKey:kCellIdentifier] ?: @"Cell";
}

- (BOOL)pageEnabledAtIndexPath:(NSIndexPath *)indexPath {
    return [[[self layoutDictAtIndexPath:indexPath] objectForKey:kPaging] boolValue];
}

- (UICollectionViewLayout *)layoutAtIndexPath:(NSIndexPath *)indexPath {
    return [[self layoutDictAtIndexPath:indexPath] objectForKey:kLayout];
}

#pragma mark -

- (NSIndexPath *)nextIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentRows = [[[self.sections objectAtIndex:indexPath.section] objectForKey:kRows] count];
    if (currentRows == indexPath.row+1) {
        return [NSIndexPath indexPathForRow:0 inSection:((indexPath.section + 1) % self.sections.count)];
    } else {
        return [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    }
}

- (NSIndexPath *)previousIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSInteger newSection = indexPath.section != 0 ? indexPath.section - 1 : self.sections.count - 1;
        NSInteger newRows = [[[self.sections objectAtIndex:newSection] objectForKey:kRows] count];
        return [NSIndexPath indexPathForRow:newRows-1 inSection:newSection];
    } else {
        return [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
    }
}


#pragma mark - 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sections[section] objectForKey:kRows] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
    
    return cell;
}


@end
