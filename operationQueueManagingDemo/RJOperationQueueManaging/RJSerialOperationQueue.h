//
//  RJSerialOperationQueue.h
//  myClasses
//
//  Created by Ryan Jake on 6/12/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJOperationQueue.h"

@interface RJSerialOperationQueue : RJOperationQueue

@end

/* Reason for implementing serial queue as per the Apple Documentation notes:
 
 ---------------------------------------------------------------------
 For a queue whose maximum number of concurrent operations is set to 1,
 this equates to a serial queue. However, you should NEVER RELY ON THE
 SERIAL EXECUTION OF OPERATION OBJECTS. Changes in the readiness of an
 operation can change the resulting execution order.
 ---------------------------------------------------------------------
 
 RJSerialOperationQueue attempts to solve this problem by using dependencies.
 This class will remove all dependencies which are added on the operations added.
 This does not exempt dependencies even from other queues.
 It wouldn't make sense anyway to have two dependent operations running on different queues.
 Instead, you should run those two operations on a serial queue, and add them in the appropriate order.
 
 */

