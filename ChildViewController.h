//
//  ChildViewController.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

// Display Products for selected Company; user can select a Product

#import <UIKit/UIKit.h>


@class DataAccessObject;

@class DetailViewController;


@interface ChildViewController : UITableViewController

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) IBOutlet DetailViewController *detailVC;

@end
