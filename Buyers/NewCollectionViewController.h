//
//  NewCollectionViewController.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SchDropDown.h"
#import "SchTextField.h"

@protocol NewCollectionViewControllerDelegate
-(IBAction)saveNewCollection:(id)sender;
@end

@interface NewCollectionViewController : UIViewController <UITextFieldDelegate> {
    id<NewCollectionViewControllerDelegate> _delegate;
}
@property BOOL isValid;
@property (nonatomic, retain) id<NewCollectionViewControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet SchTextField *collectionName;
@property(nonatomic,retain) IBOutlet UILabel *collectionError;
@property (weak, nonatomic) IBOutlet SchDropDown *collectionBrandRef;

-(IBAction)saveNewCollection:(id)sender;
-(IBAction)textFieldDoneEditing:(id)sender;

@end
