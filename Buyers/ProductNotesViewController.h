//
//  ProductNotesViewController.h
//  Buyers
//
//  Created by Web Development on 26/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@protocol ProductNotesViewControllerDelegate
-(IBAction)saveProductNotes:(id)sender;
@end


@interface ProductNotesViewController : UIViewController<UITextViewDelegate> {
    id<ProductNotesViewControllerDelegate> _delegate;
}

@property (weak, nonatomic) Product *product;
@property (nonatomic, retain) id<ProductNotesViewControllerDelegate> delegate;

@property(nonatomic,retain) IBOutlet UITextView *productNotes;
@property(nonatomic,retain) IBOutlet UILabel *productError;

-(IBAction)saveProductNotes:(id)sender;

@end
