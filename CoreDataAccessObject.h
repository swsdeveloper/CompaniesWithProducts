//
//  CoreDataAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/15/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Product.h"

@class DataAccessObject;


@interface CoreDataAccessObject : NSObject <NSFileManagerDelegate>

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) NSString *databaseName;

@property (retain, nonatomic) NSString *databasePath;

- (id)init;

- (void)saveAllCompaniesInCoreData;

- (void)restoreAllCompaniesFromCoreData;

- (NSMutableArray *)retrieveAllActiveCompaniesFromCoreData;

- (void)updateCompanyInCoreData:(Company *)company;

- (void)updateProductInCoreData:(Product *)product;


@end
