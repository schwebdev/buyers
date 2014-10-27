//
//  AdvancedSearchViewController.m
//  Buyers
//
//  Created by Web Development on 27/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "AdvancedSearchViewController.h"
#import "Sync.h"

@interface AdvancedSearchViewController ()

@end

@implementation AdvancedSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.preferredContentSize = CGSizeMake(700.0, 450.0);
    
    //categories drop down
    [self.productCategory setListItems:(NSMutableArray *)[Sync getTable:@"ProductCategory" sortWith:@"categoryName"] withName:@"categoryName" withValue:@"category2Ref"];
    //brand drop down
    [self.productBrand setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    //supplier drop down
    [self.productSupplier setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    //colour drop down
    [self.productColour setListItems:(NSMutableArray *)[Sync getTable:@"Colour" sortWith:@"colourName"] withName:@"colourName" withValue:@"colourRef"];
    //material drop down
    [self.productMaterial setListItems:(NSMutableArray *)[Sync getTable:@"Material" sortWith:@"materialName"] withName:@"materialName" withValue:@"materialRef"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)searchProducts:(id)sender {
    
    //load all the search data into the dictionary to pass to the products view controller
    
 
    NSMutableDictionary *searchData = [[NSMutableDictionary alloc]initWithCapacity:8];
   if([self.productName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
       
       [searchData setObject:self.productName.text forKey:@"productName"];
      
    }
    if([self.productCategory.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [searchData setObject:self.productCategory.getSelectedValue forKey:@"productCategoryRef"];
    }
    if([self.productBrand.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [searchData setObject:self.productBrand.getSelectedValue forKey:@"productBrandRef"];
    }
    if([self.productSupplier.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [searchData setObject:self.productSupplier.getSelectedValue forKey:@"productSupplierCode"];
    }
    if([self.productColour.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [searchData setObject:self.productColour.getSelectedValue forKey:@"productColourRef"];
    }

    if([self.productMaterial.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        [searchData setObject:self.productMaterial.getSelectedValue forKey:@"productMaterialRef"];
    }
   
    [searchData setObject:[self.productType titleForSegmentAtIndex:self.productType.selectedSegmentIndex] forKey:@"productType"];
    
    if(self.productPrice.value > 1) {
        NSString *sliderValue = [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:(int)round(self.productPrice.value)]];
        [searchData setObject:sliderValue forKey:@"productPrice"];
    }
    
    
    


    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ProductAdvancedSearch" object:self userInfo:searchData]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
