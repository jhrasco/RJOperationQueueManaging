//
//  RJRequestOperationInfo.m
//  myClasses
//
//  Created by Ryan Jake on 6/21/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJRequestOperationInfo.h"

@interface RJRequestOperationInfo ()

@end

@implementation RJRequestOperationInfo

- (void)copyAllInfo
{
	RJRequestOperation *requestOperation = (RJRequestOperation *)self.operation;

	_isReady = YES;
	
	self.stringFormOfOperationState = [self.operation stringFormOfOperationState];
	self.operationQueueKey = [self.operation operationQueueKey];
	self.operationKey = self.operation.operationKey;
	self.operationTag = @(self.operation.operationTag);
	self.secondsElapsed = @([self.operation secondsElapsed]);

	self.urlString = requestOperation.urlString;
	self.httpMethod = requestOperation.httpMethod;
	self.currentNumberOfRetries = @(requestOperation.currentNumberOfRetries);
	self.maxNumberOfRetries = @(requestOperation.maxNumberOfRetries);
	self.progressInfo = [[RJProgressInfo alloc] initWithProgressInfo:requestOperation.progressInfo];

	_operation = nil;
}

#pragma mark -
#pragma mark RJRequestOperationDebugging

- (NSString *)debugURLString
{
	return _isReady ? self.urlString : [(RJRequestOperation *)self.operation urlString];
}

- (NSString *)debugHTTPMethod
{
	return _isReady ? self.httpMethod : [(RJRequestOperation *)self.operation httpMethod];
}

- (NSInteger)debugCurrentNumberOfRetries
{
	return _isReady ? [self.currentNumberOfRetries intValue] : [(RJRequestOperation *)self.operation currentNumberOfRetries];
}

- (NSInteger)debugMaxNumberOfRetries
{
	return _isReady ? [self.maxNumberOfRetries intValue] : [(RJRequestOperation *)self.operation maxNumberOfRetries];
}

- (RJProgressInfo *)debugProgressInfo
{
	return _isReady ? self.progressInfo : [(RJRequestOperation *)self.operation progressInfo];
}

@end
