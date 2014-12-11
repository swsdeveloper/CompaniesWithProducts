//
//  DetailViewController.h
//  CompaniesAndProducts
//
//  Created by Steven Shatz on 11/6/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController < UIWebViewDelegate >

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@property (retain, nonatomic) NSURL *url;

@end
