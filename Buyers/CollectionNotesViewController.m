//
//  CollectionNotesViewController.m
//  Buyers
//
//  Created by Web Development on 23/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "CollectionNotesViewController.h"
#import "AppDelegate.h"

@interface CollectionNotesViewController ()

@end

@implementation CollectionNotesViewController



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
    _collectionNotes.delegate = self;
    self.preferredContentSize = CGSizeMake(700.0, 450.0);
    _collectionError.hidden = true;
    _collectionNotes.text = _collection.collectionNotes;
    _collectionNotes.layer.borderWidth=1;
    _collectionNotes.layer.borderColor  = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveCollectionNotes:(id)sender {
    _collectionError.hidden = true;
    [_collectionNotes resignFirstResponder];
    if ([_collectionNotes.text isEqualToString:(@"")]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter some notes for this collection!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else if (_collectionNotes.text.length > 300) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Only a maximum of 300 characters allowed, please remove some characters!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } else {
        
        
        
            //save the new collection
            NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            NSError *error;
            
            _collection.collectionNotes = _collectionNotes.text;
           _collection.collectionLastUpdateDate = [NSDate date];
        
            //get user's full name from app settings
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *creatorName = [defaults objectForKey:@"username"];
            _collection.collectionLastUpdatedBy = creatorName;
        
            if(![managedContext save:&error]) {
                NSLog(@"Could not save collection notes: %@", [error localizedDescription]);
                //display this in uilabel in red as per mocks
                _collectionError.text = @" sorry, an error occurred";
                _collectionError.hidden = false;
            } else {
                
                //NSLog(@"notes saved: %@",_collection.collectionNotes);
                
                NSDictionary *collectionData = [NSDictionary dictionaryWithObject:_collection.objectID forKey:@"collectionID"];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"CollectionNotesSaved" object:self userInfo:collectionData]];
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
