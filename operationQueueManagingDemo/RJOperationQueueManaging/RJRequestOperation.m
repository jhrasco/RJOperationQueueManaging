//
//  RJRequestOperation.m
//  myClasses
//
//  Created by Ryan Jake on 11/19/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import "RJRequestOperation.h"
#import "RJRequestConstants.h"

#import "RJOperationQueueManager.h"
#import "RJRequestCategories.h"
#import "RJDebugViewController.h"
#import "RJRequestCommonData.h"
#import "RJOperationQueue.h"

#import "RJRequestOperationInfo.h"

@interface RJRequestOperation ()

- (void)_setupConnection;

- (BOOL)_fileExistsAtPath:(NSString *)directory removeFileIfExists:(BOOL)removeFile;
- (void)_createTempFileInDirectory:(NSString *)directory;
- (NSString *)_tempFileNameDirectory;
- (void)_readdSelfToQueue;

- (id)initWithRequestOperation:(RJRequestOperation *)requestOperation withZone:(NSZone *)zone;

@property (nonatomic, strong)				NSFileHandle *						fileHandle;
@property (nonatomic, readonly, strong)		NSMutableData *						receivedData;

@end

@implementation RJRequestOperation

@synthesize urlConnection =			_urlConnection;
@synthesize data =					_data;
@synthesize receivedData =			_receivedData;
@synthesize requestCompletionBlock= _requestCompletionBlock;
@synthesize progressBlock =			_progressBlock;

@synthesize urlString =				_urlString;
@synthesize parameterString =		_parameterString;
@synthesize pathToFile =			_pathToFile;
@synthesize httpMethod =			_httpMethod;
@synthesize requestFormType =		_requestFormType;
@synthesize timeoutInterval =		_timeoutInterval;
@synthesize writeToFile =			_writeToFile;
@synthesize deleteFileAfterExecution = _deleteFileAfterExecution;
@synthesize cachePolicy =			_cachePolicy;

@synthesize dictionaryParams =		_dictionaryParams;
@synthesize dictionaryHeaders =		_dictionaryHeaders;

@synthesize shouldAbort =			_shouldAbort;

@synthesize fileHandle =			_fileHandle;

+ (BOOL)shouldHandleFinishExecution
{
	return YES;
}

- (void)dealloc
{
	_receivedData = nil;
}

- (Class)operationInfoClass
{
	return [RJRequestOperationInfo class];
}

#pragma mark -
#pragma mark Convenience

+ (id)requestOperation
{
	return [[self alloc] init];
}

+ (id)requestOperationWithOperation:(RJRequestOperation *)requestOperation
{
	return [[self alloc] initWithRequestOperation:requestOperation];
}

#pragma mark -
#pragma mark Init

- (id)init
{
	self = [super init];
	if (self) {

		_timeoutInterval = 15.0f;
		_httpMethod = RJREQUEST_HTTP_METHOD_POST;
		_cachePolicy = NSURLRequestUseProtocolCachePolicy;
		_operationKey = @"";
		_operationTag = 0;
		
		_progressInfo = [[RJProgressInfo alloc] init];
		
	}
	return self;
}

- (id)initWithRequestOperation:(RJRequestOperation *)requestOperation
{
	self = [super initWithOperation:requestOperation];
	if (self) {
		
		// setup default values
		_requestCompletionBlock = requestOperation.requestCompletionBlock;
		_progressBlock = requestOperation.progressBlock;
		
		_urlString = [requestOperation.urlString copy];
		_pathToFile = [requestOperation.pathToFile copy];
		_httpMethod = requestOperation.httpMethod;
		_operationKey = [requestOperation.operationKey copy];
		_operationTag = requestOperation.operationTag;
		_requestFormType = requestOperation.requestFormType;
		_timeoutInterval = requestOperation.timeoutInterval;
		_writeToFile = requestOperation.writeToFile;
		_deleteFileAfterExecution = requestOperation.deleteFileAfterExecution;
		_cachePolicy = requestOperation.cachePolicy;
		_dictionaryParams = requestOperation.dictionaryParams;
		_dictionaryHeaders = requestOperation.dictionaryHeaders;
		_userInfo = requestOperation.userInfo;
		
		_progressInfo = [[RJProgressInfo alloc] init];

		for (id dependency in requestOperation.dependencies) {
			[self addDependency:dependency];
		}

		self.queuePriority = requestOperation.queuePriority;
		
	}
	return self;
}

- (id)initWithRequestOperation:(RJRequestOperation *)requestOperation withZone:(NSZone *)zone // private method for copying only
{
	self = [super initWithOperation:requestOperation];
	if (self) {
		
		// setup default values
		_requestCompletionBlock = requestOperation.requestCompletionBlock;
		_progressBlock = requestOperation.progressBlock;
		
		_urlString = [requestOperation.urlString copyWithZone:zone];
		_pathToFile = [requestOperation.pathToFile copyWithZone:zone];
		_httpMethod = requestOperation.httpMethod;
		_requestFormType = requestOperation.requestFormType;
		_timeoutInterval = requestOperation.timeoutInterval;
		_writeToFile = requestOperation.writeToFile;
		_deleteFileAfterExecution = requestOperation.deleteFileAfterExecution;
		_cachePolicy = requestOperation.cachePolicy;
		_dictionaryParams = requestOperation.dictionaryParams;
		_dictionaryHeaders = requestOperation.dictionaryHeaders;
		_userInfo = requestOperation.userInfo;

		_progressInfo = [[RJProgressInfo alloc] init];

		for (id dependency in requestOperation.dependencies) {
			[self addDependency:dependency];
		}
		
		self.queuePriority = requestOperation.queuePriority;

	}
	return self;

}

#pragma mark - 
#pragma mark Set Param and Header

- (void)setParameter:(id)parameter forValue:(NSString *)value
{
	[self.dictionaryParams setObject:parameter forKey:value];
}

- (void)setHeader:(id)parameter forValue:(NSString *)value
{
	[self.dictionaryHeaders setObject:parameter forKey:value];
}

#pragma mark -
#pragma mark Block Getters and Setters

- (void)setRequestCompletionBlock:(void (^)(RJRequestOperation*requestOperation, RJRequestCommonData*receivedData, NSError*error))requestCompletionBlock
{
	_requestCompletionBlock = requestCompletionBlock;
}

- (void)setProgressBlock:(void(^)(RJRequestOperation*requestOperation, RJProgressInfo *progressInfo))progressBlock
{
	_progressBlock = progressBlock;
}

#pragma mark - 
#pragma mark Getter

- (NSString *)parameterString
{
	return _parameterString;
}

- (NSMutableDictionary *)dictionaryParams
{
	if (!_dictionaryParams) {
		_dictionaryParams = [[NSMutableDictionary alloc] initWithCapacity:2];
	}
	return _dictionaryParams;
}

- (NSMutableDictionary *)dictionaryHeaders
{
	if (!_dictionaryHeaders) {
		_dictionaryHeaders = [[NSMutableDictionary alloc] initWithCapacity:2];
	}
	return _dictionaryHeaders;
}

- (RJRequestCommonData *)data
{
	if (_data == nil) {
		_data = [[RJRequestCommonData alloc] initWithData:self.receivedData];
	}
	return _data;
}

#pragma mark -
#pragma mark Operation

- (void)cancel
{
	[self.urlConnection cancel];
		
	[self cancelExecution];
	
	[super cancel];
}

- (void)beginExecution
{
	[super beginExecution];
	
	if (self.shouldAbort == YES) {
		_isCancelled = YES;
	}
	else {
		[self _setupConnection];
	}

}

- (void)finishExecution
{
	[super finishExecution];

	if (self.deleteFileAfterExecution && self.writeToFile && [self.pathToFile length]) {
		NSError *error;
		NSString *tempFileNameDirectory = [self _tempFileNameDirectory];
		if (tempFileNameDirectory) {
			if (![[NSFileManager defaultManager] removeItemAtPath:[self _tempFileNameDirectory] error:&error]) {
				RJLOGINFO1(@"There was an error deleting the file at path %@\n error :\n", [self _tempFileNameDirectory], error);
			}
		}
	}
	
	_requestCompletionBlock = nil;
	_progressBlock = nil;
	_operationDelegate = nil;
	
}

- (void)cancelExecution
{
	[super cancelExecution];
	
	if (self.deleteFileAfterExecution && self.writeToFile && [self.pathToFile length]) {
		NSError *error;
		NSString *tempFileNameDirectory = [self _tempFileNameDirectory];
		if (tempFileNameDirectory) {
			if (![[NSFileManager defaultManager] removeItemAtPath:[self _tempFileNameDirectory] error:&error]) {
				RJLOGINFO1(@"There was an error deleting the file at path %@\n error :\n", [self _tempFileNameDirectory], error);
			}
		}
	}
	
	_requestCompletionBlock = nil;
	_progressBlock = nil;
	_operationDelegate = nil;

}

- (void)retryExecution
{
	[super retryExecution];

	if (self.shouldAbort == YES) {
		_isCancelled = YES;
	}
	else {
		[self _setupConnection];
	}

}

// TODO : Add support for multipart
// TODO : Test support for DELETE http method
- (void)_setupConnection
{

	NSString *urlString = self.urlString;
	
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
	[urlRequest setTimeoutInterval:self.timeoutInterval];
	[urlRequest setHTTPMethod:self.httpMethod];
	[urlRequest setCachePolicy:self.cachePolicy];

	[self.dictionaryHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[urlRequest setValue:obj forHTTPHeaderField:key];
	}];

	NSString *params = [self.dictionaryParams urlQueryStringWithDictionary];

	NSString *httpMethod = [self.httpMethod uppercaseString];
	
	if ([httpMethod isEqualToString:RJREQUEST_HTTP_METHOD_POST]) {
		
		if (self.requestFormType == RJRequestFormTypeURLEncoded) {
			NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
			NSString *postLength = [NSString stringWithFormat:@"%d",(int)[postData length]];
			
			[urlRequest setURL:[NSURL URLWithString:urlString]];
			[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
			[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
			[urlRequest setHTTPBody:postData];
		}
		else if (self.requestFormType == RJRequestFormTypeMultiPart) {
		
			NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", MULTI_PART_BOUNDARY];
			[urlRequest setURL:[NSURL URLWithString:urlString]];
			[urlRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
			[urlRequest setHTTPBody:[self _generateFormDataFromPostDictionary:self.dictionaryParams]];
		}
		

	}
	else if ([httpMethod isEqualToString:RJREQUEST_HTTP_METHOD_PUT]) {

		NSData *postData = [params dataUsingEncoding:NSUTF8StringEncoding];
		NSString *postLength = [NSString stringWithFormat:@"%d",(int)[postData length]];
		
		[urlRequest setURL:[NSURL URLWithString:urlString]];
		[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[urlRequest setHTTPBody:postData];

	}
	else if ([httpMethod isEqualToString:RJREQUEST_HTTP_METHOD_GET]) {
		
		NSString *urlStringWithParams = nil;
		
		if ([urlString rangeOfString:@"?"].location != NSNotFound) {
			urlStringWithParams = [NSString stringWithFormat:@"%@&%@",urlString,params];
		}
		else {
			urlStringWithParams = [NSString stringWithFormat:@"%@?%@",urlString,params];
		}
		
		[urlRequest setURL:[NSURL URLWithString:urlStringWithParams]];
		
	}
	else if ([httpMethod isEqualToString:RJREQUEST_HTTP_METHOD_DELETE]) {
		
		NSString *urlStringWithParams = nil;
		
		if ([urlString rangeOfString:@"?"].location != NSNotFound) {
			urlStringWithParams = [NSString stringWithFormat:@"%@&%@",urlString,params];
		}
		else {
			urlStringWithParams = [NSString stringWithFormat:@"%@?%@",urlString,params];
		}
		
		[urlRequest setURL:[NSURL URLWithString:urlStringWithParams]];
		
	}

	[self.progressInfo clear];

	_parameterString = params;
	
	if ([self.operationDelegate respondsToSelector:@selector(requestOperationWillStart:urlRequest:parameterString:)]) {
		[self.operationDelegate requestOperationWillStart:self urlRequest:urlRequest parameterString:params];
	}
	RJ_POST_NOTIFICATION(RJREQUEST_WILL_START, nil, [self userInfoWrap]);

	_urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:NO];
	[_urlConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[_urlConnection start];
	
}

#pragma mark -
#pragma mark RJOperationDelegate

- (void)operationWillBeginExecution:(RJOperation *)operation
{

}

- (void)operationWillFinishExecution:(RJOperation *)operation
{

}

- (void)operationWillCancelExecution:(RJOperation *)operation
{

}

- (void)operationMain:(RJOperation *)operation
{
	
}

#pragma mark -
#pragma mark RJSynchronousOperationDelegate

- (void)operationWillRetry:(RJSynchronousOperation *)operation
{

}

- (void)requestOperationDidFinish:(RJRequestOperation *)requestOperation withReceivedData:(RJRequestCommonData *)data
{
	
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (_receivedData == nil) {
		_receivedData = [[NSMutableData alloc] init];
	}
	
	self.progressInfo.expectedTotalBytes = [response expectedContentLength];
	
	if (self.writeToFile == YES  && [self.pathToFile length] > 0) {
		NSString *tempFileNameDirectory = [self _tempFileNameDirectory];
		[self _fileExistsAtPath:tempFileNameDirectory removeFileIfExists:YES]; // TODO: Increment instead of overwriting the file.
		[self _createTempFileInDirectory:tempFileNameDirectory];
		self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tempFileNameDirectory];
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.progressInfo incrementTotalBytesWritten:[data length]];
	
	if (self.writeToFile == YES && [self.pathToFile length] > 0) {
		[self.fileHandle seekToEndOfFile];
		[self.fileHandle writeData:data];
	}
	else {
		[self.receivedData appendData:data];
	}
	
	RJ_BLOCK_DISPATCH(self.progressBlock, self, self.progressInfo);
	RJ_POST_NOTIFICATION(RJREQUEST_DID_PROGRESS, nil, [self userInfoWrap]);
	
	NSInteger secondsInInteger = (int)[self secondsElapsed];

#define DOWNLOAD_RATE_UPDATE_INTERVAL (2)
	
	if (secondsInInteger % DOWNLOAD_RATE_UPDATE_INTERVAL == 0 && self.progressInfo.lastSecond != secondsInInteger) {

		self.progressInfo.lastSecond = secondsInInteger;

		[self.progressInfo updateRate:DOWNLOAD_RATE_UPDATE_INTERVAL];
	}
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.fileHandle closeFile];

	if (self.isCancelled) {
		return;
	}

	RJRequestCommonData *commonData = nil;
	
	if (self.writeToFile == YES && [self.pathToFile length] > 0) {
		commonData = [[RJRequestCommonData alloc] initWithPath:[self _tempFileNameDirectory]];
	}
	else {
		commonData = [[RJRequestCommonData alloc] initWithData:[NSData dataWithData:self.receivedData]];
	}

	_data = commonData;

	[self.operationDelegate requestOperationDidFinish:self withReceivedData:commonData];
	RJ_BLOCK_DISPATCH(self.requestCompletionBlock, self, commonData, nil);
	RJ_POST_NOTIFICATION(RJREQUEST_DID_FINISH, nil, [self userInfoWrap]);

	if (_isFlagAsFailed == NO) {
		_receivedData = nil;
		[self finishExecution];
		self.requestCompletionBlock = nil;
		self.progressBlock = nil;
	}
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self flagAsFailedWithError:error];
	
	[self _fileExistsAtPath:[self _tempFileNameDirectory] removeFileIfExists:YES];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([self.operationDelegate respondsToSelector:@selector(requestDidReceiveAuthenticationChallenge:withConnection:withChallenge:)]) {
		[self.operationDelegate requestDidReceiveAuthenticationChallenge:self withConnection:connection withChallenge:challenge];
	}
}

#pragma mark -
#pragma Utility

- (BOOL)_fileExistsAtPath:(NSString *)directory removeFileIfExists:(BOOL)removeFile
{
	if ([directory length] == 0) {
		return NO;
	}
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:directory];
	
	if (fileExists) {
		if (removeFile) {
			NSError *error;
			if (![[NSFileManager defaultManager] removeItemAtPath:directory error:&error]) {
				RJLOGINFO1(@"%@", error);
			}
		}
	}
	return fileExists;
}

- (void)_createTempFileInDirectory:(NSString *)directory
{
	[[NSFileManager defaultManager] createFileAtPath:directory
											contents:nil
										  attributes:nil];
}

- (NSString *)_tempFileNameDirectory
{
	if ([self.pathToFile length] == 0) {
		return nil;
	}
	
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:self.pathToFile];
}
// code obtained from https://gist.github.com/igaiga/1354221 // code still not tested, and not working yet.
- (NSData*)_generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	
    for (int i = 0; i < [keys count]; i++) {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", MULTI_PART_BOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) {
			// handle image data
			NSString *formstring = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n", [keys objectAtIndex:i]];
			[result appendData: [formstring dataUsingEncoding:NSUTF8StringEncoding]];
			[result appendData:value];
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:[formstring dataUsingEncoding:NSUTF8StringEncoding]];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", MULTI_PART_BOUNDARY];
    [result appendData:[formstring dataUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

- (void)_readdSelfToQueue
{
	RJOperationQueue *operationQueue = self.operationQueue;

	[[RJOperationQueueManager operationQueueManager] addOperation:[self copy]
													 withQueueKey:operationQueue.operationQueueKey
													withQueueType:operationQueue.queueType];
}

#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	RJRequestOperation *requestOperation = [[RJRequestOperation alloc] initWithRequestOperation:self withZone:zone];
	
	return requestOperation;
	
}

#pragma mark -
#pragma mark Debug methods

- (NSString *)debugDescription
{
	return [super debugDescription];
}

- (NSString *)description
{
	return [super description];
}

@end

@interface RJProgressInfo ()

@property (nonatomic, assign) long long buffer;

@end

@implementation RJProgressInfo

@synthesize expectedTotalBytes = _expectedTotalBytes;
@synthesize totalBytesWritten = _totalBytesWritten;
@synthesize lastSecond = _lastSecond;
@synthesize rate = _rate;

- (id)init
{
	self = [super init];
	if (self) {
		
		self.lastSecond = -1;
		
	}
	return self;
}

- (id)initWithProgressInfo:(RJProgressInfo *)progressInfo
{
	self = [super init];
	if (self) {

		self.expectedTotalBytes = progressInfo.expectedTotalBytes;
		self.totalBytesWritten = progressInfo.totalBytesWritten;
		self.rate = progressInfo.rate;
		
		self.lastSecond = -1;
		
	}
	return self;
}


- (void)updateRate:(NSTimeInterval)timeInterval
{
	self.rate = (CGFloat)((self.buffer / 1024.0f) / timeInterval);
	
	self.buffer = 0;
}

- (void)incrementTotalBytesWritten:(long long)totalBytesWritten
{
	_totalBytesWritten += totalBytesWritten;
	
	_buffer += totalBytesWritten;
}

- (float)percentDownloadProgress
{
	if (self.expectedTotalBytes < 0) {
		return 1.0f;
	}
	if (self.totalBytesWritten == 0) {
		return 0.0f;
	}
	
	return (CGFloat)((double)self.totalBytesWritten / (double)self.expectedTotalBytes);
}

- (void)clear
{
	_totalBytesWritten = 0;
	_expectedTotalBytes = 0;
	_buffer = 0;
}

- (id)copyWithZone:(NSZone *)zone
{
	RJProgressInfo *progressInfo = [[RJProgressInfo alloc] initWithProgressInfo:self];
	
	return progressInfo;
}

@end

