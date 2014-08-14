//
//  RJSerialOperationQueue.m
//  myClasses
//
//  Created by Ryan Jake on 6/12/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJSerialOperationQueue.h"
#import "RJRequestConstants.h"
#import "RJOperation.h"

#define RJ_SERIAL_OPERATION_DEFAULT_MAX_CONCURRENT_COUNT (1)

@interface RJSerialOperationQueue ()

- (void)_removeAllDependencies:(RJOperation *)operation;

@end

@implementation RJSerialOperationQueue

- (id)init
{
	self = [super init];
	if (self) {
		[super setMaxConcurrentOperationCount:RJ_SERIAL_OPERATION_DEFAULT_MAX_CONCURRENT_COUNT];
	}
	return self;
}

- (id)initWithOperationQueueKey:(NSString *)operationQueueKey
{
	self = [super initWithOperationQueueKey:operationQueueKey];
	if (self) {
		[super setMaxConcurrentOperationCount:RJ_SERIAL_OPERATION_DEFAULT_MAX_CONCURRENT_COUNT];
	}
	return self;
}

- (void)addOperation:(NSOperation *)op
{
	[self _removeAllDependencies:(RJOperation *)op];

	RJOperation *operation = [self lastOperation];
	
	if (operation) {
		[op addDependency:operation];
	}
	
	[super addOperation:op];
}

- (void)setMaxConcurrentOperationCount:(NSInteger)cnt
{
	RJLOGINFO1(@"Setting maxConcurrentOperationCount in an RJSerialOperationQueue will not have any effect.");
}

- (RJQueueType)queueType
{
	return RJQueueTypeSerial;
}

- (void)_removeAllDependencies:(RJOperation *)operation
{
	for (RJOperation *tempOperation in [operation dependencies]) {
		[operation removeDependency:tempOperation];
	}
}

@end
