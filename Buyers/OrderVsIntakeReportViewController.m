//
//  OrderVsIntakeReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "OrderVsIntakeReportViewController.h"

@interface OrderVsIntakeReportViewController ()

@property (nonatomic) NSMutableArray * departmentsList;


@end

@implementation OrderVsIntakeReportViewController

- (NSString *)getFilterString {
    NSMutableString *filterString = [NSMutableString new];
    [filterString appendFormat:@"%@;", [[self.CalWeekFrom getSelectedValue] isEqualToString:@""] ? @"-1" : [self.CalWeekFrom getSelectedValue]];
    [filterString appendFormat:@"%@;", [[self.CalWeekTo getSelectedValue] isEqualToString:@""] ? @"-1" : [self.CalWeekTo getSelectedValue]];
    [filterString appendFormat:@"%@;", [[self.BrandsList getSelectedValue] isEqualToString:@""] ? @"-1" : [self.BrandsList getSelectedValue]];
    [filterString appendFormat:@"%@;", [[self.MerchList getSelectedValue] isEqualToString:@""] ? @"-1" : [self.MerchList getSelectedValue]];
    [filterString appendFormat:@"%@;", [[self.SuppliersList getSelectedValue] isEqualToString:@""] ? @"-1" : [self.SuppliersList getSelectedValue]];
    [filterString appendFormat:@"%@;", [self.AnalysisCode.text isEqualToString:@""] ? @"-1" : self.AnalysisCode.text];
    
    if([self.departmentsTable indexPathsForSelectedRows].count == 0) {
        [filterString appendFormat:@"-1"];
    } else {
        for (NSIndexPath *path in [self.departmentsTable indexPathsForSelectedRows]) {
            [filterString appendFormat:@"%@,", self.departmentsList[path.row][@"depCode"]];
        }
    }
    
    return filterString;
}

- (void)loadFilterSet {
    NSLog(@"load filter set");
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",self.filterSetName]];
    
    NSError *error;
    NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
    
    if(filterSets.count > 0) {
        ReportFilterSet *filterSet = [filterSets objectAtIndex:0];
        
        NSLog(@"filterString value, %@",filterSet.filterValues);
        NSArray *filterSetValues = [filterSet.filterValues componentsSeparatedByString:@";"];
        if(![filterSetValues[0] isEqualToString:@"-1"])[self.CalWeekFrom setSelectedValue:filterSetValues[0]];
        if(![filterSetValues[1] isEqualToString:@"-1"])[self.CalWeekTo setSelectedValue:filterSetValues[1]];
        if(![filterSetValues[2] isEqualToString:@"-1"])[self.BrandsList setSelectedValue:filterSetValues[2]];
        if(![filterSetValues[3] isEqualToString:@"-1"])[self.MerchList setSelectedValue:filterSetValues[3]];
        if(![filterSetValues[4] isEqualToString:@"-1"])[self.SuppliersList setSelectedValue:filterSetValues[4]];
        if(![filterSetValues[5] isEqualToString:@"-1"])self.AnalysisCode.text = filterSetValues[5];
        
        if(![filterSetValues[6] isEqualToString:@"-1"]) {
        for (NSString *value in [filterSetValues[6] componentsSeparatedByString:@","]) {
            
            for (int i = 0; i < self.departmentsList.count; i++) {
                if([self.departmentsList[i][@"depCode"] intValue] == [value intValue]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [self.departmentsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
            
        }
        }
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.departmentsList = (NSMutableArray *)[Sync getTable:@"Department" sortWith:@"depDesc"];
    
    [self.MerchList setListItems:(NSMutableArray *)[Sync getTable:@"Merch" sortWith:@"merchName"] withName:@"merchName" withValue:@"merchRef"];
    [self.SuppliersList setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    [self.BrandsList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    [self.CalWeekFrom setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];    
    [self.CalWeekTo setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];
    
    
   // self.departmentsTable.frame = CGRectMake(0, 0,  150, 600);
    
    self.departmentsTable.layer.borderWidth = 1.0;
    self.departmentsTable.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    
    if ([self.departmentsTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.departmentsTable setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
