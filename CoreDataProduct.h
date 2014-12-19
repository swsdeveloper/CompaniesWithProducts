//
//  CoreDataProduct.h
//  BuildCoreDataStore
//
//  Created by Steven Shatz on 12/16/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataProduct : NSManagedObject

@property (nonatomic, retain) NSString *prod_name;
@property (nonatomic, retain) NSString *prod_co_name;
@property (nonatomic, retain) NSString *prod_logo;
@property (nonatomic, retain) NSString *prod_url;
@property (nonatomic, retain) NSNumber *prod_deleted;              // Note: In Core Data, a BOOL is really an NSNumber!!!
@property (nonatomic, retain) NSNumber *prod_sortid;

@end
