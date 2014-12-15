//
//  StockQuoteFetcher.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/13/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//
//  Yahoo stock quote API

// If this pgm used ARC, I would have been based this code on Justin Driscoll's blog:
//  http://themainthread.com/blog/2012/09/communicating-with-blocks-in-objective-c.html
//  http://themainthread.com/blog/2011/11/jcdhttpconnection.html
// But this is a non-ARC pgm, so I could not use his ideas!

// If I wanted CSV output instead of JSON, I would have done a query like this:
// http://download.finance.yahoo.com/d/quotes.csv?s=GOOG&f=l1


#import "StockQuoteFetcher.h"
#import "qcdDemoAppDelegate.h"
#import "Constants.h"
#import "DataAccessObject.h"
#import "NSObject+BVJSONStringCategory.h"
#import "NSString+FindSubstringCategory.h"


#define QUOTE_QUERY_PREFIX @"http://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20BidRealtime%20from%20yahoo.finance.quotes%20where%20symbol%20in%20("
#define QUOTE_QUERY_SUFFIX @")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="

// Sample Query:
// http://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20BidRealtime%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22AAPL%22%2C%22SSNLF%22%2C%22MSFT%22%2C%22EVRY%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=


@interface StockQuoteFetcher ()

@end

@implementation StockQuoteFetcher

- (id)init {
    self = [super init];

    NSLog(@"in StockQuoteFetcher init %@", self.description);
    
    if (self) {
        _quoteArray = [[NSMutableArray alloc] initWithObjects: nil];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"in StockQuoteFetcher dealloc");
    [_dataReceived release];
    [_quoteArray release];
    [_connection release];
    [super dealloc];
}

- (void)fetchQuotesAsynchronouslyForViewController:(qcdDemoViewController *)vc forStockSymbols:(NSArray *)tickers {

    NSLog(@"\nin StockQuoteFetcher fetchQuotesAsynchronously");
    
    if (tickers && [tickers count] > 0) {
        
        self.demoVC = vc;  // set for use by connectionDidFinishLoading  (this invokes setDemoVC, which retains the |vc| object)
        
        
        // Create a Yahoo Finance query for all ticker symbols in |tickers|
        
        NSMutableString *query = [[NSMutableString alloc] initWithString:QUOTE_QUERY_PREFIX];
        
        for (NSUInteger i = 0; i < [tickers count]; i++) {
            
            NSString *ticker = [[tickers objectAtIndex:i] retain];
            
            [query appendFormat:@"%%22%@%%22", ticker];
            
            if (i != [tickers count] - 1) {
                [query appendString:@"%2C"];  // append + after all tickers, except the last
            }
        }
        [query appendString:QUOTE_QUERY_SUFFIX];
        
        NSLog(@"\nQuery: %@\n", query);
        
        
        // Convert the Query to a URL Request
        
        if (query) {
            
            NSURL *url = [NSURL URLWithString:query];
            
            if (url) {
                NSLog(@"Url: %@\n", [url description]);
                
                NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                // timeout after 1 minute
                
                NSLog(@"Request: %@\n", [request description]);
                
                // create the connection with the request
                // and start loading the data immediately
                
                if (self.connection == nil) {
                    self.dataReceived = nil;
                    NSURLConnection *c = [[NSURLConnection alloc] initWithRequest:request delegate:self]; // this starts executing immediately
                    self.connection = c;
                    [c release];
                    c = nil;
                                                                                                       //[self.connection start];
                } // If the url request fails or completes successfully, the calling view controller's |reloadTableView| method will be invoked
            }
        }
        [query release];
        query = nil;
    }
}

#pragma mark - NSURLConnection Delegate methods

// ******************************************************
// * NSURLConnectionDelegate Methods - all are optional *
// ******************************************************

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse object.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    
    if (MYDEBUG) { NSLog(@"\nin StockQuoteFetcher connection:didReceiveResponse:\n%@", response); }
    
    [self.dataReceived setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"\n*** in StockQuoteFetcher connection:didFailWithError: ***");
    
    self.dataReceived = nil;
    self.connection = nil;
    
    NSLog(@"\nConnection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [self.demoVC reloadTableView];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (MYDEBUG) {
        NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"\nin StockQuoteFetcher connection:didReceiveData:\n%@", aString);
        [aString release];
        aString = nil;
    }
    
    if (self.dataReceived) {
        [self.dataReceived appendData:data];
    } else {
        NSMutableData *d = [[NSMutableData alloc] initWithData:data];
        self.dataReceived = d;
        [d release];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    if (MYDEBUG) {
        NSString *dataAsString = [[NSString alloc] initWithData:self.dataReceived encoding:NSUTF8StringEncoding];
        NSLog(@"\nin StockQuoteFetcher ConnectionDidFinishLoading:\n%@\n", dataAsString);
        [dataAsString release];
        dataAsString = nil;
    }
    
    NSLog(@"Succeeded! Received %ld bytes of data",(unsigned long)[self.dataReceived length]);
    
    NSDictionary *dict = [self jsonToDictionary:self.dataReceived];
    
    if (!dict) {
        NSLog(@"\n*** Could not convert JSON data to Dictionary ***");
        self.dataReceived = nil;
        self.connection = nil;
        return;
    }
    
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        NSLog(@"*** Cannot interpret result - Not a valid JSON Object ***");
        self.dataReceived = nil;
        self.connection = nil;
        return;
    }

    [self setQuoteArrayFromJsonDict:dict];  // sets (or resets) self.quoteArray to a list of {stock symbol:current stock price} dictionary entries
    
    if ([self.quoteArray count] < 1) {
        NSLog(@"\nStock prices array is empty");
        self.dataReceived = nil;
        self.connection = nil;
        return;
    }
    
    NSMutableDictionary *stockPriceDict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *dictionary in self.quoteArray) {
        
        NSString *symbol = [dictionary valueForKey:@"symbol"];
        
        NSString *stockPrice = [dictionary valueForKey:@"BidRealtime"];
        
        [stockPriceDict setObject:stockPrice forKey:symbol];
    }

    qcdDemoAppDelegate *appDelegate = (qcdDemoAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.dao = appDelegate.sharedDAO;

    [self.dao.stockPrices removeAllObjects];
    [self.dao.stockPrices addEntriesFromDictionary:stockPriceDict];
    
    NSLog(@"self.dao.stockPrices: %@", [self.dao.stockPrices description]);
    
    [stockPriceDict release];
    stockPriceDict = nil;
    
    self.dataReceived = nil;
    self.connection = nil;
    
    [self.demoVC reloadTableView];
}

- (void)setQuoteArrayFromJsonDict:(NSDictionary *)jsonDict {
    
    NSLog(@"in StockQuoteFetcher setQuoteArrayFromJsonDict");
    
    // Sample Output:
    // {
    //  "query":{
    //           "count":4,"created":"2014-11-17T15:25:49Z",
    //           "lang":"en-us",
    //           "results":{
    //                      "quote":[
    //                               { "symbol":"AAPL",  "BidRealtime":"114.48" },
    //                               { "symbol":"SSNLF", "BidRealtime":"0.00"   },
    //                               { "symbol":"MSFT",  "BidRealtime":"49.19"  },
    //                               { "symbol":"EVRY",  "BidRealtime":"1.39"   }
    //                              ]
    //
    //               or     "quote":{ "symbol":"AAPL",  "BidRealtime":"114.48" },
    //
    //                     }
    //          }
    // }
    
    // find key:"query" in JSONDict dictionary
    // find key:"results" in query dictionary
    // find key:"quote" in results dictionary - returns an array if there is more than 1 item; otherwise returns a dictionary
    //                                        - if quote returns a dictionary, load it into a 1 item array; otherwise, just use a copy of the returned array
    // for each symbol in our quote array:
    //    find key:"symbol"
    //    find key:"BidRealtime"]  (i.e., the current stock price)

    id resultObject1 = nil;  // These are effectively just pointers
    id resultObject2 = nil;
    id resultObject3 = nil;

    // Top JSON level
    
    resultObject1 = [jsonDict valueForKey:@"query"];
    
    if (![resultObject1 isKindOfClass:[NSDictionary class]]) {
        NSLog(@"*** ValueForKey:@\"query\" is not a Dictionary - give up ***");  // This will happen if resultObject1 is nil or an unexpected type
        return;
    }
    
    // 2nd JSON level
    
    resultObject2 = [resultObject1 valueForKey:@"results"];
    
    if (![resultObject2 isKindOfClass:[NSDictionary class]]) {
        NSLog(@"*** ValueForKey:@\"results\" is not a Dictionary - give up ***");  // This will happen if resultObject2 is nil or an unexpected type
        return;
    }
    
    // 3rd JSON level
    
    resultObject3 = [resultObject2 valueForKey:@"quote"];
    
    [self.quoteArray removeAllObjects];
    
    if ([resultObject3 isKindOfClass:[NSArray class]]) {
        NSLog(@"valueForKey:@\"quote\" is an Array");
        
        [self.quoteArray addObjectsFromArray:resultObject3];  // should be an Array of Dictionaries (created from an object of that same type)
        
    } else if ([resultObject3 isKindOfClass:[NSDictionary class]]) {
        NSLog(@"valueForKey:@\"quote\" is a Dictionary");
        
        [self.quoteArray addObject:resultObject3];            // should be an Array of Dictionaries (created from a dictionary)
        
    } else {
        return;
    }

    // 4th JSON level -- this level assumes that quoteArray contains 1 or more NSDictionary objects
    // self.quoteArray has been set (though it may be empty)

    return;
 }

// ********************************************************************************************************************************************************

#pragma mark - the following Synchronous method was tested and works, but it is not recommended

//+ (NSDictionary *)fetchQuotesSynchronouslyFor:(NSArray *)tickers {
//
//    NSLog(@"\nin fetchQuotesSynchronouslyFor:tickers:");
//
//    NSMutableDictionary *quotes = [[[NSMutableDictionary alloc] init] autorelease];
//
//    if (tickers && [tickers count] > 0) {
//
//        // Create a Yahoo Finance query for all ticker symbols in |tickers|
//
//        NSMutableString *query = [[NSMutableString alloc] initWithString:QUOTE_QUERY_PREFIX];
//
//        for (NSUInteger i = 0; i < [tickers count]; i++) {
//            NSString *ticker = [[tickers objectAtIndex:i] retain];
//            [query appendFormat:@"%%22%@%%22", ticker];
//            [ticker release];
//            if (i != [tickers count] - 1) [query appendString:@"%2C"];  // append + after all tickers, except the last
//        }
//
//        [query appendString:QUOTE_QUERY_SUFFIX];
//
//        NSLog(@"\nQuery: %@\n", query);
//
//        // Convert the Query to a URL Request
//
//        NSURL *url = [[NSURL URLWithString:query] retain];
//
//        // Invoke the URL via stringWithContentsOfURL:; save its results as JSON data
//
//        NSData *jsonData = [[[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding] retain];
//
//        // Convert the JSON data into a Dictionary
//
//        NSError *error = nil;
//        NSDictionary *results = jsonData ? [[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error] retain] : nil;
//
//        // Check results of Yahoo query
//
//        if (error) {
//            NSLog(@"\n[%@ %@] JSON error: %@\n", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
//        }
//
//        NSLog(@"\n[%@ %@] received %@\n", NSStringFromClass([self class]), NSStringFromSelector(_cmd), results);
//
//        NSArray *quoteEntries = [[results valueForKeyPath:@"query.results.quote"] retain];
//
//        for (NSDictionary *quoteEntry in quoteEntries) {
//            [quotes setValue:[quoteEntry valueForKey:@"BidRealtime"] forKey:[quoteEntry valueForKey:@"symbol"]];
//        }
//
//        [query release];
//        [url release];
//        [jsonData release];
//        [results release];
//        [quoteEntries release];
//    }
//    return quotes;
//}
// ********************************************************************************************************************************************************

@end
