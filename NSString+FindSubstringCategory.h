//
//  NSString+FindSubstringCategory.h
//  Parent
//
//  Created by Steven Shatz on 10/31/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FindSubstring)

-(NSRange)findSubstring:(NSString *)substring;

-(NSString *)getStringFollowingSubstring:(NSString *)substring;

@end
