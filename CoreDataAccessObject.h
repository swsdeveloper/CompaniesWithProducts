//
//  CoreDataAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/15/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class DataAccessObject;


@interface CoreDataAccessObject : NSObject <NSFileManagerDelegate>

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) NSString *databaseName;

@property (retain, nonatomic) NSString *databasePath;

@property(retain, nonatomic) NSManagedObjectContext *context;

@property(retain, nonatomic) NSManagedObjectModel *model;

@property(retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (id)init;

- (void)saveAllCompaniesInCoreData;

- (void)restoreAllCompaniesFromCoreData;    // updates self.dao.companies

@end
