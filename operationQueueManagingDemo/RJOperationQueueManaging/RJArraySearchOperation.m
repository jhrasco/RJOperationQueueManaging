//
//  RJArraySearchOperation.m
//  myClasses
//
//  Created by Ryan Jake on 6/23/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJArraySearchOperation.h"

#import "RJSynchronousOperation.h"
#import "RJAsynchronousOperation.h"
#import "RJOperationQueueManager.h"

#import "RJRequestConstants.h"

@interface RJArraySearchOperation ()

@property (nonatomic, strong) NSMutableArray *operations;

@end

@implementation RJArraySearchOperation

@synthesize array =							_array;
@synthesize arraySearchCompletionBlock =	_arraySearchCompletionBlock;
@synthesize operations =					_operations;

- (id)initWithArray:(NSArray *)array
{
	self = [super init];
	if (self) {
		_array = array;
	}
	return self;
}

- (void)setArraySearchCompletionBlock:(void (^)(RJArraySearchOperation*operation, NSInteger index, id object))arraySearchCompletionBlock
{
	_arraySearchCompletionBlock = arraySearchCompletionBlock;
}

- (void)searchObject:(id)object inOperationQueueWithKey:(NSString *)operationQueueKey
{
	RJOperationQueueManager *operationQueueManager = [RJOperationQueueManager operationQueueManager];
	
	NSInteger operationMaxConcurrentCount = [operationQueueManager maxConcurrentCountWithOperationQueueKey:operationQueueKey];
	
	NSInteger count = [_array count];
	NSInteger remainder = count % operationMaxConcurrentCount;
	NSInteger quart = (int)(count / operationMaxConcurrentCount);
	
	NSInteger indexLowerBound = 0;
	NSInteger indexUpperBound = indexLowerBound + quart;
	
	self.operations = [[NSMutableArray alloc] init];
	
	RJSynchronousOperation *syncOperation = [[RJSynchronousOperation alloc] init];
	
	for (int ii=0; ii<operationMaxConcurrentCount-1; ii++) {
		
		RJInternalArraySearchOperation *operation = [[RJInternalArraySearchOperation alloc] init];
		operation.array = _array;
		operation.object = object;
		operation.lowerBound = indexLowerBound;
		operation.upperBound = indexUpperBound;
		[syncOperation addDependency:operation];
		[self.operations addObject:operation];
		[operation setOperationCompletionBlock:^(RJOperation *operation) {
			RJLOGINFO1(@"secondsElapsed : %f", [operation secondsElapsed]);
		}];
		
		[operationQueueManager addOperation:operation withQueueKey:operationQueueKey withQueueType:RJQueueTypeConcurrent];
		
		indexLowerBound = indexUpperBound;
		indexUpperBound += quart;
	}
	
	RJInternalArraySearchOperation *operation = [[RJInternalArraySearchOperation alloc] init];
	operation.array = _array;
	operation.object = object;
	operation.lowerBound = indexLowerBound;
	operation.upperBound = indexUpperBound + remainder;
	[syncOperation addDependency:operation];
	[self.operations addObject:operation];
	[operation setOperationCompletionBlock:^(RJOperation *operation) {
		RJLOGINFO1(@"secondsTookToComplete : %f", [operation secondsElapsed]);
	}];
	
	[operationQueueManager addOperation:operation];

	[syncOperation setOperationMainBlock:^(RJOperation *operation) {
		
		for (RJInternalArraySearchOperation *tempOperation in self.operations) {
			if (tempOperation.objectIndex != -1) {
				RJ_BLOCK_DISPATCH(self.arraySearchCompletionBlock, self, tempOperation.objectIndex, [_array objectAtIndex:tempOperation.objectIndex]);
				self.operations = nil;
				break;
			}
		}
		
	}];

	[operationQueueManager addOperation:syncOperation];

}

@end


@implementation RJInternalArraySearchOperation

@synthesize array = _array;
@synthesize lowerBound = _lowerBound;
@synthesize upperBound = _upperBound;
@synthesize objectIndex = _objectIndex;
@synthesize object = _object;

- (void)operationMain:(RJOperation *)operation
{
	NSObject *tempObject;
	_objectIndex = -1;
	
	for (NSInteger ii=_lowerBound; ii<_upperBound; ii++) {
		tempObject = [_array objectAtIndex:ii];
		if ([tempObject isEqual:_object]) {
			_objectIndex = ii;
			RJLOGINFO1(@"index %d", _objectIndex);
			return;
		}
	}
}

@end
