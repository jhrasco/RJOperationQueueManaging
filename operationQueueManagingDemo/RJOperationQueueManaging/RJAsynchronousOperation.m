//
//  RJAsynchronousOperation.m
//  myClasses
//
//  Created by Ryan Jake on 5/13/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJAsynchronousOperation.h"

#import "RJRequestConstants.h"
#import "RJOperationInfo.h"

@interface RJAsynchronousOperation ()

- (void)_mainThreadWillBeginExecution;
- (void)_mainThreadWillFinishExecution;
- (void)_mainThreadWillCancelExecution;
- (void)_mainThreadWillAbortExecution;
- (void)_mainThreadOperationMain;

@end

@implementation RJAsynchronousOperation

- (id)init
{
	self = [super init];
	if (self) {
		_operationDelegate = self;
	}
	return self;
}

- (id)initWithAsynchronousOperation:(RJAsynchronousOperation *)asynchronousOperation
{
	self = [super initWithOperation:asynchronousOperation];
	if (self) {
		
	}
	return self;
}

- (void)cancel
{
	dispatch_sync_to_main_thread(^{
		[self _mainThreadWillCancelExecution];
	});

	[super cancel];
}

- (void)main
{
	if (self.shouldAbortOperation == YES) {
		dispatch_sync_to_main_thread(^{
			[self _mainThreadWillAbortExecution];
		});
		return;
	}
	
	if (self.isCancelled == YES) {
		dispatch_sync_to_main_thread(^{
			[self _mainThreadWillCancelExecution];
		});
		return;
	}

	dispatch_sync_to_main_thread(^{
		[self _mainThreadWillBeginExecution];
	});

#ifdef ENABLE_TRY_CATCH_DEBUG
	
	@try {
		[self _mainThreadOperationMain];
	}
	@catch (NSException *exception) {
		RJLOGINFO1(@"exception : %@", exception);
	}
#else
	[self _mainThreadOperationMain];
#endif


	dispatch_sync_to_main_thread(^{
		[self _mainThreadWillFinishExecution];
	});

}

- (void)_mainThreadWillBeginExecution
{
	if (self.isCancelled == YES) {
		return;
	}

	_timeStarted = [NSDate date];

	self.operationState = RJOperationStateExecuting;

	[self.operationDelegate operationWillBeginExecution:self];
	RJ_BLOCK_DISPATCH(self.operationBeginBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
	RJ_POST_NOTIFICATION(RJOPERATION_DID_BEGIN_EXECUTING, nil, [self userInfoWrap]);
#endif

}

- (void)_mainThreadWillFinishExecution
{
	if (self.isCancelled == YES) {
		return;
	}

	self.operationState = RJOperationStateFinished;

	[self.operationInfo copyAllInfo];

	[self.operationDelegate operationWillFinishExecution:self];
	RJ_BLOCK_DISPATCH(self.operationCompletionBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
	RJ_POST_NOTIFICATION(RJOPERATION_DID_FINISH_EXECUTING, nil, [self userInfoWrap]);
#endif

}

- (void)_mainThreadWillCancelExecution
{
	self.operationState = RJOperationStateCancelled;

	[self.operationInfo copyAllInfo];

	[self.operationDelegate operationWillCancelExecution:self];
	RJ_BLOCK_DISPATCH(self.operationCancelBlock, self);
#ifdef ENABLE_DEBUG_DISPLAY
	RJ_POST_NOTIFICATION(RJOPERATION_DID_CANCEL_EXECUTING, nil, [self userInfoWrap]);
#endif

}

- (void)_mainThreadWillAbortExecution
{
	self.operationState = RJOperationStateAborted;
	
	[self.operationInfo copyAllInfo];
	
	[self.operationDelegate operationDidAbort:self withError:self.error];
	RJ_BLOCK_DISPATCH(self.operationAbortBlock, self, self.error);
#ifdef ENABLE_DEBUG_DISPLAY
	RJ_POST_NOTIFICATION(RJOPERATION_DID_ABORT_EXECUTING, nil, [self userInfoWrap]);
#endif
	
}

- (void)_mainThreadOperationMain
{
	RJ_BLOCK_DISPATCH(self.operationMainBlock, self);
	
	[self.operationDelegate operationMain:self];
}

#pragma mark -
#pragma mark RJOperationProtocol

- (void)operationWillBeginExecution:(RJOperation *)operation;
{
	
}

- (void)operationWillCancelExecution:(RJOperation *)operation
{
	
}

- (void)operationMain:(RJOperation *)operation
{
	
}

- (void)operationWillFinishExecution:(RJOperation *)operation
{
	
}

- (void)operationDidAbort:(RJOperation *)operation withError:(NSError *)error
{
	
}

- (void)operationDidEncounterError:(RJOperation *)operation withError:(NSError *)error
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
