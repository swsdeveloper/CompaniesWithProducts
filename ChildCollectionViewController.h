//
//  ChildCollectionViewController.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 2/16/15.
//  Copyright (c) 2015 Steven Shatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataAccessObject;

@interface ChildCollectionViewController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (retain, nonatomic) DataAccessObject *dao;

@end
