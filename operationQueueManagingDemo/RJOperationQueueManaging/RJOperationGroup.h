//
//  RJOperationGroup.h
//  LO2
//
//  Created by Ryan Jake on 7/14/13.
//
//

#import <Foundation/Foundation.h>

#import "RJOperation.h"
#import "RJOperationQueueManager.h"
#import "RJSynchronousOperation.h"
#import "RJRequestTypes.h"
#import "RJRequestConstants.h"

/*
 
 
*/


@interface RJOperationGroup : NSObject

// TODO : Add callbacks for success, abort, cancel, fail/error.

- (void)setupOperations;
- (NSArray *)operations;

- (void)clearAllOperations;
- (void)runOperationGroupWithOperationQueueKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType;
- (void)runOperationGroup;

- (void)acknowledgeSuccessOperationGroup;
- (void)cancelOperationGroup;
- (void)abortOperationGroup;

- (void)addOperation:(RJOperation *)operation;
- (void)setOperationQueueKey:(NSString *)operationQueueKey queueType:(RJQueueType)queueType;

- (void)setSuccessBlock:(void (^)(RJOperationGroup*operation))successBlock;
- (void)setCancelBlock:(void (^)(RJOperationGroup*operation))cancelBlock;
- (void)setAbortBlock:(void (^)(RJOperationGroup*operation))abortBlock;
- (void)setCompletionBlock:(void (^)(RJOperationGroup*operation))completionBlock;

@property (nonatomic, strong)	RJSynchronousOperation *completionHandler;
@property (nonatomic, readonly) NSString *operationQueueKey;
@property (nonatomic, readonly) RJQueueType queueType;
@property (nonatomic, strong)	NSString *operationGroupKey;

@property (nonatomic, assign) BOOL shouldBlockWhenRunning;
@property (nonatomic, assign) BOOL shouldRunAgain;
@property (nonatomic, readonly, assign) BOOL isRunning;

@property (nonatomic, readonly, strong) RJOperationGroupSuccessBlock successBlock;
@property (nonatomic, readonly, strong) RJOperationGroupAbortBlock abortBlock;
@property (nonatomic, readonly, strong) RJOperationGroupCancelBlock cancelBlock;
@property (nonatomic, readonly, strong) RJOperationGroupCompletionBlock completionBlock;


@end
