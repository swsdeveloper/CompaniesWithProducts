//
//  Product.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "Product.h"


static int nextProductID = 0;


@implementation Product

//-(Product *)init {
//    NSLog(@"in Product init");
//    return [self initWithName:nil logo:nil url:nil];
//}

-(id)initWithName:(NSString *)prodName logo:(UIImage *)prodLogo url:(NSURL *)prodUrl company:(NSString *)prodCompany {
    NSLog(@"in Product initWithName");
    
    self = [super init];
    if (self) {
        _companyName = [prodCompany retain];
        _name = [prodName retain];
        _logo = [prodLogo retain];
        _url = [prodUrl retain];
        _deleted = NO;
        _sortID = nextProductID++;
    }
    return self;
}

-(void)dealloc {
    NSLog(@"in Product dealloc");
    [_companyName release];
    [_name release];
    [_logo release];
    [_url release];
    [super dealloc];
}


// ****************************************************
// * The next 2 methods are for use by NSUserDefaults *
// ****************************************************

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    NSLog(@"in Product encodeWithCoder");
    
    NSData* imageData = UIImagePNGRepresentation(self.logo);

    [encoder encodeObject:[self companyName] forKey:@"companyName"];
    [encoder encodeObject:[self name] forKey:@"name"];
    [encoder encodeObject:imageData forKey:@"logo"];
    [encoder encodeObject:[self url] forKey:@"url"];
    [encoder encodeBool:[self deleted] forKey:@"deleted"];
    [encoder encodeInteger:[self sortID] forKey:@"sortID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSLog(@"in Product initWithCoder");
    self = [super init];
    if(self) {
        //decode properties, other class vars
        _companyName = [[decoder decodeObjectForKey:@"companyName"] retain];
        _name = [[decoder decodeObjectForKey:@"name"] retain];

        NSData *encodedImageData = [decoder decodeObjectForKey:@"logo"];
        _logo = [[UIImage imageWithData:encodedImageData] retain];
        
        _url = [[decoder decodeObjectForKey:@"url"] retain];
        _deleted = [decoder decodeBoolForKey:@"deleted"];
        _sortID = [decoder decodeIntegerForKey:@"sortID"];
    }
    return self;
}

@end
