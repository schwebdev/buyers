//
//  ReportHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 07/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ReportHomeViewController.h"
#import "SWRevealViewController.h"
#import "ReportViewController.h"
#import "AppDelegate.h"
#import "ReportData.h"
#import "ReportFilterSet.h"

@interface ReportHomeViewController ()

@end

@implementation ReportHomeViewController

- (IBAction)viewReportClick:(id)sender {
    
    if([self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a report"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
        //vc.reportType = @"Order Vs Intake Report";
        
        [vc view];
        //NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
        NSString *filePath = [self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//[reportsPath stringByAppendingPathComponent:[self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        
        [vc loadReport:filePath];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)runReportClick:(id)sender {
    
    if([self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a report type"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@Report",[self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)editFilterSet:(id)sender {
    
    if(self.filterSets.getSelectedValue.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a filter set"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@Report",[self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        
        [vc setValue:self.filterSets.getSelectedValue forKey:@"filterSetName"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)viewFilterSet:(id)sender {
    if(self.filterSets.getSelectedValue.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a filter set"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
        //vc.reportType = @"Order Vs Intake Report";
        
        [vc view];
        //NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
        NSString *filePath = [self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//[reportsPath stringByAppendingPathComponent:[self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        
        [vc loadReport:filePath];
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
        
        self.reportList.listItems = [NSMutableArray array];
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy == %@)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]];
        
        NSError *error;
        NSArray *reports = [managedContext executeFetchRequest:request error:&error];
        
        if(reports.count > 0) {
            for (ReportData *report in reports) {
                [self.reportList.listItems addObject:@{report.name:report.name}];
            }
        }
    } else {
        
        self.reportList.listItems = [NSMutableArray arrayWithObjects:
                               @{@"blah":@"blah"}, nil];
        
    }
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
                                 @{@"OrderVsIntake":@"Order vs Intake Report"},
                                 @{@"BusinessReview":@"Business Review Report"},
                                 nil];
    
    self.reportType.observerName = @"reportTypeSelect";
    
    //[NSMutableDictionary dictionaryWithObjectsAndKeys:@"val1",@"1",@"val2",@"2",@"val3",@"3",nil];

}

- (void) dropDownSelectChange:(NSNotification *)notification {
   // NSString *reportType = (NSString*)notification.object;
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(reportType == %@)",[self.reportType getSelectedValue]]];
    
    NSError *error;
    NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
    
    self.filterSets.listItems = [NSMutableArray array];
    if(filterSets.count > 0) {
        for (ReportFilterSet *filterSet in filterSets) {
            [self.filterSets.listItems addObject:@{filterSet.filterSetName:filterSet.filterSetName}];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    UIButton *menu1 = [self setMenuButton:1 title:@"reports 1"];
//    
//    [menu1 addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self setMenuButton:2 title:@"reports 2"];
//    [self setMenuButton:3 title:@"reports 3"];
    
    
    /*
    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
        
    NSArray *reports = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:reportsPath error:nil];

    self.reportList.listItems = [NSMutableArray array];
    
    for (NSString *report in reports) {
        [self.reportList.listItems addObject:@{report:report}];
    }
    */
    
    self.reportList.listItems = [NSMutableArray array];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy == %@)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]];
    
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count > 0) {        
        for (ReportData *report in reports) {
            [self.reportList.listItems addObject:@{report.name:report.name}];
        }
    }
    
    self.filterSets.listItems = [NSMutableArray array];
    
    if([self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        [self dropDownSelectChange:nil];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(dropDownSelectChange:) name:self.reportType.observerName object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
