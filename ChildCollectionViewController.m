//
//  ChildCollectionViewController.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.

// Noteworthy References:
// - Switching from XIB-based TableView to CollectionView: http://adoptioncurve.net/archives/2012/09/a-simple-uicollectionview-tutorial/



#import "ChildCollectionViewController.h"
#import "ChildCollectionViewCell.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"


static NSString *const cellIdentifier = @"cvCell";


@interface ChildCollectionViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ChildCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.dao = appDelegate.sharedDAO;
    
    // For testing
    // -----------
    //[self generateTestData];
    
    // NIB-based approach to using CollectionViewCell
    // ----------------------------------------------
    //UINib *cellNib = [UINib nibWithNibName:@"NibCell" bundle:nil];
    //[self.collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    // Custom Class-based approach to using CollectionViewCell
    // -------------------------------------------------------
    [self.collectionView registerClass:[ChildCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(235, 235)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

//- (void)generateTestData {
//    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
//    NSMutableArray *secondSection = [[NSMutableArray alloc] init];
//    for (int i=0; i<50; i++) {
//        [firstSection addObject:[NSString stringWithFormat:@"Cell %d", i]];
//        [secondSection addObject:[NSString stringWithFormat:@"item %d", i]];
//    }
//    self.dataArray = @[firstSection, secondSection];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource Methods:

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // For testing
    // -----------
    //return [self.dataArray count];
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // For testing
    // -----------
    //NSMutableArray *sectionArray = self.dataArray[section];
    //return [sectionArray count];
    
    NSInteger productCount = [self.dao getProductsCount];
    return productCount;
}

#pragma mark - UICollectionView Delegate FlowLayout Methods:

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // For testing
    // -----------
    //NSMutableArray *data = self.dataArray[indexPath.section];
    //NSString *cellData = data[indexPath.row];

    // NIB-based approach to using CollectionViewCell
    // ----------------------------------------------
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];    // cast UIView to UILabel
    //[titleLabel setText:cellData];
    
    // Custom Class-based approach to using CollectionViewCell
    // -------------------------------------------------------
    ChildCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // For testing
    // -----------
    //[cell.titleLabel setText:cellData];
    
    Product *aProduct = [[self.dao getProductAtIndex:indexPath.row] retain];
    
    if (aProduct) {
        cell.titleLabel.text = aProduct.name;
        cell.imageView.image = aProduct.logo;
    }
    
    [aProduct release];
    aProduct = nil;
    
    return cell;
}

// Returns spacing between the cells, headers, and footers

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return (UIEdgeInsets){.left = 20, .right = 20, .top = 20, .bottom = 20};
}

@end
