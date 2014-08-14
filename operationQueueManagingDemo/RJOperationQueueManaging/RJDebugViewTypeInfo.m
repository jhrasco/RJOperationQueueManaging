//
//  RJViewTypeDataSource.m
//  myClasses
//
//  Created by Ryan Jake on 6/18/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJDebugViewTypeInfo.h"

@implementation RJDebugViewTypeInfo

@synthesize title =			_title;
@synthesize debugViewType = _debugViewType;

- (id)initWithDebugViewType:(RJDebugViewType)debugViewType
{
	self = [super init];
	if (self) {
		_debugViewType = debugViewType;
	}
	return self;
}

@end
