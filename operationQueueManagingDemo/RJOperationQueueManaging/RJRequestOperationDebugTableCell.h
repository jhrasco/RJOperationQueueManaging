//
//  RJRequestOperatioDebugTableCell.h
//  myClasses
//
//  Created by Ryan Jake on 6/20/13.
//  Copyright (c) 2013 Ryan Jake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJOperationDebugTableCell.h"

@interface RJRequestOperationDebugTableCell : RJOperationDebugTableCell

@property (nonatomic, strong) IBOutlet UILabel *urlLabel;
@property (nonatomic, strong) IBOutlet UILabel *httpMethodLabel;
@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet UILabel *attemptsLabel;
@property (nonatomic, strong) IBOutlet UILabel *totalExpectedAndWrittenBytes;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *downloadRateLabel;

@end
