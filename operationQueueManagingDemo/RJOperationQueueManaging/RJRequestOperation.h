//
//  RJRequestOperation.h
//  myClasses
//
//  Created by Ryan Jake on 11/19/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJSynchronousOperation.h"
#import "RJRequestTypes.h"
#import "RJRequestOperationDelegate.h"

/*
 
 TODO : Implement this:
 
 moveToEndOfQueueWhenRetrying

 */

@class RJMutableRequestOperation;
@class RJRequestQueueManager;
@class RJDebugViewController;
@class RJRequestOperationExpandedViewController;
@class RJDebugViewController;
@class RJRequestCommonData;
@class RJProgressInfo;

#define MULTI_PART_BOUNDARY @"---------9348765387653874658734658"

@interface RJRequestOperation : RJSynchronousOperation <NSURLConnectionDataDelegate, NSCopying, RJRequestOperationDelegate> {
	
	NSURLConnection *										_urlConnection;
	RJRequestCommonData *									_data;
	NSMutableData *											_receivedData;
	RJRequestOperationCompletionBlock						_requestCompletionBlock;
	RJRequestOperationProgressBlock							_progressBlock;
	NSString *				_requestQueueKey;
	NSString *				_urlString;
	NSString *				_pathToFile;
	NSString *				_httpMethod;
	NSString *				_requestKey;
	NSInteger				_requestTag;
	RJRequestFormType		_requestFormType;
	NSTimeInterval			_timeoutInterval;
	BOOL					_writeToFile;
	BOOL					_deleteFileAfterExecution;
	NSURLRequestCachePolicy	_cachePolicy;
	NSMutableDictionary *	_dictionaryParams;
	NSMutableDictionary *	_dictionaryHeaders;
	BOOL					_shouldAbort;
}

+ (id)requestOperation;
+ (id)requestOperationWithOperation:(RJRequestOperation *)requestOperation;

- (id)initWithRequestOperation:(RJRequestOperation *)requestOperation;

- (void)setParameter:(id)parameter forValue:(NSString *)value;
- (void)setHeader:(id)parameter forValue:(NSString *)value;

- (void)setRequestCompletionBlock:(void (^)(RJRequestOperation*requestOperation, RJRequestCommonData*receivedData, NSError*error))requestCompletionBlock;
- (void)setProgressBlock:(void(^)(RJRequestOperation*requestOperation, RJProgressInfo *progressInfo))progressBlock;

@property (nonatomic, readonly, strong)		NSURLConnection *					urlConnection;
@property (nonatomic, readonly, strong)		RJRequestCommonData *				data;
@property (nonatomic, readonly, strong)		RJRequestOperationCompletionBlock 	requestCompletionBlock;
@property (nonatomic, readonly, strong)		RJRequestOperationProgressBlock 	progressBlock;
@property (nonatomic, readonly, strong)		RJProgressInfo *					progressInfo;

@property (nonatomic, readwrite, strong)	NSString *				urlString;
@property (nonatomic, readonly, strong)		NSString *				parameterString;
@property (nonatomic, readwrite, strong)	NSString *				pathToFile;
@property (nonatomic, readwrite, strong)	NSString *				httpMethod;
@property (nonatomic, readwrite, assign)	RJRequestFormType		requestFormType;
@property (nonatomic, readwrite, assign)	NSTimeInterval			timeoutInterval;

@property (nonatomic, readwrite, assign)	BOOL					writeToFile;
@property (nonatomic, readwrite, assign)	BOOL					deleteFileAfterExecution;
@property (nonatomic, readwrite, assign)	NSURLCacheStoragePolicy	cachePolicy;

@property (nonatomic, readwrite, strong)	NSMutableDictionary *	dictionaryParams;
@property (nonatomic, readwrite, strong)	NSMutableDictionary *	dictionaryHeaders;

@property (nonatomic, readwrite, assign)	BOOL					shouldAbort;

@end


@interface RJProgressInfo : NSObject <NSCopying>

- (id)initWithProgressInfo:(RJProgressInfo *)progressInfo;
- (void)updateRate:(NSTimeInterval)timeInterval;
- (void)incrementTotalBytesWritten:(long long)totalBytesWritten;
- (float)percentDownloadProgress;
- (void)clear;

@property (nonatomic, assign) long long			expectedTotalBytes;
@property (nonatomic, assign) long long			totalBytesWritten;
@property (nonatomic, assign) NSInteger			lastSecond;
@property (nonatomic, assign) float				rate;

@end