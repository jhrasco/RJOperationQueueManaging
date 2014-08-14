//
//  RJRequestOperationInfo.h
//  myClasses
//
//  Created by Ryan Jake on 6/21/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationInfo.h"

#import "RJRequestOperation.h"
#import "RJOperationDebugging.h"

@interface RJRequestOperationInfo : RJOperationInfo <RJRequestOperationDebugging>

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, copy) NSNumber *currentNumberOfRetries;
@property (nonatomic, copy) NSNumber *maxNumberOfRetries;
@property (nonatomic, copy) RJProgressInfo *progressInfo;

@end
