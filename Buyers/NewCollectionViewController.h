//
//  NewCollectionViewController.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewCollectionViewControllerDelegate
-(IBAction)saveNewCollection:(id)sender;
@end

@interface NewCollectionViewController : UIViewController <UITextFieldDelegate> {
    id<NewCollectionViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) id<NewCollectionViewControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet UITextField *collectionName;
@property(nonatomic,retain) IBOutlet UILabel *collectionError;

-(IBAction)saveNewCollection:(id)sender;
-(IBAction)textFieldDoneEditing:(id)sender;

@end
