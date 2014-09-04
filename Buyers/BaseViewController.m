//
//  ReportsViewController.m
//  Buyers
//
//  Created by webdevelopment on 08/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"
#import "SWRevealViewController.h"
#import "SidebarViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

+ (UIView *)genNavWithTitle:(NSString*)title1 title2:(NSString*)title2 image:(NSString*)image {
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, 680, 100)];
    //navView.backgroundColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    
    UIImageView *navImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    navImage.frame = CGRectMake(1, 5, 30, 30);
    //self.navigationItem.titleView = navImage;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 500, 25)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
    [titleLabel setText:title1];
    
    UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(35, 12, 500, 50)];
    titleLabel2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0f];
    titleLabel2.textColor = [UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
    [titleLabel2 setText:title2];
    
    
    [navView addSubview:navImage];
    [navView addSubview:titleLabel];
    [navView addSubview:titleLabel2];
    
    return navView;
}

+ (UIView *)genTopBarWithTitle:(NSString*)title {
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 40, 1024, 45)];
    topBar.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1];
    
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0, 0, 1024, 2);
    topBorder.backgroundColor = [UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f].CGColor;
    [topBar.layer addSublayer:topBorder];
    
    UILabel *topBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 0, 500, 25)];
    topBarLabel.font = [UIFont fontWithName:@"HelveticaNeue-bold" size:12.0f];
    [topBarLabel setText:title];
    [topBar addSubview:topBarLabel];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 25, 1024, 20)];
    bottomBar.backgroundColor = [UIColor whiteColor];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 19, 1024, 1);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [bottomBar.layer addSublayer:bottomBorder];
    
    [topBar addSubview:bottomBar];
    return topBar;
}


- (UIButton *)setMenuButton:(NSInteger)index title:(NSString*)title {
    
    SidebarViewController *sidebar = (SidebarViewController*)self.revealViewController.rearViewController;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"schuhMenuIcon-S.png"] forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"rightArrowButtonBG.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    switch (index) {
        case 1:
            button.frame = CGRectMake(20, 40, 200, 60);
            if(sidebar.menuItem1 != nil) {
                [sidebar.menuItem1 removeFromSuperview];
            }
            sidebar.menuItem1 = nil;
            sidebar.menuItem1 = button;
            break;
        case 2:
            button.frame = CGRectMake(20, 110, 200, 60);
            if(sidebar.menuItem2 != nil) {
                [sidebar.menuItem2 removeFromSuperview];
            }
            sidebar.menuItem2 = nil;
            sidebar.menuItem2 = button;
            break;
        case 3:
            button.frame = CGRectMake(20, 180, 200, 60);
            if(sidebar.menuItem3 != nil) {
                [sidebar.menuItem3 removeFromSuperview];
            }
            sidebar.menuItem3 = nil;
            sidebar.menuItem3 = button;
            break;
            
        default:
            break;
    }
    [sidebar.view addSubview:button];
    
    return button;
}

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
    
    
    [self.navigationController.navigationBar setBounds:CGRectMake(0, 0, 1024, 124)];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    //[self setAutomaticallyAdjustsScrollViewInsets:NO];
    //[self setEdgesForExtendedLayout:UIRectEdgeNone];
        
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //clear menu buttons
    SidebarViewController *sidebar = (SidebarViewController*)self.revealViewController.rearViewController;
    
    if(sidebar.menuItem1 != nil) {
        [sidebar.menuItem1 removeFromSuperview];
    }
    sidebar.menuItem1 = nil;
    if(sidebar.menuItem2 != nil) {
        [sidebar.menuItem2 removeFromSuperview];
    }
    sidebar.menuItem2 = nil;
    if(sidebar.menuItem3 != nil) {
        [sidebar.menuItem3 removeFromSuperview];
    }
    sidebar.menuItem3 = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    //[self.view setFrame:CGRectMake(0, 124, self.view.frame.size.width,708)];
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setBounds:CGRectMake(0, 0, 1024, 124)];
    //[self.view setFrame:CGRectMake(0, 124, self.view.frame.size.width,708)];
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
