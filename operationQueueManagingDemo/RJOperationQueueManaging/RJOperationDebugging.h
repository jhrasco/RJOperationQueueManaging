//
//  RJOperationDebugging.h
//  myClasses
//
//  Created by Ryan Jake on 6/19/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJRequestOperation.h"


@protocol RJOperationDebugging <NSObject>

- (NSString *)debugOperationState;
- (NSString *)debugOperationQueueKey;
- (NSString *)debugOperationKey;
- (NSInteger)debugOperationTag;
- (NSTimeInterval)debugSecondsElapsed;

@end

@protocol RJRequestOperationDebugging <NSObject, RJOperationDebugging>

- (NSString *)debugURLString;
- (NSString *)debugHTTPMethod;
- (NSInteger)debugCurrentNumberOfRetries;
- (NSInteger)debugMaxNumberOfRetries;
- (RJProgressInfo *)debugProgressInfo;

@end