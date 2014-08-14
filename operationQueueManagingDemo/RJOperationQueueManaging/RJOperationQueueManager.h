//
//  RJOperationQueueManager.h
//  myClasses
//
//  Created by Ryan Jake on 6/12/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RJRequestTypes.h"

@class RJOperation;
@class RJOperationGroup;

@interface RJOperationQueueManager : NSObject

+ (RJOperationQueueManager *)operationQueueManager;
- (void)initializeDebugWindow;

- (void)resumeOperationQueueWithKey:(NSString *)requestQueueKey;
- (void)resumeAllOperations;
- (void)suspendOperationQueueWithKey:(NSString *)requestQueueKey;
- (void)suspendAllOperations;
- (void)suspendAllOperationsExceptQueueWithKey:(NSString *)operationQueueKey;
- (void)abortOperationQueueWithKey:(NSString *)requestQueueKey;
- (void)abortAllOperations;
- (void)cancelOperationQueueWithKey:(NSString *)requestQueueKey;
- (void)cancelAllOperations;
- (void)destroyOperationQueueWithKey:(NSString *)operationQueueKey;
- (void)destroyAllOperationQueues;
- (void)destroyAllIdleOperationQueues;

- (void)addOperation:(RJOperation *)operation;
- (void)addOperation:(RJOperation *)operation
		withQueueKey:(NSString *)operationQueueKey
	   withQueueType:(RJQueueType)queueType;

- (void)cancelOperationWithOperationKey:(NSString *)operationKey;
- (void)cancelOperationWithOperationKey:(NSString *)operationKey
					  operationQueueKey:(NSString *)operationQueueKey
							  queueType:(RJQueueType)queueType;


- (void)setMaxConcurrentCount:(NSInteger)maxConcurrentCount
		withOperationQueueKey:(NSString *)operationQueueKey;
- (NSInteger)maxConcurrentCountWithOperationQueueKey:(NSString *)operationQueueKey;

- (void)setSupportsUniqueOperationKey:(BOOL)supportUniqueOperationKey
				withOperationQueueKey:(NSString *)operationQueueKey;
- (BOOL)supportsUniqueOperationKeyWithOperationQueueKey:(NSString *)operationQueueKey;
- (BOOL)operationExistsOnOperationQueueWithKey:(NSString *)operationQueueKey
							  withOperationKey:(NSString *)operationKey;
- (BOOL)operationQueueIsBusyWithKey:(NSString *)operationQueueKey;

- (void)setMaxOperationCount:(NSInteger)maxOperationCount withOperationOperationQueueKey:(NSString *)operationQueueKey;
- (NSInteger)maxOperationCount:(NSInteger)maxOperationCount withOperationOperationQueueKey:(NSString *)operationQueueKey;

- (void)createOperationQueueWithKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType;

- (NSArray *)allOperationInfos;

@end
