//
//  RJOperation.m
//  myClasses
//
//  Created by Ryan Jake on 4/4/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJSynchronousOperation.h"
#import "RJRequestConstants.h"
#import "RJOperationInfo.h"

NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_QUEUED =		@"Queued";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_EXECUTING =	@"Executing";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FINISHED =	@"Finished";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FAILED =		@"Failed";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_CANCELLED =	@"Cancelled";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_RETRYING =	@"Retrying";
NSString *const RJ_SYNCHRONOUS_OPERATION_STRING_STATE_ABORTED =		@"Aborted";

@interface RJSynchronousOperation ()

- (void)_mainThreadBeginExecution;
- (void)_mainThreadFinishExecution;
- (void)_mainThreadCancelExecution;
- (void)_mainThreadRetryExecution;
- (void)_mainThreadFailExecution;
- (void)_mainThreadOperationMain;

@end

@implementation RJSynchronousOperation

@synthesize isExecuting =		_isExecuting;
@synthesize isFinished =		_isFinished;
@synthesize isConcurrent =		_isConcurrent;
@synthesize isFlagAsFailed =	_isFlagAsFailed;

@synthesize disableRetry =				_disableRetry;
@synthesize maxNumberOfRetries =		_maxNumberOfRetries;
@synthesize currentNumberOfRetries =	_currentNumberOfRetries;
@synthesize timeIntervalOfRetries =		_timeIntervalOfRetries;

+ (BOOL)shouldHandleFinishExecution
{
	return NO;
}

- (id)init
{
	self = [super init];
	if (self) {
		_operationState = RJOperationStateQueued;
		_maxNumberOfRetries = RJREQUEST_DEFAULT_NUMBER_OF_RETRIES;
		_timeIntervalOfRetries = 3.0f;
		
	}
	return self;
}

- (id)initWithOperation:(RJOperation *)operation
{
	self = [super initWithOperation:operation];
	if (self) {
		
	}
	return self;
}

- (void)start
{
	[self beginExecution];

	if (self.shouldAbortOperation == YES) {
		[self abortExecution];
		return;
	}
	
	if (self.isCancelled == YES) {
		[self cancelExecution];
		return;
	}

	if ([[self class] shouldHandleFinishExecution] == NO) {
		
		[self _mainThreadOperationMain];
				
		[self finishExecution];
	}

}

- (void)cancel
{
	[self cancelExecution];
	[super cancel];
}

- (void)abort
{
	[super abort];
}


- (void)_restart
{
	[self.operationDelegate operationMain:self];
	RJ_BLOCK_DISPATCH(self.operationMainBlock, self);
	[self finishExecution];
}

- (void)flagAsFailedWithError:(NSError *)error
{
	NSAssert(error != nil, @"Error parameter should not be nil.");
	
	_isFlagAsFailed = YES;
	
	_error = [error copy];

	if ([self.operationDelegate respondsToSelector:@selector(operationDidEncounterError:withError:)]) {
		[self.operationDelegate operationDidEncounterError:self withError:self.error];
	}
	
	RJ_BLOCK_DISPATCH(self.operationErrorBlock, self, self.error);
	RJ_POST_NOTIFICATION(RJOPERATION_DID_ERROR, nil, [self userInfoWrap]);
		
	if (self.disableRetry == YES) {
				
		[self finishExecution];
		return;
		
	}
		
	if (self.currentNumberOfRetries < self.maxNumberOfRetries) {
		
		_currentNumberOfRetries += 1;

		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.timeIntervalOfRetries * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self retryExecution];
		});

	}
	else {
		[self failExecution];
	}

	
}

#pragma mark -
#pragma mark Getter methods

- (BOOL)isCancelled
{
	return _isCancelled;
}

- (BOOL)isConcurrent
{
	return _isConcurrent;
}

- (BOOL)isExecuting
{
	return _isExecuting;
}

- (BOOL)isFinished
{
	return _isFinished;
}

#pragma mark -
#pragma mark Execution methods

- (void)beginExecution
{
	_timeStarted = [NSDate date];

	_operationState = RJOperationStateExecuting;
	
	[self _mainThreadBeginExecution];
	
	[self willChangeValueForKey: @"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey: @"isExecuting"];
	
    [self willChangeValueForKey: @"isFinished"];
    _isFinished = NO;
    [self didChangeValueForKey: @"isFinished"];
	
}

- (void)finishExecution
{
	if (_isCancelled == YES) {
		return;
	}
	
	_operationState = RJOperationStateFinished;

	[self.operationInfo copyAllInfo];

	[self _mainThreadFinishExecution];
	
	[self willChangeValueForKey: @"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey: @"isExecuting"];
	
    [self willChangeValueForKey: @"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey: @"isFinished"];

}

- (void)failExecution
{
	_operationState = RJOperationStateFailed;
	
	[self.operationInfo copyAllInfo];
	
	[self _mainThreadFailExecution];
	
	[self willChangeValueForKey: @"isExecuting"];
    _isExecuting = NO;
    [self didChangeValueForKey: @"isExecuting"];
	
    [self willChangeValueForKey: @"isFinished"];
    _isFinished = YES;
    [self didChangeValueForKey: @"isFinished"];
	
}

- (void)cancelExecution
{
	_operationState = RJOperationStateCancelled;

	[self.operationInfo copyAllInfo];

	[self _mainThreadCancelExecution];
	
	_isCancelled = YES;
	
	if (_isExecuting == YES) {
		[self willChangeValueForKey: @"isExecuting"];
		_isExecuting = NO;
		[self didChangeValueForKey: @"isExecuting"];

		[self willChangeValueForKey: @"isFinished"];
		_isFinished = YES;
		[self didChangeValueForKey: @"isFinished"];
	}

}

- (void)abortExecution
{
	_operationState = RJOperationStateAborted;
	
	[self.operationInfo copyAllInfo];
	
	[self _mainThreadAbortExecution];
	
	_isCancelled = YES;
	
	if (_isExecuting == YES) {
		[self willChangeValueForKey: @"isExecuting"];
		_isExecuting = NO;
		[self didChangeValueForKey: @"isExecuting"];
		
		[self willChangeValueForKey: @"isFinished"];
		_isFinished = YES;
		[self didChangeValueForKey: @"isFinished"];
	}
	
}

- (void)retryExecution
{
	_operationState = RJOperationStateRetrying;
	
	_isFlagAsFailed = NO;
	
	_error = nil;
	
	[self _mainThreadRetryExecution];
	

}

- (void)_mainThreadBeginExecution
{
	if (self.isCancelled == YES) {
		return;
	}
	
	dispatch_sync_to_main_thread(^{
		if ([self.operationDelegate respondsToSelector:@selector(operationWillBeginExecution:)]) {
			[self.operationDelegate operationWillBeginExecution:self];
		}
		RJ_BLOCK_DISPATCH(self.operationBeginBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
		RJ_POST_NOTIFICATION(RJOPERATION_DID_BEGIN_EXECUTING, nil, [self userInfoWrap]);
#endif
	});
}

- (void)_mainThreadFinishExecution
{
	if (self.isCancelled == YES) {
		return;
	}

	dispatch_sync_to_main_thread(^{
		[self.operationDelegate operationWillFinishExecution:self];
		RJ_BLOCK_DISPATCH(self.operationCompletionBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
		RJ_POST_NOTIFICATION(RJOPERATION_DID_FINISH_EXECUTING, nil, [self userInfoWrap]);
#endif
	});

}

- (void)_mainThreadFailExecution
{
	if (self.isCancelled == YES) {
		return;
	}

	dispatch_sync_to_main_thread(^{
		if ([self.operationDelegate respondsToSelector:@selector(operationDidGiveUp:)]) {
			[self.operationDelegate operationDidGiveUp:self];
		}
		RJ_BLOCK_DISPATCH(self.operationGiveUpBlock, self, self.error);
		RJ_POST_NOTIFICATION(RJOPERATION_DID_GIVE_UP, nil, [self userInfoWrap]);
	});
}

- (void)_mainThreadCancelExecution
{
	dispatch_sync_to_main_thread(^{
		if ([self.operationDelegate respondsToSelector:@selector(operationWillCancelExecution:)]) {
			[self.operationDelegate operationWillCancelExecution:self];
		}
		RJ_BLOCK_DISPATCH(self.operationCancelBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
		RJ_POST_NOTIFICATION(RJOPERATION_DID_CANCEL_EXECUTING, nil, [self userInfoWrap]);
#endif
	});
}

- (void)_mainThreadAbortExecution
{
	dispatch_sync_to_main_thread(^{
		if ([self.operationDelegate respondsToSelector:@selector(operationDidAbort:withError:)]) {
			[self.operationDelegate operationDidAbort:self withError:self.error];
		}
		RJ_BLOCK_DISPATCH(self.operationAbortBlock, self, self.error);
#ifdef ENABLE_DEBUG_DISPLAY
		RJ_POST_NOTIFICATION(RJOPERATION_DID_ABORT_EXECUTING, nil, [self userInfoWrap]);
#endif
	});
}

- (void)_mainThreadRetryExecution
{
	if (self.isCancelled == YES) {
		return;
	}

	dispatch_sync_to_main_thread(^{
		if ([self.operationDelegate respondsToSelector:@selector(operationWillRetry:)]) {
			[self.operationDelegate operationWillRetry:self];
		}
		RJ_BLOCK_DISPATCH(self.operationRetryBlock, self, self.error);
		RJ_POST_NOTIFICATION(RJOPERATION_WILL_RETRY, nil, [self userInfoWrap]);
	});
}

- (void)_mainThreadOperationMain
{
	dispatch_sync_to_main_thread(^{
		[self.operationDelegate operationMain:self];
		RJ_BLOCK_DISPATCH(self.operationMainBlock, self);
	});
}

#pragma mark -
#pragma mark RJOperationProtocol

- (void)operationWillBeginExecution:(RJOperation *)operation
{
	
}

- (void)operationWillFinishExecution:(RJOperation *)operation
{
	
}

- (void)operationWillCancelExecution:(RJOperation *)operation
{
	
}

- (void)operationMain:(RJOperation *)operation
{
	
}

#pragma mark -
#pragma mark RJSynchronousOperationProtocol

- (void)operationDidEncounterError:(RJSynchronousOperation *)operation withError:(NSError *)error
{
	
}

- (void)operationDidAbort:(RJSynchronousOperation *)operation withError:(NSError *)error;
{
	
}

- (void)operationWillRetry:(RJSynchronousOperation *)operation
{
	
}

- (void)operationDidGiveUp:(RJSynchronousOperation *)operation
{
	
}

#pragma mark -
#pragma mark Debug

- (NSString *)debugDescription
{
	return [super debugDescription];
}

- (NSString *)description
{
	return [super description];
}


@end
