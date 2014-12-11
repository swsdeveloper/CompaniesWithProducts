//
//  NSString+FindSubstringCategory.m
//  Parent
//
//  Created by Steven Shatz on 10/31/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "NSString+FindSubstringCategory.h"

@implementation NSString (FindSubstring)

-(NSRange)findSubstring:(NSString *)substring {
    
    if (self.length > 0 && substring.length > 0) {
        return [self rangeOfString:substring options:NSCaseInsensitiveSearch ];   // returns range of substring within string
    }
    return NSMakeRange(0,0);  // substring not found
}

-(NSString *)getStringFollowingSubstring:(NSString *)substring {
    
    NSRange range = [self findSubstring:substring];
    
    if (range.location > 0 && range.length > 0) {
        NSUInteger startPos = range.location + range.length;
        return [self substringFromIndex:startPos];
    } else {
        return self;
    }
    
}

@end
