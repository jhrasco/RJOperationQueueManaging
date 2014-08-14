//
//  RJOperationGroupProtocol.h
//  myClasses
//
//  Created by Ryan Jake on 7/1/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RJOperationQueueManaging.h"

@protocol RJOperationHandling <NSObject>

@optional
- (void)runOperationGroupWithOperationQueueKey:(NSString *)operationQueueKey withQueueType:(RJQueueType)queueType;
- (RJOperation *)lastOperationInGroup;

- (void)setOperationQueueKey:(NSString *)operationQueueKey;
- (void)setOperationQueueType:(NSString *)operationQueueType;

- (NSString *)operationQueueKey;
- (RJQueueType)queueType;

@required
- (void)runOperationGroup;
- (void)updateUserInterface;

- (NSString *)defaultOperationQueueKey;
- (RJQueueType)defaultOperationQueueType;

@end
