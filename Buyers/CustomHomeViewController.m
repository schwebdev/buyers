//
//  CustomHomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 11/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "CustomHomeViewController.h"

@interface CustomHomeViewController ()

@end

@implementation CustomHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"custom" title2:@"products" image:@"homeBarcodeLogo.png"];
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
