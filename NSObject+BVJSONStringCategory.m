//
//  NSObject+BVJSONStringCategory.m
//  Parent
//
//  Created by Steven Shatz on 10/30/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import "NSObject+BVJSONStringCategory.h"


@implementation NSObject (JsonMethods)

-(NSData *)dictionaryToJson:(NSDictionary *)dict {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) 0
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"dictionaryToJson: error: %@", error.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}

-(NSDictionary *)jsonToDictionary:(NSData *)jsonData {
    
    NSError *error;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:(NSJSONReadingOptions) NSJSONReadingMutableContainers
                                                           error:&error];
    
    if (! jsonData) {
        NSLog(@"jsonToDictionary: error: %@", error.localizedDescription);
        return nil;
    } else {
        return dict;
    }
}

-(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
