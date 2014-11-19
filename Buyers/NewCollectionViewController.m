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
#import "Brand.h"
#import "Sync.h"

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
    self.preferredContentSize = CGSizeMake(340.0, 380.0);
    _collectionError.hidden = true;
    
    //brand drop down
    [self.collectionBrandRef setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveNewCollection:(id)sender {
    _collectionError.hidden = true;
    [_collectionName resignFirstResponder];
    
    
    _isValid = YES;
    NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:@""];
    //get user's full name from app settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
    
    if([creatorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length ==0) {
        _isValid = NO;
        [errorMsg appendString:@"please add your name to app settings\n"];
    }
    if([self.collectionName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a name for this collection\n"];
    }
    if(self.collectionName.text.length > 255) {
        _isValid = NO;
        [errorMsg appendString:@"only a maximum of 255 characters allowed, please remove some characters!\n"];
    }
    if([self.collectionBrandRef.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a brand\n"];
    }
    
    if(_isValid) {
       
        //save the new collection
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
        NSError *error;
        Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:managedContext];
        collection.collectionCreator= creatorName;
        collection.collectionLastUpdatedBy = creatorName;
        collection.collectionCreationDate = [NSDate date];
        collection.collectionLastUpdateDate = [NSDate date];
        collection.collectionName = self.collectionName.text;
        
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.collectionBrandRef.getSelectedObject[@"IDURI"]];
        Brand *brandElement = (Brand*)[managedContext objectWithID:c];
        collection.collectionBrandRef  = brandElement.brandRef;
        
        //add unique identifier for custom product syncing
        NSString *UUID = [[NSUUID UUID] UUIDString];
        collection.collectionGUID = UUID;
        
         if(![managedContext save:&error]) {
             NSLog(@"Could not save collection: %@", [error localizedDescription]);
             //display this in uilabel in red as per mocks
             _collectionError.text = @" sorry, an error occurred";
             _collectionError.hidden = false;
         } else {
        
             //clear text field
             _collectionName.text = @"";
             _collectionBrandRef.text = @"";
             //go to new collection from parent view by sending a notification
             NSDictionary *collectionData = [NSDictionary dictionaryWithObject:collection.objectID forKey:@"collectionID"];
             [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"GoToNewCollection" object:self userInfo:collectionData]];
             [[NSNotificationCenter defaultCenter] removeObserver:self];
            
         }
        
    } else {
       
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];


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
