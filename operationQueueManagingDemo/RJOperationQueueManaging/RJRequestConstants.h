//
//  RJRequest.h
//  myClasses
//
//  Created by Ryan Jake on 11/22/12.
//  Copyright (c) 2012 Ryan Jake. All rights reserved.
//

#import <Foundation/Foundation.h>

// DEBUG SWITCHES

//#define ENABLE_DEBUG_DISPLAY
//#define ENABLE_RJLOGINFO1
//#define ENABLE_TRY_CATCH_DEBUG

#define ENABLE_BLOCKS
#define ENABLE_NOTIFICATIONS

// QUEUE KEYS

extern NSString *const RJREQUEST_DEFAULT_QUEUE;
extern NSString *const RJOPERATION_DEFAULT_CONCURRENT_QUEUE;
extern NSString *const RJOPERATION_DEFAULT_SERIAL_QUEUE;

// HTTP methods

extern NSString *const RJREQUEST_HTTP_METHOD_POST;
extern NSString *const RJREQUEST_HTTP_METHOD_GET;
extern NSString *const RJREQUEST_HTTP_METHOD_PUT;
extern NSString *const RJREQUEST_HTTP_METHOD_DELETE;

// OTHER Constants


extern NSInteger const RJREQUEST_DEFAULT_NUMBER_OF_RETRIES;

#define COMPLETION_NOT_RETRY (NO)
#define COMPLETION_IS_RETRY  (YES)

// Notifications

extern NSString *const RJREQUEST_USER_INFO_KEY;

extern NSString *const RJREQUEST_OPERATION_WAS_ADDED_TO_QUEUE;

extern NSString *const RJOPERATION_DID_BEGIN_EXECUTING;
extern NSString *const RJOPERATION_DID_FINISH_EXECUTING;
extern NSString *const RJOPERATION_DID_CANCEL_EXECUTING;
extern NSString *const RJOPERATION_DID_ABORT_EXECUTING;

extern NSString *const RJOPERATION_DID_ERROR;
extern NSString *const RJOPERATION_WILL_RETRY;
extern NSString *const RJOPERATION_DID_GIVE_UP;

extern NSString *const RJREQUEST_WILL_START;
extern NSString *const RJREQUEST_DID_FINISH;
extern NSString *const RJREQUEST_DID_PROGRESS;

@interface RJRequestConstants : NSObject

@end

#ifdef ENABLE_BLOCKS
#define RJ_BLOCK_DISPATCH(__dispatch_block__, ...) if(__dispatch_block__ != nil) __dispatch_block__(__VA_ARGS__);
#else
#define RJ_BLOCK_DISPATCH(__dispatch_block__, ...) {}
#endif

#ifdef ENABLE_NOTIFICATIONS
#define RJ_POST_NOTIFICATION(__notification_name__, __object__, __user_info__) [[NSNotificationCenter defaultCenter] postNotificationName:__notification_name__ object:__object__ userInfo:__user_info__]
#else
#define RJ_POST_NOTIFICATION(__notification_name__, __object__, __user_info__) {}
#endif


// Use RJLOGINFO for logging the current class and current method.
#define RJLOGINFO() XLog(@"\n%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))

// Use RJLOGINFO1 for logging the current class, current method and parameter passed.
#define RJLOGINFO1(...) RJLOGINFO(); XLog(__VA_ARGS__)


// Use QLog to get rid of the garbage that NSLog outputs.
void XLog (NSString *format, ...);

static inline void dispatch_sync_to_main_thread(dispatch_block_t block) {
	
	if ([NSThread isMainThread]) {
		block();
	}
	else {
		dispatch_sync(dispatch_get_main_queue(), block);
	}
	
}
