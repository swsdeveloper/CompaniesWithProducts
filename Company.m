//
//  Company.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "Company.h"


@implementation Company

//-(Company *)init {
//    NSLog(@"in Company init");
//    return [self initWithName:nil logo:nil stockSymbol:nil];
//}

-(id)initWithName:(NSString *)coName logo:(NSString *)coLogo stockSymbol:(NSString *)coStockSymbol {
    
    self = [super init];
    if (self) {
        _name = [[NSString alloc] initWithString:coName];
        _logo = [[UIImage imageNamed:coLogo] retain];
        _products = [[NSMutableArray alloc] initWithCapacity:5];
        _stockSymbol = [[NSString alloc] initWithString:coStockSymbol];
        _deleted = NO;
        _sortID = _nextSortId++;
    }
    
    //NSLog(@"_name = %@", _name);
    return self;
}

-(void)dealloc {
    NSLog(@"in Company dealloc");
    [_name release];
    [_logo release];
    [_products release];
    [_stockSymbol release];
    [super dealloc];
}

- (void)addProduct:(Product *)newProduct {
    NSLog(@"in Company addProduct");
    if (newProduct) {
        [self.products addObject:newProduct];
    }
}

//- (void)insertProduct:(Product *)newProduct atIndex:(int)i {
//    NSLog(@"in Company insertProduct");
//    if (newProduct && i >= 0 && i <= (int)[self.products count]) {
//        [self.products insertObject:newProduct atIndex:i];
//    }
//}
//
//- (void)removeProductAtIndex:(int)i {
//    NSLog(@"in Company removeProductAtIndex");
//    if (i >= 0 && i < (int)[self.products count]) {
//        [self.products removeObjectAtIndex:i];
//    }
//}

- (void)removeAllProducts {
    // Flags all of a company's products as Deleted in self.products
    
    NSLog(@"in Company removeAllProducts");
    
    NSUInteger numProducts = [self.products count];
    
    for (NSUInteger index = 0; index < numProducts; ++index) {
        [self.products[index] setDeleted:YES];
    }
}


// ****************************************************
// * The next 2 methods are for use by NSUserDefaults *
// ****************************************************

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    NSLog(@"in Company encodeWithCoder");
    
    NSData* imageData = UIImagePNGRepresentation(self.logo);
    
    [encoder encodeObject:[self name] forKey:@"name"];
    [encoder encodeObject:imageData forKey:@"logo"];
    [encoder encodeObject:[self products] forKey:@"products"];
    [encoder encodeObject:[self stockSymbol] forKey:@"stockSymbol"];
    [encoder encodeBool:[self deleted] forKey:@"deleted"];
    [encoder encodeInteger:[self sortID] forKey:@"sortID"];
    
//    // Debugging: Save the logo UIImage as a file - logoIn.jpg
//    if ([self.name isEqualToString:@"Apple"]) {
//        NSString *filePath = @"/Users/stevenshatz/logoIn.jpg";
//
//        NSFileManager *fileManager = [NSFileManager defaultManager];    // defaultManager = the shared (singleton) file manager object
//    
//        if ([fileManager fileExistsAtPath:filePath]) {
//            [fileManager removeItemAtPath:filePath error:nil];
//        }
//        
//        NSData *binaryImageData = UIImagePNGRepresentation(self.logo);
//        
//        [fileManager createFileAtPath:filePath contents:binaryImageData attributes:nil];
//    }
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSLog(@"in Company initWithCoder");
    self = [super init];
    if(self) {
        //decode properties, other class vars
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        
        NSData *encodedImageData = [decoder decodeObjectForKey:@"logo"];
        _logo = [[UIImage imageWithData:encodedImageData] retain];

        _products = [[decoder decodeObjectForKey:@"products"] retain];
        _stockSymbol = [[decoder decodeObjectForKey:@"stockSymbol"] retain];
        _deleted = [decoder decodeBoolForKey:@"deleted"];
        _sortID = [decoder decodeIntegerForKey:@"sortID"];
        
//        // Debugging: Save the logo UIImage as a file - logoOut.jpg
//        if ([_name isEqualToString:@"Apple"]) {
//            NSString *filePath = @"/Users/stevenshatz/logoOut.jpg";
//            
//            NSFileManager *fileManager = [NSFileManager defaultManager];    // defaultManager = the shared (singleton) file manager object
//            
//            if ([fileManager fileExistsAtPath:filePath]) {
//                [fileManager removeItemAtPath:filePath error:nil];
//            }
//            
//            NSData *binaryImageData = UIImagePNGRepresentation(_logo);
//            
//            [fileManager createFileAtPath:filePath contents:binaryImageData attributes:nil];
//        }
        
    }
    return self;
}

@end
