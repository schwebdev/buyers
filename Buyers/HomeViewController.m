//
//  HomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 05/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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
    // Do any additional setup after loading the view.
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

-(IBAction) btnClick:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:[NSString stringWithFormat:@"%d",btn.tag] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    //[alert show];

    SWRevealViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"RevealController"];
    //UIViewController *destController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsViewController"];
    //[self.view.superview addSubview:destController.view];
    
    //[self.navigationController pushViewController:destController animated:YES];
    //[self presentViewController:destController animated:YES completion:nil];
    
    switch (btn.tag) {
        case 0:
            [destController setFrontViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CollectionsNavController"]];
            break;
        case 1:
            [destController setFrontViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"CustomProductNavController"]];
            break;
        case 2:
            [destController setFrontViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ReportsNavController"]];
            //UINavigationController* navController = (UINavigationController*)destController.frontViewController;
            //[navController setViewControllers:@[dvc] animated:NO];
            break;
        case 3:
            [destController setFrontViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsNavController"]];
            break;
        default:
            break;
    }
    destController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:destController animated:YES completion:nil];
}

@end
