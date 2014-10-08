//
//  BaseNavigationController.m
//  Buyers
//
//  Created by webdevelopment on 03/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseNavigationController.h"
#import "SWRevealViewController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    return [super popViewControllerAnimated:animated];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    [super pushViewController:viewController animated:animated];
}

@end
