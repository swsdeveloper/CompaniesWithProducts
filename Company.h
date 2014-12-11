//
//  Company.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import <Foundation/Foundation.h>
#import "Product.h"


@interface Company : NSObject <NSCoding> {
    
    NSInteger _nextSortId;
    
}

@property (retain, nonatomic) NSString *name;

@property (retain, nonatomic) UIImage *logo;

@property (retain, nonatomic) NSMutableArray *products;

@property (retain, nonatomic) NSString *stockSymbol;

@property (assign, nonatomic) BOOL deleted;     // If YES, this company has been marked as deleted

@property (assign, nonatomic) NSInteger sortID;


-(id)initWithName:(NSString *)coName logo:(NSString *)coLogo stockSymbol:(NSString *)coStockSymbol;

-(void)addProduct:(Product *)newProduct;

//-(void)insertProduct:(Product *)newProduct atIndex:(int)i;
//-(void)removeProductAtIndex:(int)i;

-(void)removeAllProducts;

@end
