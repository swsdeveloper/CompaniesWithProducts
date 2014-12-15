//
//  CoreDataAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/15/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "CoreDataAccessObject.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "Constants.h"


@implementation CoreDataAccessObject

- (void)dealloc {
    [_databasePath release];
//    [_sqlAO release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        
        _databaseName = @"CompaniesProductsDatabase";
        
        NSLog(@"in CDAO init - database: %@", _databaseName);
        
        NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        // returns array of current user's |documents| directories (but there's probably only one)
        
        NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];  // point to current user's |documents| directory (in iOS sandbox)
        
        _databasePath = [documentsDirectory stringByAppendingPathComponent:_databaseName];   // full path to our SQL database
        
//        [self checkAndCreateDatabase];
//        
//        _sqlAO = [[SQLiteAccessObject alloc] initWithDatabase:_databasePath];
    }
    return self;
}


- (void)checkAndCreateDatabase {
    NSLog(@"in CDAO checkAndCreateDatabase");
    
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
    NSLog(@"in CDAO deleteDatabase");
    
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

- (void)saveAllCompaniesInCoreData {
    
}

- (void)restoreAllCompaniesFromCoreData {
    
}

- (NSMutableArray *)retrieveAllActiveCompaniesFromCoreData {
    NSMutableArray *temp = [[NSMutableArray alloc] initWithObjects:nil];
    return temp;
}

- (void)updateCompanyInCoreData:(Company *)company {
    
}

- (void)updateProductInCoreData:(Product *)product {
    
}

#pragma mark NSFileManager Delegate Methods

- (BOOL)fileManager:(NSFileManager *)fileManager shouldCopyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    return NO;
}

@end
