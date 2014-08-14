//
//  RJAsynchronousOperation.h
//  myClasses
//
//  Created by Ryan Jake on 5/13/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJOperation.h"

@interface RJAsynchronousOperation : RJOperation <RJOperationProtocol, RJOperationErrorHandling>

- (id)initWithAsynchronousOperation:(RJAsynchronousOperation *)asynchronousOperation;

@end
