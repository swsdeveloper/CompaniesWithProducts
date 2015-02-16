//
//  CoreDataAccessObject.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 12/15/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "CoreDataAccessObject.h"
#import "qcdDemoAppDelegate.h"
#import "DataAccessObject.h"
#import "Constants.h"
#import "CoreDataCompany.h"
#import "CoreDataProduct.h"
#import "Company.h"
#import "Product.h"


@implementation CoreDataAccessObject

- (void)dealloc {
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"in CDAO init");
        
        _databaseName = @"CompaniesProducts.data";
        
        _databasePath = [self archivePath];             // returns path to our CoreData database (see below)
        
        [self openAndOrCreateDatabase];                 // open database (or create it (with initial data) if it doesn't already exist)
    }
    return self;
}

- (void)saveAllCompaniesInCoreData {
    NSLog(@"in CDAO saveAllCompaniesInCoreData");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    for (Company *company in self.dao.companies) {
        
        // Update the Company entity (in the Core Data Context)
        
        NSLog(@"Save: Company Object ID: %@", company.coreDataID);
        
        CoreDataCompany *coreDataCompany = (CoreDataCompany *)[self.context objectWithID:company.coreDataID];
        
        coreDataCompany.co_name = company.name;
        coreDataCompany.co_logo = company.logoFileName;
        coreDataCompany.co_stocksymbol = company.stockSymbol;
        coreDataCompany.co_deleted = [NSNumber numberWithBool:company.deleted];
        coreDataCompany.co_sortid = [NSNumber numberWithInteger:company.sortID];
        
        // Update the Product entity for each of the Company's Products
        
        for (Product *product in company.products) {
            
            CoreDataProduct *coreDataProduct = (CoreDataProduct *)[self.context objectWithID:product.coreDataID];

            coreDataProduct.prod_name = product.name;
            coreDataProduct.prod_co_name = product.companyName;
            coreDataProduct.prod_logo = product.logoFileName;
            coreDataProduct.prod_url = [product.url absoluteString];
            
            NSLog(@"coreDataProduct.prod_url: %@", coreDataProduct.prod_url);
            
            coreDataProduct.prod_deleted = [NSNumber numberWithBool:product.deleted];
            coreDataProduct.prod_sortid = [NSNumber numberWithInteger:product.sortID];
        }

    }
    NSLog(@"Finishing saveAllCompaniesInCoreData\n");
    
    [self saveData];
}

- (void)restoreAllCompaniesFromCoreData {
    NSLog(@"in CDAO restoreAllCompaniesFromCoreData");
    
    [self reloadCompanyData];
    
    // When all companies are flagged as deleted, reload the initial data set
    
    if ([self.dao.companies count] < 1) {
        
        NSLog(@"No companies left - copying back initial data set");
        
        [self deleteDatabase];
        
        [self openAndOrCreateDatabase];
    }
}


// Open the database if it has already been saved to the users device, otherwise create it
- (void)openAndOrCreateDatabase {
    NSLog(@"in CDAO openAndOrCreateDatabase");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:_databasePath]) {
        NSLog(@"\nDatabase not found at path: %@ - Creating it ...", _databasePath);
        
        [self initModelContext];

        [self loadInitialData];
        
    } else {
        NSLog(@"\nDatabase already exists at path: %@", _databasePath);
        
        [self initModelContext];
    }
}

- (void)deleteDatabase {
    NSLog(@"in CDAO deleteDatabase");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:_databasePath]) {
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:_databasePath error:&error];
        
        if (success == NO) {
            NSLog(@"\nDatabase Delete Error: %@\n", error.localizedDescription);
        } else {
            NSLog(@"\nDatabase Deleted: %@", _databasePath);
        }
    } else {
        NSLog(@"Database not deleted because it was not found");
    }
}

#pragma mark --- Core Data setup

// self.model = Managed Object Model
// psc = Persistent Store Coordinator
// path = String showing path and name to SQL database (used by Core Data)
// storeURL = URL version of path
// self.context = Managed Object Model Context

- (void)initModelContext {
    NSLog(@"in CDAO initModelContext");
    
    [self setModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    // looks up all models in the specified bundles and merges them; if nil is specified as argument, uses the main bundle
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    
    NSLog(@"Data Store is located at:\n%@\n", [self.databasePath description]);
    
    NSURL *storeURL = [NSURL fileURLWithPath:self.databasePath]; // convert path to a URL
    
    NSError *error = nil;
    
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        [NSException raise:@"Open failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    [self setContext:[[NSManagedObjectContext alloc] init]];
    
    self.context.undoManager = nil;
    
    [[self context] setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (NSString *)archivePath {
    
    NSArray *documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // returns array of current user's |documents| directories (but there's probably only one)
    
    NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];  // point to current user's |documents| directory
    
    return [documentsDirectory stringByAppendingPathComponent:_databaseName];   // full path to our CoreData database}

    NSLog(@"");
    
}

#pragma mark Core Data Access methods

- (void)reloadCompanyData {
    
    [self reloadProductData];   // Build |self.dao.products| array
    
    NSLog(@"\nAbout to fetch all companies ...");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"co_deleted == 0 AND co_name MATCHES '.*'"];     // This is a Regular Expression
    
    [request setPredicate:predicate];

    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"co_sortid" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortById]];
    
    NSEntityDescription *company = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.context];
    
    [request setEntity:company];
    
    NSError *error = nil;
    
    NSArray *fetchResults = [[self context] executeFetchRequest:request error:&error];
    
        //Debugging:
        //    for (int i = 0; i < [fetchResults count]; i++) {
        //       CoreDataCompany * compthingy = fetchResults[i];
        //       NSLog(@"%@", compthingy.co_name);
        //    }
    
    if (fetchResults) {
        NSLog(@"... All companies have been fetched into the context\n");
    } else {
        [NSException raise:@"... Fetch Failed" format:@"Reason: %@\n", [error localizedDescription]];
    }
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    if (self.dao.companies) {
        [self.dao.companies removeAllObjects];
        self.dao.companies = nil;
    }
    
    self.dao.companies = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (CoreDataCompany *coreDataCompany in fetchResults) {
        
        Company *company = [[Company alloc] init];
        
//        Company *company = [[Company alloc] initWithName:coreDataCompany.co_name logo:coreDataCompany.co_logo stockSymbol:coreDataCompany.co_stocksymbol];
        
        company.name = coreDataCompany.co_name;
        
        company.logo = [UIImage imageNamed:coreDataCompany.co_logo];
        company.logoFileName = coreDataCompany.co_logo;
        
        company.products = [[NSMutableArray alloc] initWithCapacity:3];
        
        for (Product *product in self.dao.products) {
            if ([product.companyName isEqualToString:company.name]) {
                [company.products addObject:product];
            }
        }
        
        company.stockSymbol = coreDataCompany.co_stocksymbol;
        company.deleted = [coreDataCompany.co_deleted boolValue];     // In Core Data, BOOL is really an NSNumber
        company.sortID = [coreDataCompany.co_sortid integerValue];
        company.coreDataID = [coreDataCompany objectID];
        
        NSLog(@"Company Object ID: %@", company.coreDataID);
        
        [self.dao.companies addObject:company];
        
        [company release];
        company = nil;
    }
    
    NSLog(@"\nFetched %ld companies into the context\n", (unsigned long)[self.dao.companies count]);
    
    [request release];
    [sortById release];
    
    request = nil;
    sortById = nil;
}

- (void)reloadProductData {
    
    NSLog(@"\nAbout to fetch all products ...");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"prod_deleted == 0 AND prod_name MATCHES '.*'"];     // This is a Regular Expression
    
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortById = [[NSSortDescriptor alloc] initWithKey:@"prod_sortid" ascending:YES];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortById]];
    
    NSEntityDescription *product = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.context];
    
    [request setEntity:product];
    
    NSError *error = nil;
    
    NSArray *fetchResults = [[self context] executeFetchRequest:request error:&error];
    
    if (fetchResults) {
        NSLog(@"... All products have been fetched into the context\n");
    } else {
        [NSException raise:@"... Fetch Failed" format:@"Reason: %@\n", [error localizedDescription]];
    }
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    if (self.dao.products) {
        [self.dao.products removeAllObjects];
        self.dao.products = nil;
    }
    
    self.dao.products = [[NSMutableArray alloc] initWithCapacity:12];
    
    for (CoreDataProduct *coreDataProduct in fetchResults) {
        Product *product = [[Product alloc] init];
        
        product.name = coreDataProduct.prod_name;
        product.companyName = coreDataProduct.prod_co_name;
        product.logo = [UIImage imageNamed:coreDataProduct.prod_logo];
        product.logoFileName = coreDataProduct.prod_logo;
        product.url = [NSURL URLWithString:coreDataProduct.prod_url];
        product.deleted = [coreDataProduct.prod_deleted boolValue];     // In Core Data, BOOL is really an NSNumber
        product.sortID = [coreDataProduct.prod_sortid integerValue];
        product.coreDataID = [coreDataProduct objectID];
        
        NSLog(@"Product Object ID: %@", product.coreDataID);

        [self.dao.products addObject:product];
        
        [product release];
        product = nil;
    }
    
    NSLog(@"\nFetched %ld products into the context\n", (unsigned long)[self.dao.products count]);
    
    [request release];
    [sortById release];
    
    request = nil;
    sortById = nil;
}

// *********************
// * Load Initial Data *
// *********************

#pragma mark --- Core Data Actions

- (void)loadInitialData {
    NSLog(@"in CDAO loadInitialData");
    
    // Companies
    
    [self createCompanyWithName:@"Apple" logo:@"AppleLogo.jpeg" stockSymbol:@"AAPL" sortID:0];
    [self createCompanyWithName:@"Samsung" logo:@"SamsungLogo.jpeg" stockSymbol:@"005930.KS" sortID:1]; // instead of SSNLF
    [self createCompanyWithName:@"Microsoft" logo:@"MicrosoftLogo.png" stockSymbol:@"MSFT" sortID:2];
    [self createCompanyWithName:@"Everything" logo:@"EverythingLogo.png" stockSymbol:@"EVRY" sortID:3];
    
    // Products
    
    [self createProductWithName:@"iPad Air" forCompany:@"Apple" logo:@"iPadAir.png" url:@"https://www.apple.com/ipad-air-2/" sortID:0];
    [self createProductWithName:@"iPod Touch" forCompany:@"Apple" logo:@"iPodTouch.jpeg" url:@"https://www.apple.com/ipod-touch/" sortID:1];
    [self createProductWithName:@"iPhone 6" forCompany:@"Apple" logo:@"iPhone6.jpeg" url:@"https://www.apple.com/iphone-6/" sortID:2];
    
    [self createProductWithName:@"Galaxy S4" forCompany:@"Samsung" logo:@"GalaxyS4.jpeg" url:@"http://www.samsung.com/global/microsite/galaxys4/" sortID:3];
    [self createProductWithName:@"Galaxy Note" forCompany:@"Samsung" logo:@"GalaxyNote.png" url:@"http://www.samsung.com/global/microsite/galaxynote4/note4_main.html" sortID:4];
    [self createProductWithName:@"Galaxy Tab" forCompany:@"Samsung" logo:@"GalaxyTab.jpeg" url:@"http://www.samsung.com/us/mobile/galaxy-tab/SM-T230NZWAXAR" sortID:5];
    
    [self createProductWithName:@"Windows Phone 8" forCompany:@"Microsoft" logo:@"WindowsPhone.jpeg" url:@"http://www.windowsphone.com/en-us" sortID:6];
    [self createProductWithName:@"Surface Pro 3 Tablet" forCompany:@"Microsoft" logo:@"SurfacePro.png" url:@"http://www.microsoft.com/surface/en-us/products/surface-pro-2" sortID:7];
    [self createProductWithName:@"Lumia 1520" forCompany:@"Microsoft" logo:@"Lumia.png" url:@"http://www.expansys-usa.com/nokia-lumia-1520-unlocked-32gb-yellow-rm-937-255929/" sortID:8];
    
    [self createProductWithName:@"The I Can't Believe It's An Everything Tablet" forCompany:@"Everything" logo:@"EverythingTablet.png" url:@"http://instagram.com/everythingtablet" sortID:9];
    [self createProductWithName:@"TThe Amazing Everything Phone" forCompany:@"Everything" logo:@"EverythingPhone.jpg" url:@"http://everything.me" sortID:10];
    [self createProductWithName:@"The Holds Everything 100TB Music Player" forCompany:@"Everything" logo:@"EverythingMusicPlayer.png" url:@"http://www.umplayer.com" sortID:11];
}

// **************************************
// * Create Company and Product Objects *
// **************************************

#pragma mark --- Data operations

- (void)createCompanyWithName:(NSString *)coName logo:(NSString *)coLogo stockSymbol:(NSString *)coStockSymbol sortID:(int)coSortID {
    
    CoreDataCompany *coreDataCompany = [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:[self context]];
    
    [coreDataCompany setCo_name:coName];
    [coreDataCompany setCo_logo:coLogo];
    [coreDataCompany setCo_stocksymbol:coStockSymbol];
    [coreDataCompany setCo_deleted:[NSNumber numberWithBool:NO]];        // In Core Data, BOOL is really an NSNumber!!!
    [coreDataCompany setCo_sortid:[NSNumber numberWithInt:coSortID]];

    // For testing predicate, set Samsung to be logically deleted
    //    if ([coName isEqualToString:@"Samsung"]) {
    //        [coreDataCompany setCo_deleted:[NSNumber numberWithBool:YES]];      // In Core Data, BOOL is really an NSNumber!!!
    //    }
    
    NSLog(@"\nAbout to save Company name: %@, logo: %@, stock symbol: %@, deleted: %@, sortID: %d ...", coName, coLogo, coStockSymbol, [coreDataCompany co_deleted] ? @"YES" : @"NO", coSortID);
    
    [self saveData];
}

- (void)createProductWithName:(NSString *)prodName forCompany:(NSString *)prodCompanyName logo:(NSString *)prodLogo url:(NSString *)prodURL sortID:(int)prodSortID {
    
    CoreDataProduct *coreDataProduct = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:[self context]];
    
    [coreDataProduct setProd_name:prodName];
    [coreDataProduct setProd_co_name:prodCompanyName];
    [coreDataProduct setProd_logo:prodLogo];
    [coreDataProduct setProd_url:prodURL];
    [coreDataProduct setProd_deleted:[NSNumber numberWithBool:NO]];        // In Core Data, BOOL is really an NSNumber!!!
    [coreDataProduct setProd_sortid:[NSNumber numberWithInt:prodSortID]];
    
    NSLog(@"\nAbout to save Product name: %@, for company: %@, logo: %@, url: %@, deleted: %@, sortID: %d ...", prodName, prodCompanyName, prodLogo, prodURL, [coreDataProduct prod_deleted] ? @"YES" : @"NO", prodSortID);
    
    [self saveData];
}

- (void)saveData {
    NSError *err = nil;
    
    BOOL successful = [[self context] save:&err];
    
    if (successful) {
        NSLog(@"... Data Saved\n");
    } else {
        NSLog(@"... Error saving data to Persistent Store: %@\n", [err localizedDescription]);
    }
}

@end
