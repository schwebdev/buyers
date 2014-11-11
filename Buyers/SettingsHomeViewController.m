//
//  SettingsHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 11/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SettingsHomeViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "Sync.h"
#import "ReportData.h"

@interface SettingsHomeViewController ()

@property UIView *loadingOverlay;
@property UIProgressView *progressView;

@end

@implementation SettingsHomeViewController

@synthesize userName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)alert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[NSString stringWithFormat:@"test"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"change" title2:@"settings" image:@"homeSettingsLogoGrey.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"YOUR OPTIONS"]];
    
    
    //get user's full name from app settings and display it (wil display nothing if it has not been set
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userName.text = [defaults objectForKey:@"username"];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(512, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
    
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateLastSync];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateLastSync {
    NSDate *lastSync = [Sync getLastSyncDate];
    
    if(lastSync == nil) {
        _syncLabel.text = @"Please start synchronisation";
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"dd MMMM yyyy HH:mm";
        
        _syncLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:lastSync]];
        
        //CGSize textSize = [_syncLabel.text sizeWithAttributes:@{NSFontAttributeName: _syncLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        int dayDifference = [[NSDate date] timeIntervalSinceDate:lastSync] / 86400;
        
        _syncDays.text = [NSString stringWithFormat:@"%d",dayDifference];
        if(dayDifference >= 5) {
            _syncDays.superview.backgroundColor = [UIColor colorWithRed:153.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
            _syncLabel.superview.backgroundColor = [UIColor colorWithRed:153.0f/255.0f green:0.0f blue:0.0f alpha:1.0f];
        } else if(dayDifference >= 3) {
            _syncDays.superview.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
            _syncLabel.superview.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:100.0f/255.0f blue:0.0f alpha:1.0f];
        } else {
            _syncDays.superview.backgroundColor = [UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
            _syncLabel.superview.backgroundColor = [UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
            
        }
    }
}

-(IBAction)saveUserName:(id)sender {
    [userName resignFirstResponder];
    if (userName.text.length < 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your full name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        //save the new customer name to the nsuserdefaults
        [[NSUserDefaults standardUserDefaults]
         setObject:userName.text forKey:@"username"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"username saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(IBAction)startSync:(id)sender {
    
    
    Reachability *network = [(AppDelegate *)[[UIApplication sharedApplication] delegate] reachability];
    
    if ([network currentReachabilityStatus] == ReachableViaWiFi) {
        
        self.loadingOverlay = [[UIView alloc] initWithFrame:CGRectMake(0,0, 1024,768)];
        self.loadingOverlay.backgroundColor = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f];
        
        UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0,0, 300,200)];
        subview.backgroundColor = [UIColor whiteColor];
        [self.loadingOverlay addSubview:subview];
        subview.center = self.loadingOverlay.center;
        subview.layer.cornerRadius = 10;
        
        UILabel *syncLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 300, 30)];
        syncLabel.text = @"syncing...";
        syncLabel.textAlignment = NSTextAlignmentCenter;
        [subview addSubview:syncLabel];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
        [self.loadingOverlay addSubview:indicator];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicator.center = self.loadingOverlay.center;
        [indicator startAnimating];
        
        
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(25,135,250,50)];
        self.progressView.progress = 0;
        [subview addSubview:self.progressView];
        
        [[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] addSubview:self.loadingOverlay];

        [self performSelectorInBackground:@selector(sync) withObject:nil];
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"sync failed" message:@"no wifi found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }
}

-(void)sync {
    BOOL success = YES;
    
    //internet check
    
    CGFloat syncCount = 13;
    
    if(success) {
        success = [Sync syncTable:@"Supplier"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:1/syncCount] waitUntilDone:YES];
    }
    if(success) {
        success = [Sync syncTable:@"Brand"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:2/syncCount] waitUntilDone:YES];
    }
    if(success) {
        success = [Sync syncTable:@"CalYearWeek"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:3/syncCount] waitUntilDone:YES];
    }
    if(success) {
        success = [Sync syncTable:@"Merch"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:4/syncCount] waitUntilDone:YES];
    }
    if(success) {
        success = [Sync syncTable:@"Department"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:5/syncCount] waitUntilDone:YES];
    }
   
    if(success) {
        success = [Sync syncReportData];        
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:6/syncCount] waitUntilDone:YES];
    }
    
    if(success) {
        success = [Sync syncFilterReports];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:7/syncCount] waitUntilDone:YES];
        
    }
    if(success) {
        success = [Sync syncTable:@"ProductCategory"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:8/syncCount] waitUntilDone:YES];
    }
    
    if(success) {
     success = [Sync syncTable:@"Colour"];
     [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:9/syncCount] waitUntilDone:YES];
     }
    
    if(success) {
     success = [Sync syncTable:@"Material"];
     [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:10/syncCount] waitUntilDone:YES];
     }
    
    if(success) {
        success = [Sync syncTable:@"Product"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:11/syncCount] waitUntilDone:YES];
    }
    /*if(success) {
        success = [Sync syncTable:@"Collection"];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:12/syncCount] waitUntilDone:YES];
    }*/
    
    if(success) {
        success = [Sync syncProductData];
        [self performSelectorOnMainThread:@selector(updateProgress:) withObject:[NSNumber numberWithFloat:13/syncCount] waitUntilDone:YES];
    }
    
    if(success) {
        
        [Sync updateSyncStatus:@"global"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"sync success" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"sync failed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    [self updateLastSync];
    

    
   
    
    [self performSelectorOnMainThread:@selector(endSync) withObject:nil waitUntilDone:YES];

}
-(void)updateProgress:(NSNumber *)progress {
    self.progressView.progress = [progress floatValue];
}
-(void)endSync {
    [self.loadingOverlay removeFromSuperview];
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
