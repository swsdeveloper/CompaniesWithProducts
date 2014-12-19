//
//  DataAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import <Foundation/Foundation.h>
#import "Company.h"
#import "Product.h"


@class UserDefaultsAccessObject;

@class DataBaseAccessObject;

@class CoreDataAccessObject;


@interface DataAccessObject : NSObject {
        
    int persistentStoreType;
    
    enum {
        useNSUserDefaults = 1,
        useSqlite = 2,
        useCoreData = 3
    };
    
    NSArray *_persistentStoreNames;
    
}

@property (retain, nonatomic) NSMutableArray *companies; // Array of Company objects

@property (retain, nonatomic) NSMutableArray *products;  // Products Array for a selected Company

@property (retain, nonatomic) NSMutableArray *stockSymbols;  // Array of all company Stock Symbols (set in the *.m file in getAllCompanyStockSymbols)

@property (retain, nonatomic) NSMutableDictionary *stockPrices;  // Dictionary containing all company Stock Symbols and Prices (set by StockQuoteFetcher.m)

@property (retain, nonatomic) UserDefaultsAccessObject *uDAO;

@property (retain, nonatomic) DataBaseAccessObject *dBAO;

@property (retain, nonatomic) CoreDataAccessObject *cDAO;


// Class method for creating Singleton object
+ (id)createSharedDataAccessObject;

- (NSInteger)getCompaniesCount;
- (Company *)getCompanyAtIndex:(NSInteger)index;
- (void)removeCompanyAtIndex:(NSInteger)index;
- (void)moveCompanyFromIndex:(NSInteger)from toIndex:(NSInteger)to;

- (NSArray *)getAllCompanyStockSymbols;

- (NSInteger)getProductsCount;
- (Product *)getProductAtIndex:(NSInteger)index;
- (void)removeProductAtIndex:(NSInteger)index;
- (void)moveProductFromIndex:(NSInteger)from toIndex:(NSInteger)to;

- (void)saveAllCompanies;
- (void)restoreAllCompanies;

@end
