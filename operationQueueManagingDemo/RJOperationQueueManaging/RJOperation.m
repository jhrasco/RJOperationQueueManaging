//
//  RJOperation.m
//  myClasses
//
//  Created by Ryan Jake on 5/13/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperation.h"
#import "RJRequestConstants.h"
#import "RJOperationQueue.h"
#import "RJOperationGroup.h"
#import "RJOperationInfo.h"

static NSDictionary * _operationStateLookUpTable = nil;

@interface RJOperation ()

- (NSString *)_internalDescription;

@end

@implementation RJOperation

@synthesize operationDelegate =			_operationDelegate;
@synthesize operationQueue =			_operationQueue;
@synthesize operationGroup =			_operationGroup;
@synthesize operationBeginBlock =		_operationBeginBlock;
@synthesize operationCompletionBlock =	_operationCompletionBlock;
@synthesize operationMainBlock =		_operationMainBlock;
@synthesize operationCancelBlock =		_operationCancelBlock;
@synthesize operationErrorBlock =		_operationErrorBlock;
@synthesize operationRetryBlock =		_operationRetryBlock;
@synthesize operationGiveUpBlock =		_operationGiveUpBlock;
@synthesize operationAbortBlock =		_operationAbortBlock;
@synthesize operationState =			_operationState;
@synthesize operationTag =				_operationTag;
@synthesize operationKey =				_operationKey;
@synthesize timeStarted =				_timeStarted;
@synthesize operationInfo =				_operationInfo;
@synthesize userInfo =					_userInfo;
@synthesize userInfoWrap =				_userInfoWrap;
@synthesize error =						_error;

- (Class)operationInfoClass
{
	return [RJOperationInfo class];
}

- (id)init
{
	self = [super init];
	if (self) {
		_operationDelegate = self;
	}
	return self;
}

- (id)initWithOperation:(RJOperation *)operation
{
	self = [super init];
	if (self) {

		self.operationDelegate = operation.operationDelegate;
		self.operationQueue = operation.operationQueue;
		self.operationBeginBlock = [operation.operationBeginBlock copy];
		self.operationCompletionBlock = [operation.operationCompletionBlock copy];
		self.operationMainBlock = [operation.operationMainBlock copy];
		self.operationCancelBlock = [operation.operationCancelBlock copy];
		self.operationErrorBlock = [operation.operationErrorBlock copy];
		self.operationRetryBlock = [operation.operationRetryBlock copy];
		self.operationGiveUpBlock = [operation.operationGiveUpBlock copy];
		self.operationAbortBlock = [operation.operationAbortBlock copy];
		self.operationTag = operation.operationTag;
		self.operationKey = operation.operationKey;
		self.userInfo = operation.userInfo;
		
	}
	return self;
}

- (void)abort
{
	[self abortWithError:nil];
}

- (void)abortWithError:(NSError *)error
{
	_shouldAbortOperation = YES;
	_error = [error copy];
}

- (NSString *)stringFormOfOperationState
{
	NSDictionary *lookupTable = [[self class] operationStateLookUpTable];
	
	NSString *stringState = lookupTable[@(self.operationState)];

	return stringState;
}

- (RJOperation *)operationDependencyWithOperationTag:(NSUInteger)operationTag
{
	for (id operation in [self dependencies]) {
		if ([operation isKindOfClass:[RJOperation class]]) {
			RJOperation *tempOperation = (RJOperation *)operation;
			if (tempOperation.operationTag == operationTag) {
				return tempOperation;
			}
		}
	}
	return nil;
}

- (RJOperation *)operationDependencyWithOperationKey:(NSString *)operationKey
{
	for (id operation in [self dependencies]) {
		if ([operation isKindOfClass:[RJOperation class]]) {
			RJOperation *tempOperation = (RJOperation *)operation;
			if ([tempOperation.operationKey isEqualToString:operationKey]) {
				return tempOperation;
			}
		}
	}
	return nil;
}

- (NSTimeInterval)secondsElapsed
{
	return (NSTimeInterval)([[NSDate date] timeIntervalSince1970] - [self.timeStarted timeIntervalSince1970]);
}

- (void)setOperationBeginBlock:(void (^)(RJOperation*operation))operationBeginBlock
{
	_operationBeginBlock = operationBeginBlock;
}

- (void)setOperationCompletionBlock:(void (^)(RJOperation*operation))operationCompletionBlock
{
	_operationCompletionBlock = operationCompletionBlock;
}

- (void)setOperationMainBlock:(void (^)(RJOperation*operation))operationMainBlock
{
	_operationMainBlock = operationMainBlock;
}

- (void)setOperationCancelBlock:(void (^)(RJOperation*operation))operationCancelBlock
{
	_operationCancelBlock = operationCancelBlock;
}

- (void)setOperationErrorBlock:(void (^)(RJOperation*operation, NSError *error))operationErrorBlock
{
	_operationErrorBlock = operationErrorBlock;
}

- (void)setOperationRetryBlock:(void (^)(RJOperation*operation, NSError *error))operationRetryBlock
{
	_operationRetryBlock = operationRetryBlock;
}

- (void)setOperationGiveUpBlock:(void (^)(RJOperation*operation, NSError *error))operationGiveUpBlock
{
	_operationGiveUpBlock = operationGiveUpBlock;
}

- (void)setOperationAbortBlock:(void (^)(RJOperation*operation, NSError *error))operationAbortBlock
{
	_operationAbortBlock = operationAbortBlock;
}

- (NSString *)operationQueueKey
{
	return self.operationQueue.operationQueueKey;
}

- (NSDictionary *)userInfoWrap
{
	if (_userInfoWrap == nil) {
		_userInfoWrap = @{RJREQUEST_USER_INFO_KEY:self};
	}
	return _userInfoWrap;
}

- (RJOperationInfo *)operationInfo
{
	if (_operationInfo == nil) {
		_operationInfo = [[[self operationInfoClass] alloc] initWithOperation:self];
	}
	return _operationInfo;
}

#pragma mark -
#pragma mark Debugging

- (NSString *)debugDescription
{
	return [self _internalDescription];
}

- (NSString *)description
{
	return [self _internalDescription];
}

- (NSString *)_internalDescription
{
	NSMutableString *debugDescription = [[NSMutableString alloc] init];
	[debugDescription appendFormat:@"%@", NSStringFromClass([self class])]; [debugDescription appendFormat:@"\n"];
	[debugDescription appendFormat:@"operationTag : %d", self.operationTag]; [debugDescription appendFormat:@"\n"];
	[debugDescription appendFormat:@"operationKey : %@", self.operationKey]; [debugDescription appendFormat:@"\n"];
	[debugDescription appendFormat:@"operationState : %@", [self stringFormOfOperationState]]; [debugDescription appendFormat:@"\n"];
	[debugDescription appendFormat:@"secondsElapsed : %f", [self secondsElapsed]]; [debugDescription appendFormat:@"\n"];
	return debugDescription;
}

+ (NSDictionary *)operationStateLookUpTable
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_operationStateLookUpTable = @{
		@(RJOperationStateQueued):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_QUEUED,
		@(RJOperationStateExecuting):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_EXECUTING,
		@(RJOperationStateFinished):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FINISHED,
		@(RJOperationStateFailed):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_FAILED,
		@(RJOperationStateCancelled):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_CANCELLED,
		@(RJOperationStateRetrying):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_RETRYING,
		@(RJOperationStateAborted):RJ_SYNCHRONOUS_OPERATION_STRING_STATE_ABORTED,
		};
	});
	return _operationStateLookUpTable;
}


@end
