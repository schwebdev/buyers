//
//  HomeViewController.m
//  Buyers
//
//  Created by webdevelopment on 05/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "Sync.h"

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

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSDate *lastSync = [Sync getLastSyncDate];
    
    if(lastSync == nil) {
        
        _syncLabel.text = @"Please start synchronisation";
        _syncImage.image = [UIImage imageNamed:@"homeSyncRed.png"];
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.dateFormat = @"dd MMMM yyyy HH:mm";
        
        _syncLabel.text = [NSString stringWithFormat:@"Last synchronisation: %@", [dateFormat stringFromDate:lastSync]];
        
        CGSize textSize = [_syncLabel.text sizeWithAttributes:@{NSFontAttributeName: _syncLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}];
        
        
        _syncImage = [[UIImageView alloc] init];
        
        
        int dayDifference = [[NSDate date] timeIntervalSinceDate:lastSync] / 86400;
        if(dayDifference >= 5) {
            _syncImage.image = [UIImage imageNamed:@"homeSyncRed.png"];
        } else if(dayDifference >= 3) {
            _syncImage.image = [UIImage imageNamed:@"homeSyncOrange.png"];
        } else {
            _syncImage.image = [UIImage imageNamed:@"homeSyncGreen2.png"];
        }
        _syncImage.frame = CGRectMake(970 - textSize.width, 736, 24, 24);
        [self.view addSubview:_syncImage];
        //NSLog(@"image x: %f %f",_syncImage.frame.origin.x,_syncImage.frame.origin.y);
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
