//
//  DataBaseAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/8/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Product.h"


@class DataAccessObject;

@class SQLiteAccessObject;


@interface DataBaseAccessObject : NSObject <NSFileManagerDelegate>

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) NSString *databaseName;

@property (retain, nonatomic) NSString *databasePath;

@property (retain, nonatomic) SQLiteAccessObject *sqlAO;

- (id)init;

- (void)saveAllCompaniesInSqlite;

- (void)restoreAllCompaniesFromSqlite;

- (NSMutableArray *)retrieveAllActiveCompaniesFromSql;

//- (NSMutableArray *)retrieveAllProductsFromSql;

- (void)updateCompanyInSqlite:(Company *)company;

- (void)updateProductInSqlite:(Product *)product;

@end
