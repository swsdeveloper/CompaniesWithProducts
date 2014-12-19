//
//  DetailViewController.m
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.

#import "DetailViewController.h"
#import "Constants.h"
#import "DataAccessObject.h"


@implementation DetailViewController

- (void)dealloc {
    // NSLog(@"in DetailViewController dealloc");
    [_webView release];
    [_url release];
    [_urlRequest release];
    [super dealloc];
}

- (void)viewDidLoad {
    //NSLOG(@"in DetailViewController viewDidLoad");
    [super viewDidLoad];

    //    NSLog(@"in viewDidLoad: url = %@", [self.url description]);
    
    NSAssert([self.webView isKindOfClass:[UIWebView class]], @"Your webView outlet is not correctly connected.");
    NSAssert(self.webView.scalesPageToFit, @"You forgot to check 'Scales Page to Fit' for your web view.");
}

- (void)viewWillAppear:(BOOL)animated {
    //NSLOG(@"in DetailViewController viewWillAppear");

    [super viewWillAppear:animated];
    
    // Debugging Code:
    // [self loadRequestFromString:@"http://google.com"];
    
    [self loadRequestFromURL:self.url];
}

- (void)viewWillDisappear:(BOOL)animated {
    // NSLog(@"in DetailViewController viewWillDisappear");
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_webView stopLoading];
    
    NSURL *url = [NSURL URLWithString:@"about:blank"];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

//- (void)loadRequestFromString:(NSString*)urlString
//{
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    UIWebView *webView2 = [[UIWebView alloc] initWithFrame:self.webView.frame];
//    [self.webView addSubview:webView2];
//    [webView2 loadRequest:urlRequest];
//    [webView2 release];
//}

- (void)loadRequestFromURL:(NSURL*)url {
    
    // NSLog(@"in DetailViewController loadRequestFromURL");
    
    self.urlRequest = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:self.urlRequest];
}

- (void)didReceiveMemoryWarning {
    // NSLog(@"in DetailViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // NSLog(@"in DetailViewController webView:shouldStartLoadWithRequest:");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
     NSLog(@"in DetailViewController webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     NSLog(@"in DetailViewController webViewDidFinishLoad");
    [webView stopLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
     NSLog(@"in DetailViewController webView:didFailWithError: %@", [error localizedDescription]);
    [webView stopLoading];
}

@end

