//
//  ChildViewController.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "ChildViewController.h"
#import "Constants.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "DetailViewController.h"


@interface ChildViewController ()

@end

@implementation ChildViewController

- (id)initWithStyle:(UITableViewStyle)style {
    NSLog(@"in ChildViewController initWithStyle");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    NSLog(@"in ChildViewController initWithStyle");
    
    [super viewDidLoad];
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.dao = appDelegate.sharedDAO;

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"in ChildViewController viewWillAppear");
    //NSLog(@"self.title = %@", self.title);
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"in ChildViewController viewWillDisappear\n");
    
    [super viewWillDisappear:animated];
    
    // If user navigates back to parent view while Editing Mode is still in effect, turn off Editing Mode
    if (self.isEditing == YES) {
        [self setEditing:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    NSLog(@"in ChildViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
     
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //NSLog(@"in ChildViewController numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger productCount = [self.dao getProductsCount];
    
    NSLog(@"in ChildViewController numberOfRowsInSection: %ld", (long)productCount);
    
    return productCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"in ChildViewController cellForRowAtIndexPath");
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Product *aProduct = [[self.dao getProductAtIndex:indexPath.row] retain];
    
    if (aProduct) {
        cell.textLabel.text = aProduct.name;
        cell.imageView.image = aProduct.logo;
    }
    
    [aProduct release];
    aProduct = nil;

    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"in ChildViewController canEditRowAtIndexPath");
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"in ChildViewController commitEditingStyle");
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        [self.dao removeProductAtIndex:indexPath.row];  // flag this product as Deleted in the products array
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView reloadData];
    
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

    //NSLog(@"in ChildViewController moveRowAtIndexPath");
    
    if (sourceIndexPath.row != destinationIndexPath.row) {
        [self.dao moveProductFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"in ChildViewController canMoveRowAtIndexPath");
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"In ChildViewController didSelectRowAtIndexPath: row = %ld", (long)indexPath.row);
    
    Product *aProduct = [[self.dao getProductAtIndex:indexPath.row] retain];
    
    if (aProduct) {
        NSLog(@"aProduct.name = %@", aProduct.name);
        NSLog(@"aProduct.logo = %@", [aProduct.logo description]);
        NSLog(@"aProduct.url = %@", [aProduct.url description]);
    }
    
    if (aProduct) {
        self.detailVC.title  = aProduct.name;
        self.detailVC.url = aProduct.url;
        //NSLog(@"self.detailVC.title = %@\n", self.detailVC.title);
        //NSLog(@"url = %@\n", [self.detailVC.url description]);
    }
    
    [aProduct release];
    aProduct = nil;
    
// ***************************************************************************************************************************************************************
// Debugging Code:
//    [self loadRequestFromString:@"http://google.com"];
//    [self loadRequestFromURL:self.detailVC.url];
// ***************************************************************************************************************************************************************
    
    [self.navigationController pushViewController:self.detailVC animated:YES];
}

// ***************************************************************************************************************************************************************
// The methods below were added for debugging purposes
//  - they were called (but are not REM-out) from tableView:didSelectRowAtIndexPath: above
//
//- (void)loadRequestFromURL:(NSURL*)url
//{
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [self.view addSubview:webView];
//    [webView loadRequest:urlRequest];
//}
//
//- (void)loadRequestFromString:(NSString*)urlString
//{
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    [self.view addSubview:webView];
//    [webView loadRequest:urlRequest];
//}
// ***************************************************************************************************************************************************************

@end
