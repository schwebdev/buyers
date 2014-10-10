//
//  BaseReportFilterViewController.h
//  Buyers
//
//  Created by webdevelopment on 10/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"
#import "SchTextField.h"
#import "SchDropDown.h"
#import "Sync.h"
#import "ReportFilterSet.h"
#import "ReportViewController.h"
#import "AppDelegate.h"
#import "Report.h"
#import "ReportData.h"

@protocol ReportFilterViewDelegate <NSObject>

- (NSString *)getFilterString;
- (void)loadFilterSet;

@end

@interface BaseReportFilterViewController : BaseViewController <UIAlertViewDelegate, ReportFilterViewDelegate>

@property (strong, nonatomic) NSString *reportType;
@property (strong, nonatomic) NSString *reportTypeName;
@property (strong, nonatomic) NSString *filterSetName;

- (IBAction)syncReportClick:(id)sender;
- (IBAction)runReportClick:(id)sender;
@end
