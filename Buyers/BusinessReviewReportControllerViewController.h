//
//  BusinessReviewReportControllerViewController.h
//  Buyers
//
//  Created by webdevelopment on 25/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"

@interface BusinessReviewReportControllerViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *departmentsTable;
- (IBAction)runReportClick:(id)sender;

@end
