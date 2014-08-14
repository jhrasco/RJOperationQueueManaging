//
//  RJOperationInfo.m
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationInfo.h"

@interface RJOperationInfo ()

@end

@implementation RJOperationInfo

@synthesize operation = _operation;
@synthesize debugLogs = _debugLogs;

@synthesize isReady = _isReady;
@synthesize stringFormOfOperationState = _stringFormOfOperationState;
@synthesize operationQueueKey = _operationQueueKey;
@synthesize operationKey = _operationKey;
@synthesize operationTag = _operationTag;
@synthesize secondsTookToComplete = _secondsTookToComplete;
@synthesize secondsElapsed = _secondsElapsed;

- (id)initWithOperation:(RJOperation *)operation
{
	self = [super init];
	if (self) {
		_operation = operation;
	}
	return self;
}

- (void)copyAllInfo
{
	_isReady = YES;

	self.stringFormOfOperationState = [self.operation stringFormOfOperationState];
	self.operationQueueKey = [self.operation operationQueueKey];
	self.operationKey = self.operation.operationKey;
	self.operationTag = @(self.operation.operationTag);
	self.secondsElapsed = @([self.operation secondsElapsed]);

	_operation = nil;
}

#pragma mark -
#pragma mark RJOperationDebugging

- (NSString *)debugOperationState
{
	return _isReady ? self.stringFormOfOperationState : [self.operation stringFormOfOperationState];
}

- (NSString *)debugOperationQueueKey
{
	return _isReady ? self.operationQueueKey : [self.operation operationQueueKey];
}

- (NSString *)debugOperationKey
{
	return _isReady ? self.operationKey : self.operation.operationKey;
}

- (NSInteger)debugOperationTag
{
	return _isReady ? [self.operationTag intValue] : self.operation.operationTag;
}

- (NSTimeInterval)debugSecondsElapsed
{
	return _isReady ? [self.secondsElapsed floatValue] : [self.operation secondsElapsed];
}


@end
