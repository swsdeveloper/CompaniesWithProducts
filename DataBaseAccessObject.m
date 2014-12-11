//
//  DataBaseAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/8/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "DataBaseAccessObject.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "SQLiteAccessObject.h"
#import "Constants.h"


/*
 
 *******************
 * Database Schema *
 *******************
 
 CREATE TABLE `Companies` (
	`CompanyName`	TEXT NOT NULL UNIQUE,
	`CoLogo`	TEXT,
	`CoStockSymbol`	TEXT,
	`CoDeleted`	INTEGER,
	`CoSortID`	INTEGER,
	PRIMARY KEY(CompanyName)
 )
 
 CREATE TABLE "Products" (
	`ProductName`	TEXT NOT NULL UNIQUE,
	`ProdCompany`	TEXT NOT NULL,
	`ProdLogo`	TEXT,
	`ProdUrl`	TEXT,
	`ProdDeleted`	INTEGER,
	`ProdSortID`	INTEGER,
	PRIMARY KEY(ProductName)
 )
 
 */


@implementation DataBaseAccessObject

- (id)init {
    self = [super init];
    if (self) {
        _databasePath = @"/Users/stevenshatz/Turn_To_Tech/Databases/Companies_and_Products";
        _sqlAO = [[SQLiteAccessObject alloc] initWithDatabase:_databasePath];
    }
    return self;
}

- (void)dealloc {
    [_databasePath release];
    [_sqlAO release];
    [super dealloc];
}


- (void)saveAllCompaniesInSqlite {
    NSLog(@"in DataBaseAccessObject saveAllCompaniesInSqlite");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    for (Company *company in self.dao.companies) {
        
        for (Product *product in company.products) {
            
            [self updateProductInSqlite:product];
        }
        
        [self updateCompanyInSqlite:company];
    }
    NSLog(@"Finishing saveAllCompaniesInSqlite\n");
}

- (void)restoreAllCompaniesFromSqlite {
    NSLog(@"in DataBaseAccessObject restoreAllCompaniesFromSqlite");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    NSString *databasePath = self.databasePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];    // defaultManager = the shared (singleton) file manager object
    
    if (![fileManager fileExistsAtPath:databasePath]) {
        [self.dao.companies removeAllObjects];  // If database not found, force load of default test data
        return;
    }
    
    self.dao.companies = [[self retrieveAllActiveCompaniesFromSql] retain];
    
    // The companies array needs to be sorted by company.sortID:
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.dao.companies sortUsingDescriptors:sortDescriptors];
    [sortDescriptor release];
    
    NSLog(@"Companies after sorting:\n");
    for (Company *company in self.dao.companies) {
        NSLog(@"%@ : %ld", company.name, company.sortID);
    }
    
    NSLog(@"Finishing restoreAllCompaniesFromSqlite\n");
}

- (NSMutableArray *)retrieveAllActiveCompaniesFromSql {
    
    NSMutableArray *dbCompanies = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSMutableArray *dbProducts = [self retrieveAllActiveProductsFromSql];
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        const char *sql_stmt = "SELECT * FROM COMPANIES";
        
        int prepareRc = [self.sqlAO sqlPrepareStmt:sql_stmt];
        
        if (prepareRc == SQLITE_OK) {
            
            while ([self.sqlAO sqlStep] == SQLITE_ROW) {
                
                int coDeleted = sqlite3_column_int(self.sqlAO.preparedStmt, 3);
                // 4th column (field) in returned Row
                
                if (!coDeleted) {
                    
                    NSString *companyName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 0)];
                    // 1st column (field) in returned Row
                    
                    NSString *coLogo = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 1)];
                    // 2nd column (field) in returned Row
                    
                    NSString *coStockSymbol = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 2)];
                    // 3rd col (field) in returned Row
                    
                    int coSortID = sqlite3_column_int(self.sqlAO.preparedStmt, 4);
                    // 5th column (field) in returned Row
                    
                    Company *company = [[Company alloc] init];
                    
                    [company setName: companyName];
                    [company setLogo: [UIImage imageNamed: coLogo]];
                    [company setStockSymbol: coStockSymbol];
                    [company setProducts:[[NSMutableArray alloc] initWithObjects:nil]];
                    [company setDeleted:coDeleted];
                    [company setSortID:coSortID];
                    
                    for (Product *product in dbProducts) {
                        if ([product.companyName isEqualToString:companyName]) {
                            [company.products addObject:product];
                        }
                    }
                    
                    // The products array needs to be sorted by product.sortID:
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
                    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                    [company.products sortUsingDescriptors:sortDescriptors];
                    [sortDescriptor release];
                    
                    NSLog(@"Products after sorting:\n");
                    for (Product *product in company.products) {
                        NSLog(@"%@ : %ld", product.name, product.sortID);
                    }
                    
                    [dbCompanies addObject:company];
                }
            }
        
            [self.sqlAO sqlFinalizePreparedStmt];
        
        } else {
            NSLog(@"\n\nCompany Prepare Failed with return code: %d", prepareRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nCompany Open Database Failed with return code: %d", openRc);
    }
    
    return dbCompanies;
}

- (NSMutableArray *)retrieveAllActiveProductsFromSql {
    
    NSMutableArray *dbProducts = [[NSMutableArray alloc] initWithObjects:nil];
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        const char *sql_stmt = "SELECT * FROM PRODUCTS";
        
        int prepareRc = [self.sqlAO sqlPrepareStmt:sql_stmt];
        
        if (prepareRc == SQLITE_OK) {
            
            while ([self.sqlAO sqlStep] == SQLITE_ROW) {
                
                int prodDeleted = sqlite3_column_int(self.sqlAO.preparedStmt, 4);
                // 5th column (field) in returned Row
                
                if (!prodDeleted) {
                    
                    NSString *productName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 0)];
                    // 1st column (field) in returned Row
                    
                    NSString *prodCompanyName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 1)];
                    // 2nd col (field) in returned Row
                    
                    NSString *prodLogo = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 2)];
                    // 3rd col (field) in returned Row
                    
                    NSString *prodUrl = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.sqlAO.preparedStmt, 3)];
                    // 4th col (field) in returned Row
                    
                    int prodSortID = sqlite3_column_int(self.sqlAO.preparedStmt, 5);
                    // 6th column (field) in returned Row
                    
                    Product *product = [[Product alloc] init];
                    
                    [product setName: productName];
                    [product setCompanyName: prodCompanyName];
                    [product setLogo: [UIImage imageNamed: prodLogo]];
                    [product setUrl: [NSURL URLWithString: prodUrl]];
                    [product setDeleted:prodDeleted];
                    [product setSortID:prodSortID];

                    [dbProducts addObject:product];
                }
            }
            
            [self.sqlAO sqlFinalizePreparedStmt];
            
        } else {
            NSLog(@"\n\nProducts Prepare Failed with return code: %d", prepareRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nProducts Open Database Failed with return code: %d", openRc);
    }
    return dbProducts;
}

- (void)updateCompanyInSqlite:(Company *)company {
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *updateStmt = [NSString stringWithFormat:@"UPDATE COMPANIES SET CODELETED = '%d', COSORTID = '%ld' WHERE COMPANYNAME = \"%@\"", (company.deleted ? 1 : 0), company.sortID, company.name];
        
        const char *sql_stmt = [updateStmt UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc != SQLITE_OK) {
            NSLog(@"\n\nUpdate Company Failed with return code: %d", execRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nUpdate Company Open Database Failed with return code: %d", openRc);
    }
}

- (void)updateProductInSqlite:(Product *)product {
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *updateStmt = [NSString stringWithFormat:@"UPDATE PRODUCTS SET PRODDELETED = '%d', PRODSORTID = '%ld' WHERE PRODUCTNAME = \"%@\"", (product.deleted ? 1 : 0), product.sortID, product.name];
        
        const char *sql_stmt = [updateStmt UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc != SQLITE_OK) {
            NSLog(@"\n\nUpdate Product Failed with return code: %d", execRc);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nUpdate Product Open Database Failed with return code: %d", openRc);
    }
}

@end
