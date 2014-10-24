//
//  StockWorksheetReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 23/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseReportFilterViewController.h"

@interface StockWorksheetReportViewController : BaseReportFilterViewController <UITableViewDataSource, UITableViewDelegate, ReportFilterViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITableView *departmentsTable;

@end
