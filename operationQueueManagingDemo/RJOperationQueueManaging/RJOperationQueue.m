//
//  RJOperationQueue.m
//  myClasses
//
//  Created by Ryan Jake on 6/11/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationQueue.h"

#import "RJOperation.h"
#import "RJOperationGroup.h"
#import "RJRequestConstants.h"


#define RJ_OPERATION_DEFAULT_MAX_CONCURRENT_COUNT (10)

@interface RJOperationQueue ()

@property (nonatomic, strong) NSMutableDictionary *	uniqueIDs;

@end

@implementation RJOperationQueue

@synthesize operationQueueKey = _operationQueueKey;
@synthesize supportsUniqueOperationKey = _supportsUniqueOperationKey;
@synthesize uniqueIDs = _uniqueIDs;
@synthesize maxOperationCount = _maxOperationCount;

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithOperationQueueKey:(NSString *)operationQueueKey
{
	self = [super init];
	if (self) {

		_maxOperationCount = 0;
		_operationQueueKey = operationQueueKey;

		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(onOperationBeganExecution:) name:RJOPERATION_DID_BEGIN_EXECUTING object:nil];
		[notificationCenter addObserver:self selector:@selector(onOperationFinishedExecution:) name:RJOPERATION_DID_FINISH_EXECUTING object:nil];
		[notificationCenter addObserver:self selector:@selector(onOperationCancelledExecution:) name:RJOPERATION_DID_CANCEL_EXECUTING object:nil];
		[super setMaxConcurrentOperationCount:RJ_OPERATION_DEFAULT_MAX_CONCURRENT_COUNT];
			
	}
	return self;
}

- (void)addOperation:(NSOperation *)op
{
	NSAssert([op isKindOfClass:[RJOperation class]], @"Operation added in this queue should be a subclass of RJOperation.");
	
	RJOperation *tempOperation = (RJOperation *)op;
	
	if (self.maxOperationCount > 0 && self.operationCount >= self.maxOperationCount) {
		return;
	}
	
	if (self.supportsUniqueOperationKey == YES) {
		if ([self.uniqueIDs objectForKey:tempOperation.operationKey] == nil) {
			[self.uniqueIDs setObject:[NSNull null] forKey:tempOperation.operationKey];
		}
		else {
			return;
		}
	}

	[super addOperation:op];
}

- (BOOL)customAddOperation:(NSOperation *)op
{
	NSAssert([op isKindOfClass:[RJOperation class]], @"Operation added in this queue should be a subclass of RJOperation.");
	
	RJOperation *tempOperation = (RJOperation *)op;
	
	if (self.maxOperationCount > 0 && self.operationCount >= self.maxOperationCount) {
		return NO;
	}

	if (self.supportsUniqueOperationKey == YES) {
		if ([self.uniqueIDs[tempOperation.operationKey] length] > 0) {
			self.uniqueIDs[tempOperation.operationKey] = [NSNull null];
		}
		else {
			return NO;
		}
	}
	
	[super addOperation:op];

	return YES;
}


- (RJOperation *)lastOperation
{
	if ([self.operations count] == 0) {
		return nil;
	}
	return [self.operations lastObject];
}

- (RJQueueType)queueType
{	
	return RJQueueTypeConcurrent;
}

- (void)onOperationBeganExecution:(NSNotification *)notification
{

}

- (void)onOperationFinishedExecution:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	RJOperation *operation = userInfo[RJREQUEST_USER_INFO_KEY];
	
	if (self.supportsUniqueOperationKey == YES && operation.operationKey) {
		[self.uniqueIDs removeObjectForKey:operation.operationKey];
	}
}

- (void)onOperationCancelledExecution:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	RJOperation *operation = userInfo[RJREQUEST_USER_INFO_KEY];
	
	if (self.supportsUniqueOperationKey == YES && operation.operationKey) {
		[self.uniqueIDs removeObjectForKey:operation.operationKey];
	}

}

- (NSMutableDictionary *)uniqueIDs
{
	if (_uniqueIDs == nil) {
		_uniqueIDs = [[NSMutableDictionary alloc] init];
	}
	return _uniqueIDs;
}

- (BOOL)operationExistsWithOperationKey:(NSString *)operationKey
{
	NSAssert(operationKey != nil, @"Operation Key should not be nil");
	
	return [self.uniqueIDs objectForKey:operationKey] != nil ? YES : NO;
}

@end
