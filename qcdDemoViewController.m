//
//  qcdDemoViewController.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "qcdDemoViewController.h"
#import "Constants.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "StockQuoteFetcher.h"
#import "ChildViewController.h"
#import "ChildCollectionViewController.h"


@interface qcdDemoViewController ()

@end

@implementation qcdDemoViewController

- (id)initWithStyle:(UITableViewStyle)style {
    NSLog(@"in qcdDemoViewController initWithStyle");
    self = [super initWithStyle:style];
    
    if (self) {
        // initial setup goes here
//        _aStockQuoteFetcher = [[StockQuoteFetcher alloc] init];
    }
    
    //self.tableView.delegate = self;   // Not necessary since tableView delegate & datasource are defined in XIB

    return self;
}

- (void)dealloc {
    NSLog(@"In qcdDemoViewController dealloc");
//    [_aStockQuoteFetcher release];
    [super dealloc];
}

- (void)viewDidLoad {
    NSLog(@"in qcdDemoViewController viewDidLoad");
   
    [super viewDidLoad];
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.dao = appDelegate.sharedDAO;
    
    [self.dao restoreAllCompanies];
    
//    NSLog(@"self.dao.companies[0].products[0].name = %@", [[[self.dao companies] [0] products][0] name]);
//    NSLog(@"self.dao.companies[0].products[0].logo = %@", [[[[self.dao companies] [0] products][0] logo] description]);
//    NSLog(@"self.dao.companies[0].products[0].url = %@", [[[[self.dao companies] [0] products][0] url] description]);
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.title = @"Mobile device makers";   // View controller title
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"in qcdDemoViewController viewWillAppear");
    [super viewWillAppear:animated];
    
    // Get current stock prices for current set of companies
    
    // Synchronous Call - should not be used
    // self.stockPrices = [StockQuoteFetcher fetchQuotesSynchronouslyFor:[self.dao getAllCompanyStockSymbols]];
    // NSLog(@"self.stockPrices:\n%@\n", [self.stockPrices description]);
    
    StockQuoteFetcher *s = [[StockQuoteFetcher alloc] init];
    self.aStockQuoteFetcher = s;
    [s release];
    s = nil;
    
    // aStockQuoteFetcher will be released at the end of |reloadTableView|
    // The StockQuoteFetcher method |fetchQuotesAsynchronously...| requests a URL and whether that request fails or succeeeds,
    // reloadTableView is called before exiting
    
    NSArray * setOfStockSymbols = [[self.dao getAllCompanyStockSymbols] retain];
    
    [self.aStockQuoteFetcher fetchQuotesAsynchronouslyForViewController:self forStockSymbols:setOfStockSymbols];  // updates self.dao.stockPrices dictionary
    
    [self.tableView reloadData];

    [setOfStockSymbols release];
    setOfStockSymbols = nil;
    
//    NSLog(@"self.dao.companies[0].products[0].name = %@", [[[self.dao companies] [0] products][0] name]);
//    NSLog(@"self.dao.companies[0].products[0].logo = %@", [[[[self.dao companies] [0] products][0] logo] description]);
//    NSLog(@"self.dao.companies[0].products[0].url = %@", [[[[self.dao companies] [0] products][0] url] description]);
    
    NSLog(@"End of: qcdDemoViewController viewWillAppear\n");
}

// This rtn is called by StockQuoteFetcher after stock prices are received and loaded into dao.stockPrices dictionary
//- (void)reloadTableViewAfterReturnFromStockQuoteFetcher:(StockQuoteFetcher *)sqf {
- (void)reloadTableView {
    NSLog(@"in qcdDemoViewController reloadTableViewAfterReturnFromStockQuoteFetcher");
    
    [self.tableView reloadData];
    
    [_aStockQuoteFetcher release];
    _aStockQuoteFetcher = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"in qcdDemoViewController viewWillDisappear\n");
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"in qcdDemoViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"in qcdDemoViewController numberOfSectionsInTableView");
    //#warning Potentially incomplete method implementation.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger companyCount = [self.dao getCompaniesCount];
    
    NSLog(@"in qcdDemoViewController numberOfRowsInSection: %ld", (long)companyCount);
    
    return companyCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"in qcdDemoViewController cellForRowAtIndexPath");

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Company *aCompany = [[self.dao getCompanyAtIndex:indexPath.row] retain];
    
    if (aCompany) {
        cell.imageView.image = aCompany.logo;
        
        NSLog(@"self.dao.stockPrices = %@", [self.dao.stockPrices description]);
        
        NSString *stockPrice = [[self.dao.stockPrices valueForKey:aCompany.stockSymbol] retain];
        
        cell.textLabel.text = [[aCompany.name stringByAppendingString:@" Mobile Devices - "]
                               stringByAppendingString:aCompany.stockSymbol];        
        if (stockPrice) {
            cell.textLabel.text = [[cell.textLabel.text stringByAppendingString:@": "] stringByAppendingString:stockPrice];
        }
        
        [stockPrice release];
        stockPrice = nil;
    }
    [aCompany release];
    aCompany = nil;

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"in qcdDemoViewController canEditRowAtIndexPath");
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"in qcdDemoViewController commitEditingStyle");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the company from the data source
        [self.dao removeCompanyAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];   // delete the company from the tableView

        [tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    //NSLog(@"in qcdDemoViewController moveRowAtIndexPath");
    
    if (sourceIndexPath.row != destinationIndexPath.row) {
        [self.dao moveCompanyFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"in qcdDemoViewController canMoveRowAtIndexPath");
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"In qcdDemoViewController didSelectRowAtIndexPath: row = %ld", (long)indexPath.row);
    
    Company *aCompany = [[self.dao getCompanyAtIndex:indexPath.row] retain];
    if (aCompany) {
        self.childVC.title = aCompany.name;
        [self.dao setProducts:aCompany.products];
        self.childVC.dao = self.dao;
    }
    [aCompany release];
    aCompany = nil;
    
// Debugging Code:
//    NSLog(@"self.childVC.title = %@", self.childVC.title);
//
//    NSLog(@"self.dao.products[0].name = %@", [[self.dao products][0] name]);
//    NSLog(@"self.dao.products[0].url = %@", [[[self.dao products][0] url] description]);
//    NSLog(@"self.dao.products[0].logo = %@", [[[self.dao products][0] logo] description]);
//
//    or
//
//    NSArray *prods = [self.dao products];
//    Product *prod1 = prods[0];
//    NSString *name = [prod1 name];
//    NSLog(@"self.dao.products[0].name = %@", name);
//    UIImage *logo = [prod1 logo];
//    NSString *descl = [logo description];
//    NSLog(@"self.dao.products[0].logo = %@", descl);
//    NSURL *url = [prod1 url];
//    NSString *urlString = [url absoluteString];
//    NSLog(@"self.dao.products[0].url = %@", urlString);
    
    [self.navigationController pushViewController:self.childVC animated:YES];
    
    // To test CollectionView instead of TableView, un-comment the following (and comment the pushVC line above)
    //ChildCollectionViewController *collectionViewChildVC = [[ChildCollectionViewController alloc] init];
    //[self.navigationController pushViewController:collectionViewChildVC animated:YES];
}

@end
