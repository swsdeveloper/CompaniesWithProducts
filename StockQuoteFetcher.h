//
//  StockQuoteFetcher.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/13/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import <Foundation/Foundation.h>
#import "qcdDemoViewController.h"


@class DataAccessObject;

@class qcdDemoViewController;


@interface StockQuoteFetcher : NSObject <NSURLConnectionDataDelegate>

@property (retain, nonatomic) DataAccessObject *dao;

@property (retain, nonatomic) qcdDemoViewController *demoVC;

@property (strong, nonatomic) NSMutableData *dataReceived;

@property (retain, nonatomic) NSMutableArray *quoteArray;

@property (retain, nonatomic) NSURLConnection *connection;


- (void)fetchQuotesAsynchronouslyForViewController:(qcdDemoViewController *)vc forStockSymbols:(NSArray *)tickers ;    // returns stockPrices dictionary to DAO object


// The following synchronous method should NOT be used
// + (NSDictionary *)fetchQuotesSynchronouslyFor:(NSArray *)tickers;

// Private Method:
// - (void)setQuoteArrayFromJsonDict:(NSDictionary *)jsonDict;

@end
