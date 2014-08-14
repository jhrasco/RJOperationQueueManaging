//
//  RJRequestOperationDelegate.h
//  myClasses
//
//  Created by Ryan Jake on 12/16/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RJRequestOperation;

@protocol RJRequestOperationDelegate <NSObject>

@required

- (void)requestOperationDidFinish:(RJRequestOperation *)requestOperation withReceivedData:(RJRequestCommonData *)data;

@optional

- (void)requestOperationWillStart:(RJRequestOperation *)requestOperation urlRequest:(NSMutableURLRequest *)urlRequest parameterString:(NSString *)parameterString;
- (void)requestDidReceiveAuthenticationChallenge:(RJRequestOperation *)requestOperation withConnection:(NSURLConnection *)connection withChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
