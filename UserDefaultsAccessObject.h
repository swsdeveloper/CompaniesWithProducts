//
//  UserDefaultsAccessObject.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/9/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DataAccessObject;


@interface UserDefaultsAccessObject : NSObject

@property (retain, nonatomic) DataAccessObject *dao;

- (void)saveAllCompaniesInStandardUserDefaults;

- (void)restoreAllSavedCompaniesFromStandardUserDefaults;

@end
