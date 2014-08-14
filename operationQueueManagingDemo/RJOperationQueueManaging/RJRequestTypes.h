//
//  RJRequestTypes.h
//  myClasses
//
//  Created by Ryan Jake on 12/2/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

// typedefs

@class RJRequestCommonData;
@class RJRequestOperation;
@class RJOperation;
@class RJArraySearchOperation;
@class RJProgressInfo;
@class RJOperationGroup;

typedef void (^RJOperationGroupSuccessBlock)(RJOperationGroup*operation);
typedef void (^RJOperationGroupAbortBlock)(RJOperationGroup*operation);
typedef void (^RJOperationGroupCompletionBlock)(RJOperationGroup*operation);
typedef void (^RJOperationGroupCancelBlock)(RJOperationGroup*operation);

typedef void (^RJArraySearchOperationCompletionBlock)(RJArraySearchOperation*operation, NSInteger index, id object);

typedef void (^RJOperationBeginBlock)(RJOperation*operation);
typedef void (^RJOperationCompletionBlock)(RJOperation*operation);
typedef void (^RJOperationMainBlock)(RJOperation*operation);
typedef void (^RJOperationCancelBlock)(RJOperation*operation);
typedef void (^RJOperationErrorBlock)(RJOperation*operation, NSError *error);
typedef void (^RJOperationRetryBlock)(RJOperation*operation, NSError *error);
typedef void (^RJOperationGiveUpBlock)(RJOperation*operation, NSError *error);
typedef void (^RJOperationAbortBlock)(RJOperation*operation, NSError *error);

typedef void (^RJRequestOperationCompletionBlock)(RJRequestOperation*requestOperation, RJRequestCommonData*receivedData, NSError*error);
typedef void (^RJRequestOperationProgressBlock)(RJRequestOperation*requestOperation, RJProgressInfo *progressInfo);

// For string representation see RJSynchronousOperation .h and .m file.

typedef enum {
    RJQueueTypeDefault = -1,
	RJQueueTypeConcurrent = 1,
	RJQueueTypeSerial = 2
} RJQueueType;


typedef enum {
	RJOperationStateQueued,
	RJOperationStateExecuting,
	RJOperationStateFinished,
	RJOperationStateFailed,
	RJOperationStateCancelled,
	RJOperationStateAborted,
	RJOperationStateRetrying
} RJOperationState;



typedef enum {

	RJRequestFormTypeURLEncoded,
	RJRequestFormTypeMultiPart
	
} RJRequestFormType;

