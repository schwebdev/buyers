//
//  SettingsHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 11/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SettingsHomeViewController.h"
#import "Sync.h"

@interface SettingsHomeViewController ()

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
    
    UIButton *menu1 = [self setMenuButton:1 title:@"settings 1"];
    
    [menu1 addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    
    [self setMenuButton:2 title:@"settings 2"];
    [self setMenuButton:3 title:@"settings 3"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveUserName:(id)sender {
    [userName resignFirstResponder];
    if ([userName.text isEqualToString:(@"")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter your full name!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        //save the new customer name to the nsuserdefaults
        [[NSUserDefaults standardUserDefaults]
         setObject:userName.text forKey:@"username"];
    }
    
}

-(IBAction)startSync:(id)sender {
    
    BOOL success = YES;
    
    success = [Sync syncAll];
    
    if(success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"sync success" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"sync failed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
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
