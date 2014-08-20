//
//  ReportHomeViewController.h
//  Buyers
//
//  Created by webdevelopment on 07/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SchDropDown.h"
@interface ReportHomeViewController : BaseViewController

@property (weak, nonatomic) IBOutlet SchDropDown *reportType;
@property (weak, nonatomic) IBOutlet SchDropDown *reportList;

- (IBAction)reportFilterChange:(id)sender;

- (IBAction)runReportClick:(id)sender;

@end
