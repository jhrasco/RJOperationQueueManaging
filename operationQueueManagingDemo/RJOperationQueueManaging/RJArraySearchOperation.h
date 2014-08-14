//
//  RJArraySearchOperation.h
//  myClasses
//
//  Created by Ryan Jake on 6/23/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJAsynchronousOperation.h"
#import "RJOperation.h"

@interface RJArraySearchOperation : NSObject

@property (nonatomic, readonly, strong) NSArray *array;

- (id)initWithArray:(NSArray *)array;
- (void)setArraySearchCompletionBlock:(void (^)(RJArraySearchOperation*operation, NSInteger index, id object))arraySearchCompletionBlock;
- (void)searchObject:(id)object inOperationQueueWithKey:(NSString *)operationQueueKey;

@property (nonatomic, readonly, strong) RJArraySearchOperationCompletionBlock arraySearchCompletionBlock;

@end

@interface RJInternalArraySearchOperation : RJAsynchronousOperation

@property (nonatomic, unsafe_unretained) NSArray *array;
@property (nonatomic, unsafe_unretained) id object;
@property (nonatomic, assign) NSInteger lowerBound;
@property (nonatomic, assign) NSInteger upperBound;
@property (nonatomic, assign) NSInteger objectIndex;

@end