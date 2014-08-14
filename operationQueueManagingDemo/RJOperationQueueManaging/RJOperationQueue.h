//
//  RJOperationQueue.h
//  myClasses
//
//  Created by Ryan Jake on 6/11/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJRequestTypes.h"

@class RJOperation;

@interface RJOperationQueue : NSOperationQueue

- (id)initWithOperationQueueKey:(NSString *)operationQueueKey;
- (RJOperation *)lastOperation;
- (RJQueueType)queueType;
- (BOOL)operationExistsWithOperationKey:(NSString *)operationKey;
- (BOOL)customAddOperation:(NSOperation *)op;

@property (nonatomic, readonly, strong) NSString *	operationQueueKey;
@property (nonatomic, assign) BOOL					supportsUniqueOperationKey;
@property (nonatomic, assign) NSInteger				maxOperationCount;


@end
