//
//  BusinessReviewReportControllerViewController.h
//  Buyers
//
//  Created by webdevelopment on 25/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseReportFilterViewController.h"

@interface BusinessReviewReportControllerViewController : BaseReportFilterViewController <UITableViewDataSource, UITableViewDelegate, ReportFilterViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *departmentsTable;

@end
