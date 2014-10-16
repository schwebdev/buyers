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
#import "BaseReportFilterViewController.h"
#import "Sync.h"

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
        NSString *filePath = [self.reportList getSelectedValue];//[reportsPath stringByAppendingPathComponent:[self.reportList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        
        [vc loadReport:filePath];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)runReportClick:(id)sender {
    
    if([self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a report type"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        BaseReportFilterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@Report",[self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
                
        vc.reportType = [self.reportType getSelectedValue];
        vc.reportTypeName = self.reportType.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)editFilterSet:(id)sender {
    
    if(self.filterSets.getSelectedValue.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a filter set"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        BaseReportFilterViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%@Report",[self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]];
        
        vc.filterSetName = [self.filterSets getSelectedValue];
        vc.reportType = [self.reportType getSelectedValue];
        vc.reportTypeName = self.reportType.text;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)viewFilterSet:(id)sender {
    if(self.filterSets.getSelectedValue.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please select a filter set"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else if([self.filterSets getSelectedObject][@"lastSync"] == [NSNull null]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"this filter set has not been synced yet"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
        [vc view];
        
        NSString *filePath = [NSString stringWithFormat:@"filterReport:%@",[self.filterSets getSelectedValue]];
        [vc loadReport:filePath];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void) reportTypeChange:(NSNotification *)notification {
    [self.filterSets setListItems:(NSMutableArray *)[Sync getTable:@"ReportFilterSet" sortWith:@"filterSetName" withPredicate:[NSPredicate predicateWithFormat:@"(reportType == %@)",[self.reportType getSelectedValue]]] withName:@"filterSetName" withValue:@"filterSetName"];
    
    self.FilterLabel.text = @"Last sync:";
}


- (void) filterSetsChange:(NSNotification *)notification {
    if([self.filterSets getSelectedObject][@"lastSync"] == [NSNull null]) {
        self.FilterLabel.text = @"Last sync: n/a";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
        
        NSString *dateTime = [dateFormatter stringFromDate:(NSDate*)[self.filterSets getSelectedObject][@"lastSync"]];

        self.FilterLabel.text = [NSString stringWithFormat:@"Last sync: %@",dateTime];
    }
}

- (IBAction)reportFilterChange:(id)sender {
    
    UISwitch *currentSwitch = (UISwitch *)sender;
    [currentSwitch setOn:YES animated:YES];
    
    for (UIView *subview in self.ReportFilterView.subviews) {
        if([subview isKindOfClass:[UISwitch class]]) {
            if(subview.tag != currentSwitch.tag) {
                UISwitch *otherSwitch = (UISwitch*)subview;
                [otherSwitch setOn:NO animated:YES];
            }
        }
    }
    self.reportList.text = @"";
    
    
    self.reportList.listItems = [NSMutableArray array];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    if(currentSwitch.tag == 1) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy == %@ AND isActive == 1)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]];
        
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy != \"sync\" AND isActive == 1)"]];
    }
        
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count > 0) {
        for (ReportData *report in reports) {
            [self.reportList.listItems addObject:@{report.name:report.name}];
        }
    }

}
- (IBAction)reportFilterClicked:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    button.selected = YES;
    
    for (UIView *subview in self.ReportFilterView.subviews) {
        if([subview isKindOfClass:[UIButton class]]) {
            if(subview.tag != button.tag) {
                UIButton *other = (UIButton*)subview;
                other.selected = NO;
            }
        }
    }
    self.reportList.text = @"";
    
    
    self.reportList.listItems = [NSMutableArray array];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    if(button.tag == 1) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy == %@ AND isActive == 1)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]];
        
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy != \"sync\" AND isActive == 1)"]];
    }
    
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count > 0) {
        for (ReportData *report in reports) {
            [self.reportList.listItems addObject:@{report.name:report.name}];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@""]];
    
    
    
    self.reportType.listItems = [NSMutableArray arrayWithObjects:
                                 @{@"OrderVsIntake":@"Order vs Intake Report"},
                                 @{@"BusinessReview":@"Business Review Report"},
                                 @{@"Bestsellers":@"Bestsellers Report"},
                                 nil];
    
    self.reportType.observerName = @"reportTypeSelect";
    
    self.filterSets.observerName = @"filterSetsSelect";
    
    
    UIButton *ownCheck = (UIButton*)[self.ReportFilterView viewWithTag:1];
    ownCheck.selected = YES;

}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIButton *ownCheck = (UIButton*)[self.ReportFilterView viewWithTag:1];
    
    self.reportList.text = @"";
    
    self.reportList.listItems = [NSMutableArray array];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    if([ownCheck isSelected]) {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy == %@ AND isActive == 1)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]]];
    } else {
        [request setPredicate:[NSPredicate predicateWithFormat:@"(createdBy != \"sync\" AND isActive == 1)"]];
    }
    
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count > 0) {
        for (ReportData *report in reports) {
            [self.reportList.listItems addObject:@{report.name:report.name}];
        }
    }
    
    self.filterSets.listItems = [NSMutableArray array];
    
    if([self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0) {
        [self reportTypeChange:nil];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(reportTypeChange:) name:self.reportType.observerName object:nil];
    [center addObserver:self selector:@selector(filterSetsChange:) name:self.filterSets.observerName object:nil];
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
