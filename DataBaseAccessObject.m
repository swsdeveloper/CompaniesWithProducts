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

- (void)dealloc {
    [_databasePath release];
    [_sqlAO release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _databaseName = @"CompaniesProductsDatabase";
        
        NSLog(@"in DBAO init - database: %@", _databaseName);

        NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // returns array of current user's |documents| directories (but there's probably only one)
        
        NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];  // point to current user's |documents| directory (in iOS sandbox)
        
        _databasePath = [documentsDirectory stringByAppendingPathComponent:_databaseName];   // full path to our SQL database
        
        [self checkAndCreateDatabase];
        
        _sqlAO = [[SQLiteAccessObject alloc] initWithDatabase:_databasePath];
    }
    return self;
}

- (void)checkAndCreateDatabase {
    NSLog(@"in DBAO checkAndCreateDatabase");
    
    //Check if the database has been saved to the users device, if not then copy it over
    
    //Create a file manager object, we will use this to check the status of the databse and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Check if the database has already been created in the users filesystem
    //If not then proceed to copy the database from the application to the users filesystem
    if (![fileManager fileExistsAtPath:_databasePath]) {
    
        //Get the path to the database in the application package
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_databaseName];
    
        NSLog(@"\n\nCopy pre-loaded database from: %@", databasePathFromApp);
        NSLog(@"\nTo: %@\n\n", _databasePath);
        
        //Copy the database from the package to the usrrs filesystem
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:databasePathFromApp toPath:_databasePath error:&error];
        
        /*
         When copying items, the current process must have permission to read the file or directory at srcPath and write the parent directory of dstPath. If the item at srcPath is a directory, this method copies the directory and all of its contents, including any hidden files. If a file with the same name already exists at dstPath, this method aborts the copy attempt and returns an appropriate error. If the last component of srcPath is a symbolic link, only the link is copied to the new path.
        
        Prior to copying an item, the file manager asks its delegate if it should actually do so for each item. It does this by calling the fileManager:shouldCopyItemAtURL:toURL: method; if that method is not implemented it calls the fileManager:shouldCopyItemAtPath:toPath: method instead. If the delegate method returns YES, or if the delegate does not implement the appropriate methods, the file manager copies the given file or directory. If there is an error copying an item, the file manager may also call the delegate’s fileManager:shouldProceedAfterError:copyingItemAtURL:toURL: or fileManager:shouldProceedAfterError:copyingItemAtPath:toPath: method to determine how to proceed.
         */
        
        if (success == NO) {
            NSLog(@"\nDatabase Copy Error: %@\n", error.localizedDescription);
        } else {
            NSLog(@"\nDatabase Copied to %@", _databasePath);
        }
    } else {
        NSLog(@"\nDatabase already exists at path: %@", _databasePath);
    }
}

- (void)deleteDatabase {
    NSLog(@"in DBAO deleteDatabase");

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:_databasePath]) {
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:_databasePath error:&error];
        
        if (success == NO) {
            NSLog(@"\nDatabase Delete Error: %@\n", error.localizedDescription);
        } else {
            NSLog(@"\nDatabase Deleted: %@", _databasePath);
        }
    } else {
        NSLog(@"Database not deleted because it was not found");
    }
}

- (void)saveAllCompaniesInSqlite {
    NSLog(@"in DBAO saveAllCompaniesInSqlite");
    
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
    NSLog(@"in DBAO restoreAllCompaniesFromSqlite");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    NSString *databasePath = self.databasePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];    // defaultManager = the shared (singleton) file manager object
    
    if (![fileManager fileExistsAtPath:databasePath]) {
        [self.dao.companies removeAllObjects];  // If database not found, force load of default test data
        return;
    }
    
    self.dao.companies = [[self retrieveAllActiveCompaniesFromSql] retain];
    
    // When all companies are flagged as deleted, copy back the initial data set
    
    if ([self.dao.companies count] < 1) {
        NSLog(@"No companies left - copying back initial data set");
        [self deleteDatabase];
        [self checkAndCreateDatabase];
    }
    
    // The companies array needs to be sorted by company.sortID:
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.dao.companies sortUsingDescriptors:sortDescriptors];
    [sortDescriptor release];
    
    NSLog(@"Companies after sorting:\n");
    for (Company *company in self.dao.companies) {
        NSLog(@"%@ : %ld", company.name, (long)company.sortID);
    }
    
    NSLog(@"Finishing restoreAllCompaniesFromSqlite\n");
}

- (NSMutableArray *)retrieveAllActiveCompaniesFromSql {
    NSLog(@"in DBAO retrieveAllActiveCompaniesFromSql");
    
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
                        NSLog(@"%@ : %ld", product.name, (long)product.sortID);
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
    NSLog(@"in DBAO retrieveAllActiveProductsFromSql");
    
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
    NSLog(@"in DBAO updateCompanyInSqlite: %@", company.name);
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *updateStmt = [NSString stringWithFormat:@"UPDATE COMPANIES SET CODELETED = '%d', COSORTID = '%ld' WHERE COMPANYNAME = \"%@\"",(company.deleted ? 1 : 0), (long)company.sortID, company.name];
        
        const char *sql_stmt = [updateStmt UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc != SQLITE_OK) {
            NSLog(@"\n\nUpdate Company Failed with return code: %d", execRc);
        } else {
            NSLog(@"Update Company: %@ Succeeded", company.name);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nUpdate Company Open Database Failed with return code: %d", openRc);
    }
}

- (void)updateProductInSqlite:(Product *)product {
    NSLog(@"in DBAO updateProductInSqlite: %@", product.name);
    
    int openRc = [self.sqlAO openDatabase];
    
    if (openRc == SQLITE_OK) {
        
        NSString *updateStmt = [NSString stringWithFormat:@"UPDATE PRODUCTS SET PRODDELETED = '%d', PRODSORTID = '%ld' WHERE PRODUCTNAME = \"%@\"", (product.deleted ? 1 : 0), (long)product.sortID, product.name];
        
        const char *sql_stmt = [updateStmt UTF8String];
        
        int execRc = [self.sqlAO sqlExecStmt:sql_stmt];
        
        if (execRc != SQLITE_OK) {
            NSLog(@"\n\nUpdate Product Failed with return code: %d", execRc);
        } else {
            NSLog(@"Update Product: %@ Succeeded", product.name);
        }
        
        [self.sqlAO closeDatabase];
        
    } else {
        NSLog(@"\n\nUpdate Product Open Database Failed with return code: %d", openRc);
    }
}

#pragma mark NSFileManager Delegate Methods

- (BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return NO;
}

@end
