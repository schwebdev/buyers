//
//  OrderVsIntakeReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "OrderVsIntakeReportViewController.h"
#import "ReportViewController.h"
#import "Sync.h"
#import "Supplier.h"

@interface OrderVsIntakeReportViewController ()

@property (nonatomic) NSMutableArray * departmentsList;

@end

@implementation OrderVsIntakeReportViewController


- (IBAction)runReportClick:(id)sender {
    
    NSLog(@"calweekfrom value, %@",[self.CalWeekFrom getSelectedValue]);
    NSLog(@"calweekto value, %@",[self.CalWeekTo getSelectedValue]);
    NSLog(@"brand value, %@",[self.BrandsList getSelectedValue]);
    NSLog(@"supplier value, %@",[self.SuppliersList getSelectedValue]);
    NSLog(@"merch value, %@",[self.MerchList getSelectedValue]);
    for (NSIndexPath *path in [self.departmentsTable indexPathsForSelectedRows]) {
        //self.departmentsList[path.row][@"supplierName"];
        //Supplier *supplier = (Supplier *)self.departmentsList[path.row];
        //NSLog(@"%@ - %@",[[listItem allKeys] objectAtIndex:0], listItem[[[listItem allKeys] objectAtIndex:0]]);
        NSLog(@"%@, %@",self.departmentsList[path.row][@"depCode"], self.departmentsList[path.row][@"depDesc"]);
    }
    ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    vc.reportType = @"OrderVsIntake";
   // [vc preLoadView];
    
    [vc view];
    [vc generateReport];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"order vs intake by week report"]];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(834, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
    
    self.departmentsList = [NSMutableArray arrayWithObjects:
                      @{@"1":@"blah1"},
                      @{@"2":@"blah2"},
                      @{@"3":@"blah3"},
                      @{@"4":@"blah4"},
                      @{@"5":@"blah5"},
                      @{@"6":@"blah6"},
                      @{@"7":@"blah7"},
                      @{@"8":@"blah8"},
                      @{@"9":@"blah9"},
                      @{@"10":@"blah10"},
                      @{@"11":@"blah11"},
                      @{@"12":@"blah12"},
                      @{@"13":@"blah13"},
                      @{@"14":@"blah14"},
                      @{@"15":@"blah15"},
                      nil];
    
    
    
    self.departmentsList = (NSMutableArray *)[Sync getTable:@"Department" sortWith:@"depDesc"];
    
    [self.MerchList setListItems:(NSMutableArray *)[Sync getTable:@"Merch" sortWith:@"merchName"] withName:@"merchName" withValue:@"merchRef"];
    [self.SuppliersList setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    [self.BrandsList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    
    [self.CalWeekFrom setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];
    
    [self.CalWeekTo setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];
    
    
   // self.departmentsTable.frame = CGRectMake(0, 0,  150, 600);
    
    self.departmentsTable.layer.borderWidth = 1.0;
    self.departmentsTable.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.departmentsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcItems"];
    
    //NSDictionary *listItem = (NSDictionary *)self.departmentsList[indexPath.row];
    //cell.textLabel.text = listItem[[[listItem allKeys] objectAtIndex:0]];
    
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.text = self.departmentsList[indexPath.row][@"depDesc"];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    for (NSIndexPath *path in [tableView indexPathsForSelectedRows]) {
        if (path.row == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}
@end
