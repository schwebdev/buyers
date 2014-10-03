//
//  AddNewProductViewController.h
//  Buyers
//
//  Created by Web Development on 26/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SchTextField.h"
#import "SchDropDown.h"

@interface AddNewProductViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
@property BOOL newMedia;
@property BOOL isValid;
@property BOOL isDirtyImage;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *cameraView;
- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
@property (weak, nonatomic) IBOutlet SchTextField *txtProductName;
- (IBAction)ddlCategoryList:(id)sender;
@property (weak, nonatomic) IBOutlet SchTextField *txtProductPrice;

@property (weak, nonatomic) IBOutlet SchTextField *txtProductCode;
@property (weak, nonatomic) IBOutlet SchDropDown *categoryList;
@property (weak, nonatomic) IBOutlet SchDropDown *brandList;
@property (weak, nonatomic) IBOutlet SchDropDown *supplierList;
@property (weak, nonatomic) IBOutlet SchDropDown *colourList;
@property (weak, nonatomic) IBOutlet SchDropDown *materialList;
- (void)saveCustomProduct:(id)sender;

@end
