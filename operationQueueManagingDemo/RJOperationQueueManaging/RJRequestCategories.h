//
//  RJRequestCategories.h
//  myClasses
//
//  Created by Ryan Jake on 11/23/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJRequestCategories : NSObject

@end


@interface NSDictionary (HTTPQueryString)

- (NSString *)urlQueryStringWithDictionary;

@end