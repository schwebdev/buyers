//
//  ProductViewController.m
//  Buyers
//
//  Created by Web Development on 22/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ProductViewController.h"
#import "SWRevealViewController.h"
#import "BaseViewController.h"
#import "Brand.h"
#import "ProductCategory.h"
#import "Supplier.h"
#import "Colour.h"
#import "Material.h"
#import "AppDelegate.h"
#import "Sync.h"


static const float kPageWidth = 680.0;

@interface ProductViewController ()

@end

@implementation ProductViewController

@synthesize collection = _collection;
@synthesize product = _product;
@synthesize displayNotesPopover = _displayNotesPopover;
@synthesize productNotes = _productNotes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)saveProductNotes:(id)sender {
    //protocol method callback - empty to avoid warning
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editImageButton.hidden = YES;
    self.productName_edit.hidden = YES;
    self.productPrice_edit.hidden=YES;
    
    self.productCategory_edit.hidden=YES;
    self.productBrand_edit.hidden=YES;
    self.productSupplier_edit.hidden=YES;
    self.productColour_edit.hidden=YES;
    self.productMaterial_edit.hidden=YES;
    
    
    
    
     //if custom product need to hide label content and replace with textfields and dropdown menus.  Also need to allow the image to be changed
    
     self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"collection" title2:_collection.collectionName image:@"homePaperClipLogo.png"];
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"Product Detail"]];
    
    UIView *tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 65)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    UIButton *saveProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [saveProductButton setTitle:@"save" forState:UIControlStateNormal];
    saveProductButton.frame = CGRectMake(720, 620, 100, 50);
    [saveProductButton addTarget:self action:@selector(saveCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    saveProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    saveProductButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    UIButton *deleteProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [deleteProductButton setTitle:@"delete" forState:UIControlStateNormal];
    deleteProductButton.frame = CGRectMake(900, 620, 100, 50);
    [deleteProductButton addTarget:self action:@selector(deleteCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    deleteProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    deleteProductButton.backgroundColor = [UIColor redColor]; //[UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    _notesButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_notesButton setTitle:@"notes" forState:UIControlStateNormal];
    _notesButton.frame = CGRectMake(0, 0, 150, 50);
    _notesButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    _notesButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:133.0/255.0 blue:178.0/255.0 alpha:1];
    [_notesButton addTarget:self action:@selector(displayNotesPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    //only add save, notes and edit image button to a custom product and don't show product code
    if([_product.productCode  isEqual:@""] || [_product.productCode  isEqual:@"0000000000"]) {
    [self.view addSubview:deleteProductButton];
    [self.view addSubview:saveProductButton];
    self.editImageButton.hidden = NO;
        _productCodeLabel.hidden = YES;
        _productCode.hidden = YES;
        self.productName_edit.hidden = NO;
        self.productPrice_edit.hidden=NO;
        self.productCategory_edit.hidden=NO;
        self.productBrand_edit.hidden=NO;
        self.productSupplier_edit.hidden=NO;
        self.productColour_edit.hidden=NO;
        self.productMaterial_edit.hidden=NO;
        
        
        self.productName.hidden = YES;
        self.productPrice.hidden=YES;
        self.productCategory.hidden=YES;
        self.productBrand.hidden=YES;
        self.productSupplier.hidden=YES;
        self.productColour.hidden=YES;
        self.productMaterial.hidden=YES;
        
        
        //categories drop down
        [self.productCategory_edit setListItems:(NSMutableArray *)[Sync getTable:@"ProductCategory" sortWith:@"categoryName"] withName:@"categoryName" withValue:@"categoryName"];
        //brand drop down
        [self.productBrand_edit setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
        //supplier drop down
        [self.productSupplier_edit setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
        //colour drop down
        [self.productColour_edit setListItems:(NSMutableArray *)[Sync getTable:@"Colour" sortWith:@"colourName"] withName:@"colourName" withValue:@"colourCode"];
        //material drop down
        [self.productMaterial_edit setListItems:(NSMutableArray *)[Sync getTable:@"Material" sortWith:@"materialName"] withName:@"materialName" withValue:@"materialCode"];
        
    [tools addSubview:_notesButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    }
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(kPageWidth, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];

    
    UILabel *productsInfo = [[UILabel alloc] init];
    productsInfo.text = @"info";
    productsInfo.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsInfo.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsInfo.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsInfo.numberOfLines = 1;
    CGRect productsInfoTitle = CGRectMake((kPageWidth+20.0), 92.0, 300, 30.0); //kPageWidth, 70.0, 300, 30.0
    productsInfo.frame = productsInfoTitle;
    
    [self.view addSubview:productsInfo];
    
   
    UIImage *image = [UIImage imageWithData:(_product.productImageData)];
    [self.productImage setImage:image];
    
    self.productName.text = _product.productName;
    self.productCode.text = _product.productCode;
    self.productCategory.text = _product.category.categoryName;
    self.productBrand.text = _product.brand.brandName;
    self.productSupplier.text = _product.supplier.supplierName;
    self.productColour .text = _product.colour.colourName;
    self.productMaterial.text = _product.material.materialName;
    
    
    
    NSNumberFormatter *formatPrice = [[NSNumberFormatter alloc] init];
    [formatPrice setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatPrice setDecimalSeparator:@"###.##"];
    self.productPrice.text = [NSString stringWithFormat:@"£%@",[formatPrice stringFromNumber:_product.productPrice]];
    
    
    self.productName_edit.text=_product.productName;
    self.productPrice_edit.text=[NSString stringWithFormat:@"£%@",[formatPrice stringFromNumber:_product.productPrice]];
    
    [self.productCategory_edit setSelectedValue:_product.category.categoryName];
    [self.productBrand_edit setSelectedValue:_product.brand.brandName];
    
    
    //add notification to listen for the collection being saved and call method to close the pop over
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productNotesSaved:) name:@"ProductNotesSaved" object:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)deleteCustomProduct:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                    message:@"Are you sure you wish to delete this custom product?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                          
                                          otherButtonTitles:@"Yes",nil];
    [alert show];
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex ==1) {
        
        // Delete the product
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        
        //shouldn't need to delete from collection or ordering if the object itself is deleted
        [managedContext deleteObject:_product];
        
        if (![managedContext save:&error]) {
            NSLog(@"Could not delete custom product: %@", [error localizedDescription]);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)saveCustomProduct:(id)sender
{
    //validate fields
    
    //save the product changes
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    //_product.productName = self.txtProductName.text;
    //_product.category =
    //_product.brand =
    //_product.supplier =
    //_product.colour =
    //_product.material =
    //_product.productPrice =
    //_product.productImageData = //this may be saved when the image is changed already
    
    if(![managedContext save:&error]) {
        NSLog(@"Could not save product: %@", [error localizedDescription]);

    }
    
    //alert user that product has been saved
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product" message:@"The product changes have been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}
- (void)productNotesSaved:(NSNotification *)notification
{
    [self.displayNotesPopover dismissPopoverAnimated:YES];
    
    //NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    //NSError *error;
    
    //NSManagedObjectID *collectionID = [[notification userInfo] valueForKey:@"productID"];
    //Product *product = (Product *) [managedContext existingObjectWithID:productID error:&error];
    // NSLog(@"notes *: %@", product.productNotes);
    
    
}
- (IBAction)displayNotesPopover:(id)sender {
    
    if (_productNotes== nil) {
        self.productNotes = [self.storyboard instantiateViewControllerWithIdentifier:@"productNotes"];
        _productNotes.delegate = self;
        _productNotes.product = _product;
        
        self.displayNotesPopover = [[UIPopoverController alloc] initWithContentViewController:_productNotes];
    }
    
    [self.displayNotesPopover presentPopoverFromRect:_notesButton.bounds  inView:_notesButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    
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

- (IBAction)editImage:(id)sender {
}
@end
