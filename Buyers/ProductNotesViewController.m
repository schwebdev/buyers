//
//  ProductNotesViewController.m
//  Buyers
//
//  Created by Web Development on 26/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ProductNotesViewController.h"
#import "AppDelegate.h"

@interface ProductNotesViewController ()

@end

@implementation ProductNotesViewController

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
    _productNotes.delegate = self;
    self.preferredContentSize = CGSizeMake(700.0, 450.0);
    _productError.hidden = true;
    _productNotes.text = _product.productNotes;
    _productNotes.layer.borderWidth=1;
    _productNotes.layer.borderColor  = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveProductNotes:(id)sender {
    _productError.hidden = true;
    [_productNotes resignFirstResponder];
    //get user's full name from app settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
    
    if ([_productNotes.text isEqualToString:(@"")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter some notes for this product!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else  if([creatorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length ==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"Please add your name to app settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } else {
        
        //save the product notes
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        
        _product.productNotes = _productNotes.text;
        _product.productLastUpdateDate = [NSDate date];
        _product.productLastUpdatedBy = creatorName;
        
        if(![managedContext save:&error]) {
            NSLog(@"Could not save collection notes: %@", [error localizedDescription]);
            //display this in uilabel in red as per mocks
            _productError.text = @" sorry, an error occurred";
            _productError.hidden = false;
        } else {
            
            //NSLog(@"notes saved: %@",_product.productNotes);
            
            NSDictionary *productData = [NSDictionary dictionaryWithObject:_product.objectID forKey:@"productID"];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ProductNotesSaved" object:self userInfo:productData]];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        }
        
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
