//
//  ProductViewController.h
//  Buyers
//
//  Created by Web Development on 22/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"
#import "Collection.h"
#import "ProductNotesViewController.h"

@interface ProductViewController : UIViewController <ProductNotesViewControllerDelegate> {
    UIPopoverController *_displayNotesPopover;
    ProductNotesViewController *_productNotes;
}
@property (weak, nonatomic) IBOutlet UIButton *editImageButton;

@property (nonatomic, retain) ProductNotesViewController *productNotes;
@property (nonatomic, retain) UIPopoverController *displayNotesPopover;
@property (weak, nonatomic) Collection *collection;
@property (weak, nonatomic) Product *product;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productCategory;
@property (weak, nonatomic) IBOutlet UILabel *productBrand;
@property (weak, nonatomic) IBOutlet UILabel *productSupplier;
@property (weak, nonatomic) IBOutlet UILabel *productColour;
@property (weak, nonatomic) IBOutlet UILabel *productMaterial;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property(nonatomic,retain) UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UILabel *productCode;
@property (weak, nonatomic) IBOutlet UILabel *productCodeLabel;

- (IBAction)editImage:(id)sender;
- (void)saveCustomProduct:(id)sender;
- (void)deleteCustomProduct:(id)sender;
-(IBAction)saveProductNotes:(id)sender;
@end
