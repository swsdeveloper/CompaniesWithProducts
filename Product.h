//
//  Product.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@class NSManagedObjectID;


@interface Product : NSObject


@property (retain, nonatomic) NSString *companyName;    // Company that Product belongs to

@property (retain, nonatomic) NSString *name;           // Product name

@property (retain, nonatomic) UIImage *logo;

@property (retain, nonatomic) NSString *logoFileName;   // For Core Data only (because image file name cannot be gotten from a UIImage)

@property (retain, nonatomic) NSURL *url;

@property (assign, nonatomic) BOOL deleted;             // If YES, this product has been marked as deleted

@property (assign, nonatomic) NSInteger sortID;

@property (retain, nonatomic) NSManagedObjectID *coreDataID;    // For Core Data only


-(id)initWithName:(NSString *)prodName logo:(NSString *)prodLogo url:(NSURL *)prodUrl company:(NSString *)prodCompany;

@end
