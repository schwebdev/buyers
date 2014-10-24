//
//  OrderVsIntakeReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//
#import "BaseReportFilterViewController.h"

@interface OrderVsIntakeReportViewController : BaseReportFilterViewController <UITableViewDataSource, UITableViewDelegate,ReportFilterViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet SchTextField *CalLastWeeks;
@property (weak, nonatomic) IBOutlet SchDropDown *CalWeekFrom;
@property (weak, nonatomic) IBOutlet SchDropDown *CalWeekTo;

@property (weak, nonatomic) IBOutlet SchDropDown *SuppliersList;
@property (weak, nonatomic) IBOutlet SchDropDown *BrandsList;
@property (weak, nonatomic) IBOutlet SchDropDown *MerchList;
@property (weak, nonatomic) IBOutlet SchTextField *AnalysisCode;
@property (weak, nonatomic) IBOutlet UITableView *departmentsTable;


@end
