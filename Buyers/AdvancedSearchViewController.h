//
//  AdvancedSearchViewController.h
//  Buyers
//
//  Created by Web Development on 27/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SchDropDown.h"
#import "SchTextField.h"

@protocol AdvancedSearchViewControllerDelegate
-(IBAction)searchProducts:(id)sender;
@end

@interface AdvancedSearchViewController : UIViewController {
    id<AdvancedSearchViewControllerDelegate> _delegate;
}
@property (weak, nonatomic) IBOutlet SchTextField *productName;
@property (weak, nonatomic) IBOutlet SchDropDown *productCategory;
@property (weak, nonatomic) IBOutlet SchDropDown *productBrand;
@property (weak, nonatomic) IBOutlet SchDropDown *productSupplier;
@property (weak, nonatomic) IBOutlet SchDropDown *productMaterial;
@property (weak, nonatomic) IBOutlet SchDropDown *productColour;
@property (weak, nonatomic) IBOutlet UISegmentedControl *productType;
@property (weak, nonatomic) IBOutlet UISlider *productPrice;

@property (nonatomic, retain) id<AdvancedSearchViewControllerDelegate> delegate;
- (IBAction)searchProducts:(id)sender;

@end
