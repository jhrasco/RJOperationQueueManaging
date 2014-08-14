//
//  RJViewTypeDataSource.h
//  myClasses
//
//  Created by Ryan Jake on 6/18/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJOperationQueueManager.h"

typedef enum{
	RJDebugViewTypeAllOperations,
	RJDebugViewTypeViewByOperationQueue,
	RJDebugViewTypeGroupByOperationQueue,
} RJDebugViewType;


@interface RJDebugViewTypeInfo : NSObject

- (id)initWithDebugViewType:(RJDebugViewType)debugViewType;

@property (nonatomic, readwrite, strong)	NSString *title;
@property (nonatomic, readonly, assign)		RJDebugViewType debugViewType;

@end
