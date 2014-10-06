//
//  OrderVsIntakeReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 15/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "OrderVsIntakeReportViewController.h"
#import "ReportViewController.h"
#import "SchTextField.h"
#import "Sync.h"
#import "ReportFilterSet.h"
#import "AppDelegate.h"

@interface OrderVsIntakeReportViewController ()

@property (nonatomic) NSMutableArray * departmentsList;

@property SchTextField *saveText;
@property UIPopoverController *popover;

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
- (IBAction)saveFilterSet {
    NSString *fileName = [self.saveText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if(fileName.length > 0) {
        
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",fileName]];
        
        NSError *error;
        NSArray *reports = [managedContext executeFetchRequest:request error:&error];
        
        if(reports.count > 0) {
            //ReportData *report = reports[0];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"a filter set with this name already exists" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        } else {
            
            NSMutableString *filterString = [NSMutableString new];
            [filterString appendFormat:@"%@;", [self.CalWeekFrom getSelectedValue]];
            [filterString appendFormat:@"%@;", [self.CalWeekTo getSelectedValue]];
            [filterString appendFormat:@"%@;", [self.BrandsList getSelectedValue]];
            [filterString appendFormat:@"%@;", [self.MerchList getSelectedValue]];
            [filterString appendFormat:@"%@;", [self.SuppliersList getSelectedValue]];
            [filterString appendFormat:@"%@;", self.AnalysisCode.text];
            
            for (NSIndexPath *path in [self.departmentsTable indexPathsForSelectedRows]) {
                [filterString appendFormat:@"%@,", self.departmentsList[path.row][@"depCode"]];
            }
            NSLog(@"filterString value, %@",filterString);
            
            ReportFilterSet *filterSet = [NSEntityDescription insertNewObjectForEntityForName:@"ReportFilterSet" inManagedObjectContext:managedContext];
            filterSet.filterSetName = fileName;
            filterSet.filterValues = filterString;
            filterSet.createdBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            filterSet.reportType = @"OrderVsIntake";
            filterSet.lastModified = [NSDate date];
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not save filter set: %@", [saveError localizedDescription]);
            } else {
                NSLog(@"%@ filter set entry created", fileName);
            }
            
            [self.popover dismissPopoverAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"filter set has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    
}


- (IBAction)saveClick:(UIButton*)sender {
    //[self createPDFFromUIVIew:self.webView saveToDocumentWithFileName:@"test.pdf"];
    //[self savePDFFromWebView:self.webView fileName:@"test2.pdf"];
    
    //UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] init];
    
    self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    self.saveText.autocorrectionType = UITextAutocorrectionTypeNo;
    [popoverView addSubview:self.saveText];
    
    
    UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveConfirm setTitle:@"confirm" forState:UIControlStateNormal];
    [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    
    //[saveConfirm setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
    
    [saveConfirm setFrame:CGRectMake(60, 70, 150, 50)];
    [saveConfirm addTarget:self action:@selector(saveFilterSet) forControlEvents:UIControlEventTouchUpInside];
    
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    //self.popover.delegate = self;
    [self.popover setPopoverContentSize:CGSizeMake(270, 130) animated:NO];
    
    [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    //[self.popover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
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
        [self.CalWeekFrom setSelectedValue:filterSetValues[0]];
        [self.CalWeekTo setSelectedValue:filterSetValues[1]];
        [self.BrandsList setSelectedValue:filterSetValues[2]];
        [self.MerchList setSelectedValue:filterSetValues[3]];
        [self.SuppliersList setSelectedValue:filterSetValues[4]];
        self.AnalysisCode.text = filterSetValues[5];
        
        
        for (NSString *value in [filterSetValues[6] componentsSeparatedByString:@","]) {
            
            for (int i = 0; i < self.departmentsList.count; i++) {
                if([self.departmentsList[i][@"depCode"] intValue] == [value intValue]) {
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    
                    [self.departmentsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
            
        }
    }

    
    NSMutableString *filterString = [NSMutableString new];
    [filterString appendFormat:@"%@;", [self.CalWeekFrom getSelectedValue]];
    [filterString appendFormat:@"%@;", [self.CalWeekTo getSelectedValue]];
    [filterString appendFormat:@"%@;", [self.BrandsList getSelectedValue]];
    [filterString appendFormat:@"%@;", [self.MerchList getSelectedValue]];
    [filterString appendFormat:@"%@;", [self.SuppliersList getSelectedValue]];
    [filterString appendFormat:@"%@;", self.AnalysisCode.text];
    
    for (NSIndexPath *path in [self.departmentsTable indexPathsForSelectedRows]) {
        [filterString appendFormat:@"%@,", self.departmentsList[path.row][@"depCode"]];
    }
    
    
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
    
    
    self.departmentsList = (NSMutableArray *)[Sync getTable:@"Department" sortWith:@"depDesc"];
    
    [self.MerchList setListItems:(NSMutableArray *)[Sync getTable:@"Merch" sortWith:@"merchName"] withName:@"merchName" withValue:@"merchRef"];
    [self.SuppliersList setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    [self.BrandsList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    [self.CalWeekFrom setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];    
    [self.CalWeekTo setListItems:(NSMutableArray *)[Sync getTable:@"CalYearWeek" sortWith:@"calYearWeek"] withName:@"calYearWeek" withValue:@"calYearWeek"];
    
    
   // self.departmentsTable.frame = CGRectMake(0, 0,  150, 600);
    
    self.departmentsTable.layer.borderWidth = 1.0;
    self.departmentsTable.layer.borderColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.departmentsTable setLayoutMargins:UIEdgeInsetsZero];
    
    UIView *barButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 85)];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"schuhMenuIcon-S.png"] forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"save" forState:UIControlStateNormal];
    [saveButton setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    saveButton.frame = CGRectMake(0, 0, 100, 50);
    //[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [saveButton addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    [barButtons addSubview:saveButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.filterSetName != nil) {
        [self loadFilterSet];
    }
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
