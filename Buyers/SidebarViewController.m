//
//  SidebarViewController.m
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"

@interface SidebarViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation SidebarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    

    _menuItems = @[@"menu1", @"menu2", @"menu3", @"menu4", @"menu5", @"menu6", @"menu7",@"menu8"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) homeClick:(id)sender {
    
    [self.revealViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1];
    switch (indexPath.row) {
        case 2:
            
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if(indexPath.row == 0) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[NSString stringWithFormat:@"home click %@",[_menuItems objectAtIndex:indexPath.row]] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        //[alert show];
        
        [self.revealViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    //destViewController.title = [[_menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers:@[dvc] animated:NO];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        };
    }
}

@end
