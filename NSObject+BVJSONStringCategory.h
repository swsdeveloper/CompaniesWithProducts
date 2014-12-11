//
//  NSObject+BVJSONStringCategory.h
//  Parent
//
//  Created by Steven Shatz on 10/30/14.
//  Copyright (c) 2014 Steven Shatz. All rights reserved.
//

#import <Foundation/Foundation.h>


// *************************************************************************************************************************************************
// (see StackOverflow: http://stackoverflow.com/questions/6368867/generate-json-string-from-nsdictionary)

// Categories add methods to existing classes
// Syntax: @interface ClassName (CategoryName)

// Define "BVJSONString" Category for NSObject (which includes NSDictionary and NSArray):
// *************************************************************************************************************************************************


@interface NSObject (JsonMethods)

-(NSData *)dictionaryToJson:(NSDictionary *)dict;

-(NSDictionary *)jsonToDictionary:(NSData *)data;

-(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint;

@end
