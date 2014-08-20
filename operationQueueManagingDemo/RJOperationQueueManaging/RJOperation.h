//
//  RJOperation.h
//  myClasses
//
//  Created by Ryan Jake on 5/13/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RJRequestTypes.h"

@class RJOperation;
@class RJOperationInfo;
@class RJOperationQueue;
@class RJOperationGroup;

@protocol RJOperationProtocol <NSObject>

@required
- (void)operationWillFinishExecution:(RJOperation *)operation;

@optional
- (void)operationWillBeginExecution:(RJOperation *)operation;
- (void)operationWillCancelExecution:(RJOperation *)operation;
- (void)operationMain:(RJOperation *)operation;

@end

@protocol RJOperationErrorHandling <NSObject>

@optional
- (void)operationDidEncounterError:(RJOperation *)operation withError:(NSError *)error;
- (void)operationDidAbort:(RJOperation *)operation withError:(NSError *)error;

@end

@protocol RJOperationRetryHandling <NSObject>

@optional
- (void)operationWillRetry:(RJOperation *)operation;
- (BOOL)operationShouldRetry:(RJOperation *)operation;
- (void)operationDidGiveUp:(RJOperation *)operation;

@end


@interface RJOperation : NSOperation {

	__unsafe_unretained				id							_operationDelegate;
	__unsafe_unretained RJOperationQueue *						_operationQueue;
	__unsafe_unretained RJOperationGroup *						_operationGroup;
	RJOperationBeginBlock							_operationBeginBlock;
	RJOperationCompletionBlock						_operationCompletionBlock;
	RJOperationMainBlock							_operationMainBlock;
	RJOperationCancelBlock							_operationCancelBlock;
	RJOperationErrorBlock							_operationErrorBlock;
	RJOperationRetryBlock							_operationRetryBlock;
	RJOperationGiveUpBlock							_operationGiveUpBlock;
	RJOperationAbortBlock							_operationAbortBlock;
	RJOperationState								_operationState;
	NSInteger										_operationTag;
	NSString *										_operationKey;
	NSDate *										_timeStarted;
	RJOperationInfo *								_operationInfo;
	NSDictionary *									_userInfo;
	NSDictionary *									_userInfoWrap;
	NSError *										_error;
}

- (id)initWithOperation:(RJOperation *)operation;

- (void)abort;
- (void)abortWithError:(NSError *)error;

- (NSString *)stringFormOfOperationState;
- (RJOperation *)operationDependencyWithOperationTag:(NSUInteger)operationTag;
- (RJOperation *)operationDependencyWithOperationKey:(NSString *)operationKey;

- (NSTimeInterval)secondsElapsed;

- (void)setOperationBeginBlock:(void (^)(RJOperation*operation))operationBeginBlock;
- (void)setOperationCompletionBlock:(void (^)(RJOperation*operation))operationCompletionBlock;
- (void)setOperationMainBlock:(void (^)(RJOperation*operation))operationMainBlock;
- (void)setOperationErrorBlock:(void (^)(RJOperation*operation, NSError *error))operationErrorBlock;
- (void)setOperationCancelBlock:(void (^)(RJOperation*operation))operationCancelBlock;
- (void)setOperationRetryBlock:(void (^)(RJOperation*operation, NSError *error))operationRetryBlock;
- (void)setOperationGiveUpBlock:(void (^)(RJOperation*operation, NSError *error))operationGiveUpBlock;
- (void)setOperationAbortBlock:(void (^)(RJOperation*operation, NSError *error))operationAbortBlock;

- (NSString *)operationQueueKey;
- (Class)operationInfoClass;
+ (NSDictionary *)operationStateLookUpTable;

@property (nonatomic, __unsafe_unretained)					id							operationDelegate;
@property (nonatomic, __unsafe_unretained)					RJOperationQueue *			operationQueue;
@property (nonatomic, __unsafe_unretained)					RJOperationGroup *			operationGroup;
@property (nonatomic, readonly, copy)		RJOperationBeginBlock		operationBeginBlock;
@property (nonatomic, readonly, copy)		RJOperationCompletionBlock	operationCompletionBlock;
@property (nonatomic, readonly, copy)		RJOperationMainBlock		operationMainBlock;
@property (nonatomic, readonly, copy)		RJOperationCancelBlock		operationCancelBlock;
@property (nonatomic, readonly, copy)		RJOperationErrorBlock		operationErrorBlock;
@property (nonatomic, readonly, copy)		RJOperationRetryBlock		operationRetryBlock;
@property (nonatomic, readonly, copy)		RJOperationGiveUpBlock		operationGiveUpBlock;
@property (nonatomic, readonly, copy)		RJOperationAbortBlock		operationAbortBlock;
@property (nonatomic, assign)				RJOperationState			operationState;
@property (nonatomic, assign)				NSInteger					operationTag;
@property (nonatomic, strong)				NSString *					operationKey;
@property (nonatomic, readonly, strong)		NSDate *					timeStarted;
@property (nonatomic, readonly, strong)		RJOperationInfo *			operationInfo;
@property (nonatomic, strong)				NSDictionary *				userInfo;
@property (nonatomic, strong)				NSDictionary *				userInfoWrap;
@property (nonatomic, readonly, copy)		NSError *error;

@property (nonatomic, assign)				BOOL						shouldAbortOperation;
@property (nonatomic, assign)				BOOL						shouldAbortRemainingOperationsOnGroupOnFail;

@end
