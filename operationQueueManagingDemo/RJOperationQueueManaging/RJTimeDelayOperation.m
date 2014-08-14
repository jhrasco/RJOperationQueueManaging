//
//  RJTimeDelayOperation.m
//  LO2
//
//  Created by Ryan Jake on 7/29/13.
//
//

#import "RJTimeDelayOperation.h"

@implementation RJTimeDelayOperation

+ (BOOL)shouldHandleFinishExecution
{
	return YES;
}

- (id)initWithTimeInterval:(NSTimeInterval)timeInterval
{
	if (self = [super init]) {
		_timeInterval = timeInterval;
	}
	return self;
}

- (void)beginExecution
{
	[super beginExecution];
	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.timeInterval * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self finishExecution];
	});

}


@end
