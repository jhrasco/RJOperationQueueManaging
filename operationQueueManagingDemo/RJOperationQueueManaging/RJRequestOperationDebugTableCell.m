//
//  RJRequestOperatioDebugTableCell.m
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import "RJRequestOperationDebugTableCell.h"

#import "RJOperationDebugging.h"

@implementation RJRequestOperationDebugTableCell

@synthesize urlLabel = _urlLabel;
@synthesize httpMethodLabel = _httpMethodLabel;
@synthesize percentLabel = _percentLabel;
@synthesize attemptsLabel = _attemptsLabel;
@synthesize totalExpectedAndWrittenBytes = _totalExpectedAndWrittenBytes;
@synthesize progressView = _progressView;
@synthesize downloadRateLabel = _downloadRateLabel;

+ (CGFloat)cellHeight
{
	return 120.0f;
}

+ (NSString *)cellID
{
	return @"cellID_RJRequestOperatioDebugTableCell";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)updateCell:(id)operationDebugging
{
	[super updateCell:operationDebugging];

	id <RJRequestOperationDebugging> debuggable = operationDebugging;
	
	self.urlLabel.text = [debuggable debugURLString];
	self.httpMethodLabel.text = [debuggable debugHTTPMethod];
	
	self.percentLabel.text = [NSString stringWithFormat:@"%d%%",(int)(debuggable.debugProgressInfo.percentDownloadProgress * 100)];
	self.attemptsLabel.text = [NSString stringWithFormat:@"%d / %d", [debuggable debugCurrentNumberOfRetries], [debuggable debugMaxNumberOfRetries]];
	self.totalExpectedAndWrittenBytes.text = [NSString stringWithFormat:@"%lldB / %lldB", debuggable.debugProgressInfo.totalBytesWritten, debuggable.debugProgressInfo.expectedTotalBytes];
	self.progressView.progress = debuggable.debugProgressInfo.percentDownloadProgress;
	self.downloadRateLabel.text = [NSString stringWithFormat:@"%.2f KB/sec", debuggable.debugProgressInfo.rate];
	
}

@end
