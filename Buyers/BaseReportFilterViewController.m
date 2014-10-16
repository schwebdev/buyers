//
//  BaseReportFilterViewController.m
//  Buyers
//
//  Created by webdevelopment on 10/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseReportFilterViewController.h"

@interface BaseReportFilterViewController ()

@property SchTextField *saveText;
@property UIPopoverController *popover;
@end

@implementation BaseReportFilterViewController


- (NSString *)getFilterString {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"you must override %@ in subclass",  NSStringFromSelector(_cmd)] userInfo:nil];
}

- (void)loadFilterSet {
    [NSException raise:NSInternalInconsistencyException format:@"you must override %@ in subclass", NSStringFromSelector(_cmd)];
}

- (void)syncReportClick:(id)sender {
    
    if(self.filterSetName != nil) {
        
        NSString *htmlString = [Report generateReport:self.reportType withFilters:[self getFilterString]];
        
        if(htmlString.length > 0) {
            NSString *reportName = [NSString stringWithFormat:@"filterReport:%@",self.filterSetName];
            
            NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",reportName]];
            
            NSError *error;
            NSArray *reports = [managedContext executeFetchRequest:request error:&error];
            ReportData *report;
            
            if(reports.count > 0) {
                report = reports[0];
            } else {
                report = [NSEntityDescription insertNewObjectForEntityForName:@"ReportData" inManagedObjectContext:managedContext];
                report.name = reportName;
            }
            
            report.content = htmlString;
            report.lastModified = [NSDate date];
            report.createdBy = @"sync";
            report.requiresSync = @NO;
            
            
            request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",self.filterSetName]];
            
            NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
            if(filterSets.count > 0) {
                
                ReportFilterSet *filterSet = filterSets[0];
                filterSet.lastSync = [NSDate date];
            }
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not save reportdata: %@", [saveError localizedDescription]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set sync failed"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"%@ reportdata entry saved", reportName);
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"filter set report has been synced"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
                ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
                [vc view];
                [vc loadReport:reportName];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set must be saved before it can be synced."] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)runReportClick:(id)sender {
    
    NSString *filterString = [self getFilterString];
    NSLog(@"filterString value, %@",filterString);
    ReportViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    vc.reportType = self.reportType;
    // [vc preLoadView];
    
    [vc view];
    [vc generateReport:filterString];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveFilterSet {
    NSString *fileName = self.saveText.text;
    
    if([fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",fileName]];
        
        NSError *error;
        NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
        
        if(filterSets.count > 0) {
            //ReportData *report = reports[0];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"warning" message:@"a filter set with this name already exists. would you like to overwrite it?" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
            alert.tag = 1;
            [alert show];
        } else {
            
            NSString *filterString = [self getFilterString];
            NSLog(@"filterString value, %@",filterString);
            
            ReportFilterSet *filterSet = [NSEntityDescription insertNewObjectForEntityForName:@"ReportFilterSet" inManagedObjectContext:managedContext];
            filterSet.filterSetName = fileName;
            filterSet.filterValues = filterString;
            filterSet.createdBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            filterSet.reportType = self.reportType;
            filterSet.lastModified = [NSDate date];
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not save filter set: %@", [saveError localizedDescription]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set save failed"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"%@ filter set entry created", fileName);
                self.filterSetName = fileName;
                [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@: %@", self.reportTypeName, self.filterSetName]]];
                
                [self.popover dismissPopoverAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"filter set has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag == 1 && buttonIndex == 1) {
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",self.filterSetName]];
        
        NSError *error;
        NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
        
        if(filterSets.count > 0) {
            ReportFilterSet *filterSet = filterSets[0];
            
            NSString *filterString = [self getFilterString];
            NSLog(@"filterString value, %@",filterString);
            
            filterSet.filterValues = filterString;
            filterSet.createdBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            filterSet.reportType = self.reportType;
            filterSet.lastModified = [NSDate date];
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not save filter set: %@", [saveError localizedDescription]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set save failed"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"%@ filter set entry saved", self.filterSetName);
                [self.popover dismissPopoverAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"filter set has been saved"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else if(alertView.tag == 2 && buttonIndex == 1) {
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(filterSetName == %@)",self.filterSetName]];
        
        NSError *error;
        NSArray *filterSets = [managedContext executeFetchRequest:request error:&error];
        
        if(filterSets.count > 0) {
            
            [managedContext deleteObject:filterSets[0]];
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not delete filter set: %@", [saveError localizedDescription]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set delete failed"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            } else {
                NSLog(@"%@ filter set entry marked as deleted", self.filterSetName);
                
                self.filterSetName = @"";
                [self.navigationController popViewControllerAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"filter set has been deleted"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            }
        }
        
    }
}


- (IBAction)saveClick:(UIButton*)sender {
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"username"] == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please set your username on the settings screen."] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    } else {
        
        UIViewController *popoverContent = [[UIViewController alloc] init];
        
        UIView *popoverView = [[UIView alloc] init];
        
        self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
        self.saveText.autocorrectionType = UITextAutocorrectionTypeNo;
        self.saveText.text = self.filterSetName;
        [popoverView addSubview:self.saveText];
        
        
        UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
        [saveConfirm setTitle:@"confirm" forState:UIControlStateNormal];
        [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
        
        [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
        
        [saveConfirm setFrame:CGRectMake(60, 70, 150, 50)];
        [saveConfirm addTarget:self action:@selector(saveFilterSet) forControlEvents:UIControlEventTouchUpInside];
        
        [popoverView addSubview:saveConfirm];
        
        popoverContent.view = popoverView;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        [self.popover setPopoverContentSize:CGSizeMake(270, 130) animated:NO];
        
        [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}


- (void)deleteFilter {
    if(self.filterSetName != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"warning" message:[NSString stringWithFormat:@"Are you sure you wish to delete this filter set?"] delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes",nil];
        alert.tag = 2;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"filter set has not been saved"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"report" title2:@"filters" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:self.reportTypeName]];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(834, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
    
    UIView *barButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 65)];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"schuhMenuIcon-S.png"] forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"save" forState:UIControlStateNormal];
    [saveButton setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    saveButton.frame = CGRectMake(0, 0, 100, 40);
    //[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [saveButton addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    [barButtons addSubview:saveButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if(self.filterSetName != nil) {
        [self loadFilterSet];
        
        [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@: %@", self.reportTypeName, self.filterSetName]]];
    }
    
    
    [[self setMenuButton:1 title:@"delete filter set"] addTarget:self action:@selector(deleteFilter) forControlEvents:UIControlEventTouchUpInside];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
