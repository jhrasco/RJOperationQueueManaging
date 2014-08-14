//
//  RJOperation.h
//  myClasses
//
//  Created by Ryan Jake on 4/4/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJRequestTypes.h"
#import "RJOperation.h"

/*
 Documentation To Follow
*/

extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_QUEUED;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_EXECUTING;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FINISHED;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FAILED;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_CANCELLED;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_RETRYING;
extern NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_ABORTED;

@class RJSynchronousOperation;

@interface RJSynchronousOperation : RJOperation <RJOperationProtocol> {
	
	BOOL													_isExecuting;
	BOOL													_isFinished;
	BOOL													_isConcurrent;
	BOOL													_isCancelled;
	BOOL													_isFlagAsFailed;
	BOOL													_disableRetry;
	NSInteger												_maxNumberOfRetries;
	NSInteger												_currentNumberOfRetries;
	NSTimeInterval											_timeIntervalOfRetries;

}

+ (BOOL)shouldHandleFinishExecution;

- (void)beginExecution;
- (void)cancelExecution;
- (void)finishExecution;
- (void)retryExecution;
- (void)abortExecution;
- (void)failExecution;

- (void)flagAsFailedWithError:(NSError *)error;

@property (nonatomic, readonly, assign)		BOOL								isExecuting;
@property (nonatomic, readonly, assign)		BOOL								isFinished;
@property (nonatomic, readonly, assign)		BOOL								isConcurrent;
@property (nonatomic, readonly, assign)		BOOL								isFlagAsFailed;
@property (nonatomic, assign)				BOOL								disableRetry;
@property (nonatomic, assign)				NSInteger							maxNumberOfRetries;
@property (nonatomic, assign)				NSInteger							currentNumberOfRetries;
@property (nonatomic, assign)				NSTimeInterval						timeIntervalOfRetries;

@end
