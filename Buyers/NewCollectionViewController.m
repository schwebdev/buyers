//
//  NewCollectionViewController.m
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "NewCollectionViewController.h"
#import "AppDelegate.h"
#import "Collection.h"

@interface NewCollectionViewController ()

@end

@implementation NewCollectionViewController

@synthesize collectionName = _collectionName;
@synthesize collectionError = _collectionError;
@synthesize delegate = _delegate;

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
    _collectionName.delegate = self;
    self.preferredContentSize = CGSizeMake(340.0, 250.0);
    _collectionError.hidden = true;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveNewCollection:(id)sender {
    _collectionError.hidden = true;
    [_collectionName resignFirstResponder];
    if ([self.collectionName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a name for this collection!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
       
         //get user's full name from app settings
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSString *creatorName = [defaults objectForKey:@"username"];
        
        if([creatorName length] ==0) {
            _collectionError.text = @" please add your name to app settings";
            _collectionError.hidden = false;
        } else {
        
        //save the new collection
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:managedContext];
        
        collection.collectionName = _collectionName.text;
        collection.collectionCreator = creatorName;
        collection.collectionCreationDate = [NSDate date];
         
         if(![managedContext save:&error]) {
             NSLog(@"Could not save collection: %@", [error localizedDescription]);
             //display this in uilabel in red as per mocks
             _collectionError.text = @" sorry, an error occurred";
             _collectionError.hidden = false;
         } else {
        
             //clear text field
             _collectionName.text = @"";
             //go to new collection from parent view by sending a notification
             NSDictionary *collectionData = [NSDictionary dictionaryWithObject:collection.objectID forKey:@"collectionID"];
             [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToNewCollection" object:self userInfo:collectionData]];
             [[NSNotificationCenter defaultCenter] removeObserver:self];
            
         }
        }
        
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_collectionName resignFirstResponder];
    return YES;
}
- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
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
