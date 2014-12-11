//
//  qcdDemoViewController.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

// Display List of Companies; user can select a Company

#import <UIKit/UIKit.h>


@class DataAccessObject;

@class ChildViewController;

@class StockQuoteFetcher;


@interface qcdDemoViewController : UITableViewController

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) IBOutlet ChildViewController *childVC;

@property (retain, nonatomic) StockQuoteFetcher *aStockQuoteFetcher;


// @property (retain, nonatomic) NSDictionary *stockPrices;  // This was used for synchronous call to StockQuoteFetcher - should not be used


- (void)reloadTableView;

@end
