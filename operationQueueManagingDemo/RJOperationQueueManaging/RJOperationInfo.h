//
//  RJOperationInfo.h
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RJOperation.h"
#import "RJOperationDebugging.h"

@interface RJOperationInfo : NSObject <RJOperationDebugging> {
	
	__strong			RJOperation *		_operation;
	__strong			NSString *			_debugLogs;
						BOOL				_isReady;
}

- (id)initWithOperation:(RJOperation *)operation;
- (void)copyAllInfo;

@property (nonatomic, readonly, strong)	RJOperation *operation;
@property (nonatomic, readonly, strong)				NSString *debugLogs;
@property (nonatomic, readonly, assign)				BOOL isReady;

@property (nonatomic, copy)	NSString *stringFormOfOperationState;
@property (nonatomic, copy) NSString *operationQueueKey;
@property (nonatomic, copy) NSString *operationKey;
@property (nonatomic, copy)	NSNumber *operationTag;
@property (nonatomic, copy) NSNumber *secondsTookToComplete;
@property (nonatomic, copy) NSNumber *secondsElapsed;

@end
