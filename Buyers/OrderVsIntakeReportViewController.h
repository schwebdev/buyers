//
//  OrderVsIntakeReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SchTextField.h"
#import "SchDropDown.h"

@interface OrderVsIntakeReportViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet SchDropDown *CalWeekFrom;
@property (weak, nonatomic) IBOutlet SchDropDown *CalWeekTo;

@property (weak, nonatomic) IBOutlet SchDropDown *SuppliersList;
@property (weak, nonatomic) IBOutlet SchDropDown *BrandsList;
@property (weak, nonatomic) IBOutlet SchDropDown *MerchList;
@property (weak, nonatomic) IBOutlet SchTextField *AnalysisCode;
@property (weak, nonatomic) IBOutlet UITableView *departmentsTable;

@property (strong, nonatomic) NSString *filterSetName;

- (IBAction)syncReportClick:(id)sender;
- (IBAction)runReportClick:(id)sender;

@end
