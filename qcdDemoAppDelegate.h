//
//  qcdDemoAppDelegate.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import <UIKit/UIKit.h>


@class DataAccessObject;


@interface qcdDemoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (assign, nonatomic) DataAccessObject *sharedDAO;

@end
