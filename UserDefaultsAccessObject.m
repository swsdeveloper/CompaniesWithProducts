//
//  UserDefaultsAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/9/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "UserDefaultsAccessObject.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "Constants.h"
#import "Company.h"
#import "Product.h"


@implementation UserDefaultsAccessObject

- (void)saveAllCompaniesInStandardUserDefaults {
    NSLog(@"in UserDefaultsAccessObject saveAllCompaniesInStandardUserDefaults");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  // get current user's standard defaults
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.dao.companies];  // Convert (archive) |self.dao.companies| object into NSData
    
    [defaults setObject:encodedObject forKey:@"SWS-NavCtrlWithObjects-Companies"]; // add our NSData object to the default file
    
    [defaults synchronize];  // save the new defaults
    
    NSLog(@"Finishing saveAllCompaniesInStandardUserDefaults\n");
}

- (void)restoreAllSavedCompaniesFromStandardUserDefaults {
    NSLog(@"in UserDefaultsAccessObject restoreAllCompaniesFromStandardUserDefaults");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  // get current user's standard defaults
    
    NSData *encodedObject = [defaults objectForKey:@"SWS-NavCtrlWithObjects-Companies"];  // retrieve the archived companies array object
    
    self.dao.companies = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];  // set |self.dao.companies| to the retrieved data
    
    // *****************************************************************
    // * Remove any companies and products that are flagged as Deleted *
    // *****************************************************************
    
    int numCompanies = (int)[self.dao.companies count];
    
    for (int cIndex = numCompanies-1; cIndex >= 0; cIndex--) {
        Company *company = self.dao.companies[cIndex];
        
        int numProducts = (int)[company.products count];
        
        for (int pIndex = numProducts-1; pIndex >= 0; pIndex--) {
            Product *product = company.products[pIndex];
            
            if (product.deleted) {
                [company.products removeObjectAtIndex:pIndex];
            }
        }
        
        if (company.deleted) {
            [self.dao.companies removeObjectAtIndex:cIndex];
        }
    }
    NSLog(@"Finishing restoreAllCompaniesFromStandardUserDefaults\n");
}

@end
