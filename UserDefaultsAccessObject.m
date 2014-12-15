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
    NSLog(@"in UDAO saveAllCompaniesInStandardUserDefaults");
    
    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    _dao = appDelegate.sharedDAO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  // get current user's standard defaults
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.dao.companies];  // Convert (archive) |self.dao.companies| object into NSData
    
    [defaults setObject:encodedObject forKey:@"SWS-NavCtrlWithObjects-Companies"]; // add our NSData object to the default file
    
    [defaults synchronize];  // save the new defaults
    
    NSLog(@"Finishing saveAllCompaniesInStandardUserDefaults\n");
}

- (void)restoreAllSavedCompaniesFromStandardUserDefaults {
    NSLog(@"in UDAO restoreAllCompaniesFromStandardUserDefaults");
    
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
    
    // If no companies were restored (i.e., all companies have been deleted), recreate the initial data set
    
    if ([self.dao.companies count] < 1) {
        NSLog(@"\n\nNo companies left in NSUserDefaults\n");

        _initialLoad = NO;
        
        // Uncomment the next statement to load initial data when using NSUserDefaults for the first time
//        _initialLoad = YES;
        
        if (_initialLoad == YES) {
            NSLog(@"\n\nReloading initial data set\n");
            [self createInitialCompaniesAndProducts];
            [self saveAllCompaniesInStandardUserDefaults];
            _initialLoad = NO;
        }
    }
    
    NSLog(@"Finishing restoreAllCompaniesFromStandardUserDefaults\n");
}


#pragma mark - Defaults: create test set of Companies and Products

- (void)createInitialCompaniesAndProducts {
    NSLog(@"in UDAO createInitialCompaniesAndProducts");
    
    [self.dao.companies release];
    self.dao.companies = nil;
    
    self.dao.companies = [[NSMutableArray alloc] init];
    
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
    self.dao.companies[i++] = aCompany;
    self.dao.companies[i++] = bCompany;
    self.dao.companies[i++] = cCompany;
    self.dao.companies[i++] = dCompany;
    
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
    
    //    NSLog(@"self.dao.companies[0].products[0].company = %@", [[self.dao.companies[0] products][0] company]);
    //    NSLog(@"self.dao.companies[0].products[0].name = %@", [[self.dao.companies[0] products][0] name]);
    //    NSLog(@"self.dao.companies[0].products[0].logo = %@", [[[self.dao.companies[0] products][0] logo] description]);
    //    NSLog(@"self.dao.companies[0].products[0].url = %@", [[[self.dao.companies[0] products][0] url] description]);
    
    NSLog(@"Finishing createInitialCompaniesAndProducts\n");
}

@end
