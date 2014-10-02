//
//  CollectionNotesViewController.h
//  Buyers
//
//  Created by Web Development on 23/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Collection.h"

@protocol CollectionNotesViewControllerDelegate
-(IBAction)saveCollectionNotes:(id)sender;
@end


@interface CollectionNotesViewController : UIViewController<UITextViewDelegate> {
    id<CollectionNotesViewControllerDelegate> _delegate;
}

@property (weak, nonatomic) Collection *collection;
@property (nonatomic, retain) id<CollectionNotesViewControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet UITextView *collectionNotes;
@property(nonatomic,retain) IBOutlet UILabel *collectionError;

-(IBAction)saveCollectionNotes:(id)sender;



@end
