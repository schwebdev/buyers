//
//  BusinessReviewReportControllerViewController.m
//  Buyers
//
//  Created by webdevelopment on 25/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BusinessReviewReportViewController.h"

@interface BusinessReviewReportViewController ()

@property (nonatomic) NSMutableArray * departmentsList;

@end

@implementation BusinessReviewReportViewController

- (NSString *)getFilterString {
    NSMutableString *filterString = [NSMutableString new];
    
    return filterString;
}

- (void)loadFilterSet {
//    NSLog(@"load filter set");
//    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",self.filterSetName]];
//    
//    NSError *error;
//    NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
//    
//    if(filterSets.count > 0) {
//        ReportFilterSet *filterSet = [filterSets objectAtIndex:0];
//        
//        NSLog(@"filterString value, %@",filterSet.filterValues);
//        NSArray *filterSetValues = [filterSet.filterValues componentsSeparatedByString:@";"];
//        [self.CalWeekFrom setSelectedValue:filterSetValues[0]];
//        [self.CalWeekTo setSelectedValue:filterSetValues[1]];
//        [self.BrandsList setSelectedValue:filterSetValues[2]];
//        [self.MerchList setSelectedValue:filterSetValues[3]];
//        [self.SuppliersList setSelectedValue:filterSetValues[4]];
//        self.AnalysisCode.text = filterSetValues[5];
//        
//        
//        for (NSString *value in [filterSetValues[6] componentsSeparatedByString:@","]) {
//            
//            for (int i = 0; i < self.departmentsList.count; i++) {
//                if([self.departmentsList[i][@"depCode"] intValue] == [value intValue]) {
//                    
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                    
//                    [self.departmentsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//                }
//            }
//            
//        }
//    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    self.departmentsTable.layer.borderWidth = 1.0;
    self.departmentsTable.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.departmentsTable setLayoutMargins:UIEdgeInsetsZero];
    
    //UIScrollView *sv = (UIScrollView*)self.view;
    [self.container setFrame:CGRectMake(0, 85, 834, 619)];
    [self.container setContentSize:CGSizeMake(self.container.frame.size.width, 1238)];
    
    UIButton *btn = (UIButton*)[self.view viewWithTag:2];
    
    [btn setSelected:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.container flashScrollIndicators];
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
    
    NSDictionary *listItem = (NSDictionary *)self.departmentsList[indexPath.row];
    cell.textLabel.text = listItem[[[listItem allKeys] objectAtIndex:0]];
    
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    for (NSIndexPath *path in [tableView indexPathsForSelectedRows]) {
        if (path.row == indexPath.row) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
}


@end
