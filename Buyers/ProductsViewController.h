//
//  AddProductsViewController.h
//  Buyers
//
//  Created by Web Development on 08/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Collection.h"
#import "SchTextField.h"
#import "SchDropDown.h"
#import "BaseViewController.h"
@interface ProductsViewController : BaseViewController <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet SchTextField *txtNewCollection;
@property (weak, nonatomic) Collection *collection;
@property(nonatomic,retain) IBOutlet UIButton *clearAll;
@property(nonatomic,retain) IBOutlet UIButton *saveSelection;
@property (weak, nonatomic) IBOutlet SchDropDown *collectionList;

-(IBAction)saveProducts:(id)sender;
-(IBAction)clearAll:(id)sender;

@end
