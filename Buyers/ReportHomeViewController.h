//
//  ReportHomeViewController.h
//  Buyers
//
//  Created by webdevelopment on 07/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SchTextField.h"
@interface ReportHomeViewController : BaseViewController

@property (weak, nonatomic) IBOutlet SchTextField *txt1;
@property (weak, nonatomic) IBOutlet SchTextField *txt2;

- (IBAction)reportFilterChange:(id)sender;

- (IBAction)runReportClick:(id)sender;

@end
