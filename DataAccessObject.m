//
//  DataAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "DataAccessObject.h"
#import "UserDefaultsAccessObject.h"
#import "DataBaseAccessObject.h"
#import "Constants.h"


@implementation DataAccessObject

// Singleton class - there will only be one instance of the DataAccessObject and it will be shared by all view controllers

#pragma mark Singleton Methods (needed with or without ARC)

static DataAccessObject *sharedDAO = nil;  // create a single static variable for the sharedDAO object

+ (id)createSharedDataAccessObject{
    NSLog(@"in DAO createSharedDataAccessObject");
    @synchronized(self) {  // the @synchronized directive serves to lock out all other threads until the block between the {} is finished
        if (sharedDAO == nil) {
            sharedDAO = [[super allocWithZone:NULL] init];
        }
    }
    return sharedDAO;
}

- (id)init {
    NSLog(@"in DAO init");
    if (sharedDAO) {
        NSLog(@"sharedDAO already exists - no new allocation will occur");
        return sharedDAO;
    }
    self = [super init];
    if (self) {
        NSLog(@"allocating empty companies and products arrays");
        _companies = [[NSMutableArray alloc] initWithObjects:nil];
        _products = [[NSMutableArray alloc] initWithObjects:nil];
        _stockSymbols = [[NSMutableArray alloc] initWithObjects: nil];
        _stockPrices = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    // ************************************
    // * Set Source of Persistent Storage *
    // ************************************
    
//    loadInitialData = YES;
    loadInitialData = NO;
    
//     persistentStoreType = useNSUserDefaults;
    persistentStoreType = useSqlite;
    
    if (persistentStoreType == useNSUserDefaults) {
        _uDAO = [[UserDefaultsAccessObject alloc] init];
    }
    
    if (persistentStoreType == useSqlite) {
        _dBAO = [[DataBaseAccessObject alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    NSLog(@"in DAO dealloc");
    
    [_companies release];
    [_products release];
    
    [_stockSymbols release];
    [_stockPrices release];
    
    [_uDAO release];
    [_dBAO release];
    
    [super dealloc];
}

#pragma mark - Additional Singleton Methods (needed when ARC is in effect)

//+ (id)createSharedDataAccessObject {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedDAO = [[self alloc] init];
//    });
//    return sharedDAO;
//}

#pragma mark - Additional Singleton Methods (needed when ARC is NOT in effect)

+ (id)allocWithZone:(NSZone *)zone {
    NSLog(@"in DAO allocWithZone");
    return [[self createSharedDataAccessObject] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    NSLog(@"in DAO copyWithZone");
    return self;
}

- (id)retain {
    NSLog(@"in DAO retain");
    return self;
}

- (NSUInteger)retainCount {
    NSLog(@"in DAO retainCount");
    return NSUIntegerMax; //denotes an object that cannot be released (makes retainCount the max possible number)
}

- (oneway void)release {
    NSLog(@"in DAO release - SHOULD NEVER HAPPEN!!!");
    // never release
}

- (id)autorelease {
    NSLog(@"in DAO autorelease");
    return self;
}


#pragma mark - Methods for saving and retrieving Companies to/from Persistant Storage

- (void)saveAllCompanies {
    NSLog(@"\nin DAO saveCompanies");
    
    if (persistentStoreType == useNSUserDefaults) {
        [self.uDAO saveAllCompaniesInStandardUserDefaults];
    }
    
    if (persistentStoreType == useSqlite) {
        [self.dBAO saveAllCompaniesInSqlite];
    }
}

- (void)restoreAllCompanies {
    NSLog(@"\nin DAO restoreCompanies");
    
    if (loadInitialData) {
        [self createInitialCompaniesAndProducts];
        [self saveAllCompanies];
        loadInitialData = NO;
    }
    
    if (persistentStoreType == useNSUserDefaults) {
        [self.uDAO restoreAllSavedCompaniesFromStandardUserDefaults];
    }
    
    if (persistentStoreType == useSqlite) {
        [self.dBAO restoreAllCompaniesFromSqlite];
    }
}


#pragma mark - Company methods

- (NSInteger)getCompaniesCount {
    NSLog(@"in DAO getCompaniesCount");
    return [self.companies count];
}

- (Company *)getCompanyAtIndex:(NSInteger)index {
    NSLog(@"in DAO getCompanyAtIndex: %ld", (long) index);
    return [self.companies objectAtIndex:index];
}

- (void)removeCompanyAtIndex:(NSInteger)index {
    NSLog(@"in DAO removeCompanyAtIndex");
    
    [self.companies[index] removeAllProducts];      // Flag this company's entire |products| array as Deleted
    
    [self.companies[index] setDeleted:YES];         // Then, flag this company as Deleted
    
    [self saveAllCompanies];                        // Then, update the persistent store (to reflect the flag changes)
    
    [self restoreAllCompanies];                     // Finally, reload all remaining (i.e., non-Deleted) data from the persistent store
}

- (void)moveCompanyFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"\nin DAO moveCompanyFromIndex");
    
    //NSLog(@"\nMove %@ From Index: %ld, To Index: %ld", [[self.companies objectAtIndex:fromIndex] name] ,fromIndex, toIndex);
    
    NSMutableArray *saveSortIDs = [[NSMutableArray alloc] initWithObjects:nil];
    for (Company *company in self.companies) {
        [saveSortIDs addObject:[NSNumber numberWithInteger:company.sortID]];
    }
    
    NSLog(@"sortIDs before:");
    for (Company *company in self.companies) {
        NSLog(@"%@ : %ld", company.name, company.sortID);
    }

    Company *aCompany = [[self.companies objectAtIndex:fromIndex] retain];  // save the company that is being moved
    
    //NSLog(@"Remove %@ from index: %ld", [[self.companies objectAtIndex:fromIndex] name] ,fromIndex);
    [self.companies removeObjectAtIndex:fromIndex];  // delete the company from its old position in the |companies| array
    
    //NSLog(@"Insert %@ at index: %ld", aCompany.name ,toIndex);
    [self.companies insertObject:aCompany atIndex:toIndex];  // insert the company into its new position in the |companies| array

    [aCompany release];
    aCompany = nil;
    
    for (int i=0; i<[self.companies count]; i++) {
        NSInteger newSortID = [saveSortIDs[i] intValue];        // NSNumber object to NSInteger primitive
        [self.companies[i] setSortID:newSortID];
    }
    
    NSLog(@"sortIDs after:");
    for (Company *company in self.companies) {
        NSLog(@"%@ : %ld", company.name, company.sortID);
    }
    
    [self saveAllCompanies];
    
    [saveSortIDs release];
}

- (NSMutableArray *)getAllCompanyStockSymbols {
    NSLog(@"in DAO getAllCompanyStockSymbols");
    
    [self.stockSymbols removeAllObjects];
    
    for (Company *company in self.companies) {
        NSLog(@"symbol: %@", company.stockSymbol);
        
        [self.stockSymbols addObject:company.stockSymbol];
    }
    return self.stockSymbols;
}


#pragma mark - Product methods

- (NSInteger)getProductsCount {
    NSLog(@"in DAO getProductsCount");
    return [self.products count];
}

- (Product *)getProductAtIndex:(NSInteger)index {
    NSLog(@"in DAO getProductsAtIndex: %ld - %@", (long)index, [[self.products objectAtIndex:index] name]);
    return [self.products objectAtIndex:index];
}

- (void)removeProductAtIndex:(NSInteger)index {
    NSLog(@"in DAO removeProductAtIndex");
    
    [self.products[index] setDeleted:YES];      // First, flag this product as Deleted
    
    NSString *saveCompanyName = [self.products[index] companyName];

    [self saveAllCompanies];                    // Then, update the persistent store (to reflect the flag changes)
    
    [self restoreAllCompanies];                 // Then, reload all remaining (i.e., non-Deleted) data from the persistent store
    
    for (Company *company in self.companies) {                  // Finally, restore the updated self.products array
        if ([company.name isEqualToString:saveCompanyName]) {
            [self setProducts:company.products];
            break;
        }
    }
}

- (void)moveProductFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSLog(@"in DAO moveProductFromIndex");
    //NSLog(@"\nMove %@ From Index: %ld, To Index: %ld", [[self.products objectAtIndex:fromIndex] name] ,fromIndex, toIndex);
    
    NSMutableArray *saveSortIDs = [[NSMutableArray alloc] initWithObjects:nil];
    for (Product *product in self.products) {
        [saveSortIDs addObject:[NSNumber numberWithInteger:product.sortID]];
    }
    
    NSLog(@"sortIDs before:");
    for (Company *product in self.products) {
        NSLog(@"%@ : %ld", product.name, product.sortID);
    }
    
    Product *aProduct = [[self.products objectAtIndex:fromIndex] retain];  // save the product that is being moved
    
    //NSLog(@"Remove %@ from index: %ld", [[self.products objectAtIndex:fromIndex] name] ,fromIndex);
    [self.products removeObjectAtIndex:fromIndex];  // delete the product from its old position in the |products| array
    
    //NSLog(@"Insert %@ at index: %ld", aProduct.name ,toIndex);
    [self.products insertObject:aProduct atIndex:toIndex];  // insert the product into its new position in the |products| array
    
    [aProduct release];
    aProduct = nil;
    
    for (int i=0; i<[self.products count]; i++) {
        NSInteger newSortID = [saveSortIDs[i] intValue];        // NSNumber object to NSInteger primitive
        [self.products[i] setSortID:newSortID];
    }
    
    NSLog(@"sortIDs after:");
    for (Product *product in self.products) {
        NSLog(@"%@ : %ld", product.name, product.sortID);
    }
    
    [self saveAllCompanies];
    
    [saveSortIDs release];
}


#pragma mark - Defaults: create test set of Companies and Products

- (void)createInitialCompaniesAndProducts {
    NSLog(@"in DAO createInitialCompaniesAndProducts");
    
    [_companies release];
    _companies = nil;
    
    _companies = [[NSMutableArray alloc] init];
    
    Company *aCompany = [[Company alloc] initWithName:@"Apple" logo:@"AppleLogo.jpeg" stockSymbol:@"AAPL"];

    Product *a1Product = [[Product alloc] initWithName:@"iPad Air"
                                                  logo:[UIImage imageNamed:@"iPadAir.png"]
                                                   url:[NSURL URLWithString:@"https://www.apple.com/ipad-air-2/"]
                                               company:@"Apple"];
    Product *a2Product = [[Product alloc] initWithName:@"iPod Touch"
                                                  logo:[UIImage imageNamed:@"iPodTouch.jpeg"]
                                                   url:[NSURL URLWithString:@"https://www.apple.com/ipod-touch/"]
                                               company:@"Apple"];
    Product *a3Product = [[Product alloc] initWithName:@"iPhone 6"
                                                  logo:[UIImage imageNamed:@"iPhone6.jpeg"]
                                                   url:[NSURL URLWithString:@"https://www.apple.com/iphone-6/"]
                                               company:@"Apple"];
    [aCompany addProduct:a1Product];
    [aCompany addProduct:a2Product];
    [aCompany addProduct:a3Product];
    
    Company *bCompany = [[Company alloc] initWithName:@"Samsung" logo:@"SamsungLogo.jpeg" stockSymbol:@"SSNLF"];
    
    Product *b1Product = [[Product alloc] initWithName:@"Galaxy S4"
                                                  logo:[UIImage imageNamed:@"GalaxyS4.jpeg"]
                                                   url:[NSURL URLWithString:@"http://www.samsung.com/global/microsite/galaxys4/"]
                                               company:@"Samsung"];
    Product *b2Product = [[Product alloc] initWithName:@"Galaxy Note"
                                                  logo:[UIImage imageNamed:@"GalaxyNote.png"]
                                                   url:[NSURL URLWithString:@"http://www.samsung.com/global/microsite/galaxynote4/note4_main.html"]
                                               company:@"Samsung"];
    Product *b3Product = [[Product alloc] initWithName:@"Galaxy Tab"
                                                  logo:[UIImage imageNamed:@"GalaxyTab.jpeg"]
                                                   url:[NSURL URLWithString:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T230NZWAXAR"]
                                               company:@"Samsung"];
    [bCompany addProduct:b1Product];
    [bCompany addProduct:b2Product];
    [bCompany addProduct:b3Product];
    
    Company *cCompany = [[Company alloc] initWithName:@"Microsoft" logo:@"MicrosoftLogo.png" stockSymbol:@"MSFT"];
    
    Product *c1Product = [[Product alloc] initWithName:@"Windows Phone 8"
                                                  logo:[UIImage imageNamed:@"WindowsPhone.jpeg"]
                                                   url:[NSURL URLWithString:@"http://www.windowsphone.com/en-us"]
                                               company:@"Microsoft"];
    Product *c2Product = [[Product alloc] initWithName:@"Surface Pro 3 Tablet"
                                                  logo:[UIImage imageNamed:@"SurfacePro.png"]
                                                   url:[NSURL URLWithString:@"http://www.microsoft.com/surface/en-us/products/surface-pro-2"]
                                               company:@"Microsoft"];
    Product *c3Product = [[Product alloc] initWithName:@"Lumia 1520"
                                                  logo:[UIImage imageNamed:@"Lumia.png"]
                                                   url:[NSURL URLWithString:@"http://www.expansys-usa.com/nokia-lumia-1520-unlocked-32gb-yellow-rm-937-255929/"]
                                               company:@"Microsoft"];
    [cCompany addProduct:c1Product];
    [cCompany addProduct:c2Product];
    [cCompany addProduct:c3Product];
    
    Company *dCompany = [[Company alloc] initWithName:@"Everything" logo:@"EverythingLogo.png" stockSymbol:@"EVRY"];
    
    Product *d1Product = [[Product alloc] initWithName:@"The I Can't Believe It's An Everything Tablet"
                                                  logo:[UIImage imageNamed:@"EverythingTablet.png"]
                                                   url:[NSURL URLWithString:@"http://instagram.com/everythingtablet"]
                                               company:@"Everything"];
    Product *d2Product = [[Product alloc] initWithName:@"The Amazing Everything Phone"
                                                  logo:[UIImage imageNamed:@"EverythingPhone.jpg"]
                                                   url:[NSURL URLWithString:@"http://everything.me"]
                                               company:@"Everything"];
    Product *d3Product = [[Product alloc] initWithName:@"The Holds Everything 100TB Music Player"
                                                  logo:[UIImage imageNamed:@"EverythingMusicPlayer.png"]
                                                   url:[NSURL URLWithString:@"http://www.umplayer.com"]
                                               company:@"Everything"];
    [dCompany addProduct:d1Product];
    [dCompany addProduct:d2Product];
    [dCompany addProduct:d3Product];
    
    int i = 0;
    self.companies[i++] = aCompany;
    self.companies[i++] = bCompany;
    self.companies[i++] = cCompany;
    self.companies[i++] = dCompany;
    
    [aCompany release];
    [a1Product release];
    [a2Product release];
    [a3Product release];
    
    [bCompany release];
    [b1Product release];
    [b2Product release];
    [b3Product release];
    
    [cCompany release];
    [c1Product release];
    [c2Product release];
    [c3Product release];

    [dCompany release];
    [d1Product release];
    [d2Product release];
    [d3Product release];
    
    aCompany = nil;
    a1Product = nil;
    a2Product = nil;
    a3Product = nil;
    
    bCompany = nil;
    b1Product = nil;
    b2Product = nil;
    b3Product = nil;
    
    cCompany = nil;
    c1Product = nil;
    c2Product = nil;
    c3Product = nil;
    
    dCompany = nil;
    d1Product = nil;
    d2Product = nil;
    d3Product = nil;
    
//    NSLog(@"self.companies[0].products[0].company = %@", [[self.companies[0] products][0] company]);
//    NSLog(@"self.companies[0].products[0].name = %@", [[self.companies[0] products][0] name]);
//    NSLog(@"self.companies[0].products[0].logo = %@", [[[self.companies[0] products][0] logo] description]);
//    NSLog(@"self.companies[0].products[0].url = %@", [[[self.companies[0] products][0] url] description]);
    
    NSLog(@"Finishing createInitialCompaniesAndProducts\n");
}

@end
