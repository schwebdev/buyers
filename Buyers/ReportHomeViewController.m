//
//  ReportHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 07/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ReportHomeViewController.h"
#import "SWRevealViewController.h"

@interface ReportHomeViewController ()

@end

@implementation ReportHomeViewController


- (IBAction)runReportClick:(id)sender {
    
    if([self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a report type"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderVsIntakeReportViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (IBAction)reportFilterChange:(id)sender {
    
    UISwitch *currentSwitch = (UISwitch *)sender;
    [currentSwitch setOn:YES animated:YES];
    
    //if(currentSwitch.on) {
        for (UIView *subview in currentSwitch.superview.subviews) {
            if([subview isKindOfClass:[UISwitch class]]) {
                if(subview.tag != currentSwitch.tag) {
                    UISwitch *otherSwitch = (UISwitch*)subview;
                    [otherSwitch setOn:NO animated:YES];
                }
            }
        }
    //}
    self.reportList.text = @"";
    if(currentSwitch.tag == 0) {
        
        NSArray *reports = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"] error:nil];
        
        self.reportList.listItems = [NSMutableArray array];
        
        for (NSString *report in reports) {
            [self.reportList.listItems addObject:@{report:report}];
        }
    } else {
        
        self.reportList.listItems = [NSMutableArray arrayWithObjects:
                               @{@"blah":@"blah"}, nil];
        
    }
}

- (void)alert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert2" message:[NSString stringWithFormat:@"test2"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@""]];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(512, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
    
    
    self.reportType.listItems = [NSMutableArray arrayWithObjects:
                            @{@"OrderVsIntakeReportViewController":@"Order vs Intake"}, nil];
    
    
    
    NSArray *reports = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"] error:nil];
    
    self.reportList.listItems = [NSMutableArray array];
    
    for (NSString *report in reports) {
        [self.reportList.listItems addObject:@{report:report}];
    }
    //[NSMutableDictionary dictionaryWithObjectsAndKeys:@"val1",@"1",@"val2",@"2",@"val3",@"3",nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIButton *menu1 = [self setMenuButton:1 title:@"reports 1"];
    
    [menu1 addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    
    [self setMenuButton:2 title:@"reports 2"];
    [self setMenuButton:3 title:@"reports 3"];
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
