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
#import "ProductOrder.h"
#import "Supplier.h"
#import "Colour.h"
#import "Material.h"
#import "AppDelegate.h"
#import "Sync.h"
#import "CameraRollViewController.h"
#import "UIImage+Resize.h"

static const float kPageWidth = 680.0;

@interface ProductViewController () {
    UILabel *updateInfo;
}

@property UIImagePickerController *imagePicker;
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
    
    self.productName_edit.hidden = YES;
    self.productPrice_edit.hidden=YES;
    self.productCategory_edit.hidden=YES;
    self.productBrand_edit.hidden=YES;
    self.productSupplier_edit.hidden=YES;
    self.productColour_edit.hidden=YES;
    self.productMaterial_edit.hidden=YES;
    
    self.btnUseCamera.hidden=YES;
    self.btnUseCameraRoll.hidden=YES;
    
     //if custom product need to hide label content and replace with textfields and dropdown menus.  Also need to allow the image to be changed
    
    NSString *pageName = _collection.collectionName;
    NSString *pageTitle = @"collection";
    if(_collection == nil) {
        pageTitle = @"product";
        pageName = _product.productName;
    }
     self.navigationItem.titleView = [BaseViewController genNavWithTitle:pageTitle title2:pageName image:@"homePaperClipLogo.png"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd MMMM yyyy HH:mm"];
    NSDate *creationDate = _product.productCreationDate;
    NSString *formatCreationDate = [dateFormat stringFromDate:creationDate];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"Created on %@ by %@", formatCreationDate, _product.productCreator]]];
    
    UIView *tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 65)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    UIButton *saveProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [saveProductButton setTitle:@"save" forState:UIControlStateNormal];
    saveProductButton.frame = CGRectMake(720, 629, 100, 50);
    [saveProductButton addTarget:self action:@selector(saveCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    saveProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    saveProductButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    UIButton *deleteProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [deleteProductButton setTitle:@"delete" forState:UIControlStateNormal];
    deleteProductButton.frame = CGRectMake(900, 629, 100, 50);
    [deleteProductButton addTarget:self action:@selector(deleteCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    deleteProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    deleteProductButton.backgroundColor = [UIColor redColor];
    
    _notesButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_notesButton setTitle:@"notes" forState:UIControlStateNormal];
    _notesButton.frame = CGRectMake(0, 0, 150, 50);
    _notesButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    _notesButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:133.0/255.0 blue:178.0/255.0 alpha:1];
    [_notesButton addTarget:self action:@selector(displayNotesPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    //only add save and edit image button to a custom product and don't show product code
    if([_product.productCode  isEqual:@""] || [_product.productCode  isEqual:@"0000000000"]) {
    [self.view addSubview:deleteProductButton];
    [self.view addSubview:saveProductButton];
        
        
    //self.editImageButton.hidden = NO;
        self.btnUseCamera.hidden=NO;
        self.btnUseCameraRoll.hidden=NO;
        _productCodeLabel.hidden = YES;
        _productCode.hidden = YES;
        self.productName_edit.hidden = NO;
        self.productPrice_edit.hidden=NO;
        self.productPrice_edit.delegate = self;
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
        
        
        
    
    }
    [tools addSubview:_notesButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
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
    
    updateInfo = [[UILabel alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy HH:mm"];
    NSDate *updateDate = _product.productLastUpdateDate;
    NSString *formatDate = [dateFormat stringFromDate:updateDate];
    updateInfo.text = [NSString stringWithFormat: @"Last updated on %@ by %@",formatDate, _product.productLastUpdatedBy];
    updateInfo.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    updateInfo.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    updateInfo.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    updateInfo.numberOfLines = 1;
    CGRect updateInfoTitle = CGRectMake(210.0, 58.0, 500, 30.0);
    updateInfo.frame = updateInfoTitle;
    
    [self.view addSubview:updateInfo];

    
    //categories drop down
    [self.productCategory_edit setListItems:(NSMutableArray *)[Sync getTable:@"ProductCategory" sortWith:@"categoryName"] withName:@"categoryName" withValue:@"category2Ref"];
    //brand drop down
    [self.productBrand_edit setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    //supplier drop down
    [self.productSupplier_edit setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    //colour drop down
    [self.productColour_edit setListItems:(NSMutableArray *)[Sync getTable:@"Colour" sortWith:@"colourName"] withName:@"colourName" withValue:@"colourRef"];
    //material drop down
    [self.productMaterial_edit setListItems:(NSMutableArray *)[Sync getTable:@"Material" sortWith:@"materialName"] withName:@"materialName" withValue:@"materialRef"];
    
    UIImage *image = [UIImage imageWithData:(_product.productImageData)];
    [self.productImage setImage:image];
    
    NSNumberFormatter *formatPrice = [[NSNumberFormatter alloc] init];
    [formatPrice setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatPrice setMaximumFractionDigits:2];
    [formatPrice setMinimumFractionDigits:2];
    
    self.productName_edit.text=_product.productName;
    self.productPrice_edit.text=[formatPrice stringFromNumber:_product.productPrice];
    
    [self.productCategory_edit setSelectedValue:[NSString stringWithFormat:@"%@",_product.productCategoryRef]];
    [self.productBrand_edit setSelectedValue:[NSString stringWithFormat:@"%@",_product.productBrandRef]];
    [self.productSupplier_edit setSelectedValue:[NSString stringWithFormat:@"%@",_product.productSupplierCode]];
    [self.productColour_edit setSelectedValue:[NSString stringWithFormat:@"%@",_product.productColourRef]];
    [self.productMaterial_edit setSelectedValue:[NSString stringWithFormat:@"%@",_product.productMaterialRef]];
    
    self.productName.text = _product.productName;
    self.productCode.text = _product.productCode;
    self.productPrice.text = [NSString stringWithFormat:@"£%@",[formatPrice stringFromNumber:_product.productPrice]];

    //set labels for schuh product to the value of the editable field dropdown value
    self.productCategory.text = [self.productCategory_edit getSelectedText];
    self.productBrand.text = [self.productBrand_edit getSelectedText];
    self.productSupplier.text =  [self.productSupplier_edit getSelectedText];
    self.productColour .text = [self.productColour_edit getSelectedText];
    self.productMaterial.text = [self.productMaterial_edit getSelectedText];
    
    //add notification to listen for the collection being saved and call method to close the pop over
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productNotesSaved:) name:@"ProductNotesSaved" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_selectedImage !=nil){
        self.productImage.image = _selectedImage;
        //_isDirtyImage = YES;
    }
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
        
        //need to remove the object from every relationship prior to deleting otherwise the object is set to nil and causes an error
        /*if([_product.brand.productBrand containsObject:_product]) {
            [_product.brand removeProductBrandObject:_product];
        }
        if([_product.category.productCategory containsObject:_product]) {
        [_product.category removeProductCategoryObject:_product];
        }
        if([_product.supplier.productSupplier containsObject:_product]) {
            [_product.supplier removeProductSupplierObject:_product];
        }
        if([_product.colour.productColour containsObject:_product]) {
            [_product.colour removeProductColourObject:_product];
        }
        if([_product.material.productMaterial containsObject:_product]) {
            [_product.material removeProductMaterialObject:_product];
        }*/
        
        /*
         NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"products contains %@",product];
         
         NSFetchRequest *requestCollections = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
         NSArray *collections = [backgroundContext executeFetchRequest:requestCollections error:&error];
         NSArray *findCollections = [collections filteredArrayUsingPredicate:predicate2];

         */
        ProductOrder *po = (ProductOrder*)_product;
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"products contains %@",_product];
        NSFetchRequest *requestCollections = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
        NSArray *collections = [managedContext executeFetchRequest:requestCollections error:&error];
        NSArray *foundCollections = [collections filteredArrayUsingPredicate:predicate];
        for (Collection *collection in foundCollections) {
            
                [collection removeProductsObject:po];
                collection.collectionLastUpdateDate = [NSDate date];
                //get user's full name from app settings
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *creatorName = [defaults objectForKey:@"username"];
                collection.collectionLastUpdatedBy = creatorName;
        }
        NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"orderProduct = %@",po];
        NSFetchRequest *requestProductOrders = [[NSFetchRequest alloc] initWithEntityName:@"ProductOrder"];
        NSArray *orders = [managedContext executeFetchRequest:requestProductOrders error:&error];
        NSArray *foundOrders = [orders filteredArrayUsingPredicate:predicate2];
        for (ProductOrder *pOrder in foundOrders) {
            [managedContext deleteObject:pOrder];
        }
        
        //flag for deletion
        //get user's full name from app settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *creatorName = [defaults objectForKey:@"username"];
        
        _product.productDeleted =  [NSNumber numberWithBool:YES];
        _product.productLastUpdateDate = [NSDate date];
        _product.productLastUpdatedBy = creatorName;
        _product.productDeleted =  [NSNumber numberWithBool:YES];
        
        if (![managedContext save:&error]) {
            NSLog(@"Could not delete custom product: %@", [error localizedDescription]);
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}

- (void)saveCustomProduct:(id)sender
{
    
    //save the product changes
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];

    NSError *error;
    
    _isValid = YES;
    NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:@""];
    
    
    //get user's full name from app settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
  
     if([creatorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length ==0) {
         _isValid = NO;
         [errorMsg appendString:@"please add your name to app settings\n"];

     } else {
         _product.productLastUpdatedBy = creatorName;
     }
    
    if([self.productName_edit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a product name\n"];
    } else {
        _product.productName = self.productName_edit.text;
    }
    
    if([self.productCategory_edit.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a category\n"];
        _product.productCategoryRef = nil;
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.productCategory_edit.getSelectedObject[@"IDURI"]];
        ProductCategory *categoryElement = (ProductCategory*)[managedContext objectWithID:c];
        _product.productCategoryRef =  categoryElement.category2Ref;
    }
    
    if([self.productBrand_edit.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a brand\n"];
         _product.productBrandRef = nil;
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.productBrand_edit.getSelectedObject[@"IDURI"]];
        Brand *brandElement = (Brand*)[managedContext objectWithID:c];
        _product.productBrandRef = brandElement.brandRef;
        
    }
    
    if([self.productSupplier_edit.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
       // _isValid = NO;
       // [errorMsg appendString:@"please select a supplier\n"];
         _product.productSupplierCode = nil;
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.productSupplier_edit.getSelectedObject[@"IDURI"]];
        Supplier *supplierElement = (Supplier*)[managedContext objectWithID:c];
        _product.productSupplierCode = supplierElement.supplierCode;
    }
    
    if([self.productColour_edit.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a colour\n"];
         _product.productColourRef = nil;
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.productColour_edit.getSelectedObject[@"IDURI"]];
        Colour *colourElement = (Colour*)[managedContext objectWithID:c];
        _product.productColourRef = colourElement.colourRef;
        //NSLog(@"colour: %@", _product.colour.colourName);
        //pColour = [self.colourList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.productMaterial_edit.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
       // _isValid = NO;
        //[errorMsg appendString:@"please select a material\n"];
         _product.productMaterialRef = nil;
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.productMaterial_edit.getSelectedObject[@"IDURI"]];
        Material *materialElement = (Material*)[managedContext objectWithID:c];
        _product.productMaterialRef = materialElement.materialRef;
        //pMaterial = [self.materialList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.productPrice_edit.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please enter a price\n"];
         _product.productPrice =  [NSNumber numberWithDouble:0.00];
    } else {
        _product.productPrice = [NSNumber numberWithDouble:[self.productPrice_edit.text doubleValue]];
    }
    
    
    NSData *imageData;
    if(_selectedImage !=nil){
        imageData  = [NSData dataWithData:UIImageJPEGRepresentation(_selectedImage, 1)];
    }else{
        imageData = [NSData dataWithData:UIImageJPEGRepresentation(self.productImage.image, 1)];
        
    }
    
    if([imageData length] ==0){
        UIImage *defaultImage = [UIImage imageNamed:@"shoeOutline.png"];
        imageData = [NSData dataWithData:UIImagePNGRepresentation(defaultImage)];
    }
    
     _product.productImageData = imageData;
   
    _product.productLastUpdateDate = [NSDate date];


    if(_isValid){
        if(![managedContext save:&error]) {
            NSLog(@"Could not save product: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];

        }else{
            //alert user that product has been saved
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product" message:@"The product changes have been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    
    
    
    
    
}
- (void)productNotesSaved:(NSNotification *)notification
{
    [self.displayNotesPopover dismissPopoverAnimated:YES];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd MMM yyyy HH:mm"];
    NSDate *updateDate = _product.productLastUpdateDate;
    NSString *formatDate = [dateFormat stringFromDate:updateDate];
    updateInfo.text = [NSString stringWithFormat: @"Last updated on %@ by %@",formatDate, _product.productLastUpdatedBy];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CameraRollViewController *vc = (CameraRollViewController*)[segue destinationViewController];
    vc.sourceController = self;
}






-(void)onKeyboardHide:(NSNotification *)notification {

    //only animate if the view frame's y co-ordinate has been shifted up
    if(CGRectGetMaxY(self.view.frame) < 700) {
        [self animateTextField:self.productPrice_edit up:NO];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField:textField up:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(void)animateTextField:(UITextField *)textField up:(BOOL)up{
    
   
    
    const int movementDistance = -316;
    const float movementDuration = 0.2f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations:@"animateTextField" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}



- (IBAction)useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        self.imagePicker = [[UIImagePickerController alloc] init];
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        self.imagePicker.allowsEditing = NO;
        //imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn; //UIImagePickerControllerCameraFlashModeAuto;
        self.imagePicker.showsCameraControls = NO;
        
        //        CGRect f = self.imagePicker.view.bounds;
        //        f.size.height -= self.imagePicker.navigationBar.bounds.size.height;
        //        //f.size.width = f.size.height;
        //        CGFloat barHeight = (f.size.height - f.size.width) / 2;
        //        UIGraphicsBeginImageContext(f.size);
        //        [[UIColor colorWithWhite:0 alpha:.5] set];
        //        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, barHeight), kCGBlendModeNormal);
        //        UIRectFillUsingBlendMode(CGRectMake(0, f.size.height - barHeight, f.size.width, barHeight), kCGBlendModeNormal);
        //        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        //        UIGraphicsEndImageContext();
        //
        //        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:self.imagePicker.view.bounds];
        //        overlayIV.image = overlayImage;
        //        [self.imagePicker.cameraOverlayView addSubview:overlayIV];
        
        UIView *overlayView = [[UIView alloc] initWithFrame:self.imagePicker.view.frame];
        [self.imagePicker.cameraOverlayView addSubview:overlayView];
        
        CGFloat borderWidth = (self.imagePicker.view.frame.size.width - self.imagePicker.view.frame.size.height)/2;
        
        CALayer *leftBorder = [CALayer layer];
        leftBorder.frame = CGRectMake(0, 0, borderWidth, 768);
        leftBorder.backgroundColor = [UIColor blackColor].CGColor;
        [overlayView.layer addSublayer:leftBorder];
        
        
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(1024 - borderWidth, 0, borderWidth, 768);
        rightBorder.backgroundColor = [UIColor blackColor].CGColor;
        [overlayView.layer addSublayer:rightBorder];
        
        
        UIButton *takePhotoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [takePhotoButton setTitle:@"take photo" forState:UIControlStateNormal];
        takePhotoButton.frame = CGRectMake(914, 359, 100, 50);
        [takePhotoButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
        takePhotoButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
        takePhotoButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
        [overlayView addSubview:takePhotoButton];
        
        UIButton *cancelPhotoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [cancelPhotoButton setTitle:@"cancel" forState:UIControlStateNormal];
        cancelPhotoButton.frame = CGRectMake(914, 444, 100, 50);
        [cancelPhotoButton addTarget:self action:@selector(cancelPhoto:) forControlEvents:UIControlEventTouchUpInside];
        cancelPhotoButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
        cancelPhotoButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
        [overlayView addSubview:cancelPhotoButton];
        
        
        self.imagePicker.delegate = self;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCameraOverlay) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    }
}

- (IBAction)takePhoto:(id)sender {
    [self.imagePicker takePicture];
}

- (IBAction)cancelPhoto:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //image = info[UIImagePickerControllerOriginalImage];
        
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *scaledImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(450.0f, 450.0f) interpolationQuality:kCGInterpolationHigh];
        
        UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - 450.0f)/2, (scaledImage.size.height - 450.0f)/2, 450.0f, 450.0f)];
        
        
        self.productImage.image = croppedImage;
        
        //image = croppedImage;
        
        UIImageWriteToSavedPhotosAlbum(croppedImage,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end