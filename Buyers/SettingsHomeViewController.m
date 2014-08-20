//
//  SettingsHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 11/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SettingsHomeViewController.h"

@interface SettingsHomeViewController ()

@end

@implementation SettingsHomeViewController

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
