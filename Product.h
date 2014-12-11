//
//  Product.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Product : NSObject {
    
    NSInteger _nextSortId;
    
}


@property (retain, nonatomic) NSString *companyName;    // Company that Product belongs to

@property (retain, nonatomic) NSString *name;       // Product name

@property (retain, nonatomic) UIImage *logo;

@property (retain, nonatomic) NSURL *url;

@property (assign, nonatomic) BOOL deleted;     // If YES, this product has been marked as deleted

@property (assign, nonatomic) NSInteger sortID;


-(id)initWithName:(NSString *)prodName logo:(UIImage *)prodLogo url:(NSURL *)prodUrl company:(NSString *)prodCompany;

@end
