//
//  OrderVsIntakeReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "OrderVsIntakeReportViewController.h"
#import "ReportViewController.h"
@interface OrderVsIntakeReportViewController ()

@end

@implementation OrderVsIntakeReportViewController


- (IBAction)runReportClick:(id)sender {

    ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    vc.reportType = @"Order Vs Intake Report";
   // [vc preLoadView];
    
    [vc generateReport];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"order vs intake by week report"]];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(802, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
