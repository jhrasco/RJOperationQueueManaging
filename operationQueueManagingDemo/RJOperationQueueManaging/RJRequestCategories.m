//
//  RJRequestCategories.m
//  myClasses
//
//  Created by Ryan Jake on 11/23/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import "RJRequestCategories.h"

@implementation RJRequestCategories

@end


@implementation NSDictionary (HTTPQueryString)

- (NSString *)urlQueryStringWithDictionary
{
	
    NSMutableArray *parameters = [NSMutableArray array];
    
    NSArray *keys = [self allKeys];
    
    for(NSString *key in keys){
        
        id object = [self objectForKey:key];
        
        if([object isKindOfClass:[NSString class]]){
            [parameters addObject:[NSString stringWithFormat:@"%@=%@", key, object]];
        } else if([object isKindOfClass:[NSArray class]]){
            [parameters addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSArray *)object componentsJoinedByString:@","]]];
        } else if([object isKindOfClass:[NSNumber class]]){
            [parameters addObject:[NSString stringWithFormat:@"%@=%i", key, [(NSNumber *)object intValue]]];
        } else if([object isKindOfClass:[NSDate class]]){
            NSAssert(NO, @"Please use date formatted as strings.");
        }
        
    }
    
	NSString *stringParams = [parameters componentsJoinedByString:@"&"];
	
    return stringParams;
}


@end