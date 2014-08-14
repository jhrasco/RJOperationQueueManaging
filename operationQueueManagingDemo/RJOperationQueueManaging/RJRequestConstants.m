//
//  RJRequest.m
//  myClasses
//
//  Created by Ryan Jake on 11/22/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import "RJRequestConstants.h"

NSString *const RJREQUEST_DEFAULT_QUEUE =					@"RJREQUEST_DEFAULT_QUEUE";

NSString *const RJOPERATION_DEFAULT_CONCURRENT_QUEUE =		@"RJOPERATION_DEFAULT_CONCURRENT_QUEUE";
NSString *const RJOPERATION_DEFAULT_SERIAL_QUEUE =			@"RJOPERATION_DEFAULT_SERIAL_QUEUE";

NSString *const RJOPERATION_DID_BEGIN_EXECUTING =			@"RJOPERATION_DID_BEGIN_EXECUTING";
NSString *const RJOPERATION_DID_FINISH_EXECUTING =			@"RJOPERATION_DID_FINISH_EXECUTING";
NSString *const RJOPERATION_DID_CANCEL_EXECUTING =			@"RJOPERATION_DID_CANCEL_EXECUTING";
NSString *const RJOPERATION_DID_ABORT_EXECUTING =			@"RJOPERATION_DID_ABORT_EXECUTING";

NSString *const RJOPERATION_DID_ERROR =						@"RJOPERATION_DID_ERROR";
NSString *const RJOPERATION_WILL_RETRY =					@"RJOPERATION_WILL_RETRY";
NSString *const RJOPERATION_DID_GIVE_UP =					@"RJOPERATION_DID_GIVE_UP";

NSString *const RJREQUEST_HTTP_METHOD_POST =				@"POST";
NSString *const RJREQUEST_HTTP_METHOD_GET =					@"GET";
NSString *const RJREQUEST_HTTP_METHOD_PUT =					@"PUT";
NSString *const RJREQUEST_HTTP_METHOD_DELETE =				@"DELETE";

NSInteger const RJREQUEST_DEFAULT_NUMBER_OF_RETRIES =		3;
NSString *const RJREQUEST_USER_INFO_KEY =					@"RJREQUEST_USER_INFO_KEY";

NSString *const RJREQUEST_OPERATION_WAS_ADDED_TO_QUEUE =	@"RJREQUEST_OPERATION_WAS_ADDED_TO_QUEUE";

NSString *const RJREQUEST_WILL_START =						@"RJREQUEST_WILL_START";
NSString *const RJREQUEST_DID_FINISH =						@"RJREQUEST_DID_FINISH";
NSString *const RJREQUEST_DID_PROGRESS =					@"RJREQUEST_DID_PROGRESS";

@implementation RJRequestConstants

@end

void XLog (NSString *format, ...)
{
	va_list argList;
	va_start (argList, format);
	NSString *message = [[NSString alloc] initWithFormat: format
											   arguments: argList];
	printf ("%s\n", [message UTF8String]);
	va_end  (argList);

}


