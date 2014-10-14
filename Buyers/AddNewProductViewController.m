//
//  AddNewProductViewController.m
//  Buyers
//
//  Created by Web Development on 26/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "AddNewProductViewController.h"
#import "AppDelegate.h"
#import "Product.h"
#import "BaseViewController.h"
#import "Brand.h"
#import "ProductCategory.h"
#import "Supplier.h"
#import "Colour.h"
#import "Material.h"
#import "Sync.h"

static const float kPageWidth = 680.0;

@interface AddNewProductViewController (){
    UIImage *image;
    NSArray *categories;
    NSArray *brands;
    NSArray *suppliers;
    NSArray *colours;
    NSArray *material;
}

@end

@implementation AddNewProductViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isDirtyImage = NO;
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"product" title2:@"your custom product" image:@"homePaperClipLogo.png"];
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"Add New Product"]];
    
    UIButton *saveProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [saveProductButton setTitle:@"add product" forState:UIControlStateNormal];
    saveProductButton.frame = CGRectMake(720, 600, 150, 50);
    [saveProductButton addTarget:self action:@selector(saveCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    saveProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    saveProductButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    [self.view addSubview:saveProductButton];
    
    
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
    
    if(_selectedImage !=nil){
        _cameraView.image = _selectedImage;
        _isDirtyImage = YES;
    }     
    
    //categories drop down
    [self.categoryList setListItems:(NSMutableArray *)[Sync getTable:@"ProductCategory" sortWith:@"categoryName"] withName:@"categoryName" withValue:@"categoryName"];
    //brand drop down
    [self.brandList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    //supplier drop down
    [self.supplierList setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    //colour drop down
    [self.colourList setListItems:(NSMutableArray *)[Sync getTable:@"Colour" sortWith:@"colourName"] withName:@"colourName" withValue:@"colourCode"];
    //material drop down
    [self.materialList setListItems:(NSMutableArray *)[Sync getTable:@"Material" sortWith:@"materialName"] withName:@"materialName" withValue:@"materialCode"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        ///imagePicker.allowsEditing = NO;
        //imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn; //UIImagePickerControllerCameraFlashModeAuto;
        //imagePicker.showsCameraControls = YES;
        
        CGRect f = imagePicker.view.bounds;
        f.size.height -= imagePicker.navigationBar.bounds.size.height;
        //f.size.width = f.size.height;
        CGFloat barHeight = (f.size.height - f.size.width) / 2;
        UIGraphicsBeginImageContext(f.size);
        [[UIColor colorWithWhite:0 alpha:.5] set];
        UIRectFillUsingBlendMode(CGRectMake(0, 0, f.size.width, barHeight), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, f.size.height - barHeight, f.size.width, barHeight), kCGBlendModeNormal);
        UIImage *overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
        overlayIV.image = overlayImage;
        [imagePicker.cameraOverlayView addSubview:overlayIV];
        
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        _newMedia = YES;
        _isDirtyImage = YES;
    }
}

/*- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = NO;
        _isDirtyImage = YES;
    }
}*/

- (IBAction)categoryList:(id)sender {
    [_txtProductName resignFirstResponder];
}

- (void)saveCustomProduct:(id)sender {
    
    NSString *pName;
    ProductCategory *pCategory;
    Brand *pBrand;
    Supplier *pSupplier;
    Colour *pColour;
    Material *pMaterial;
    NSMutableString *errorMsg = [[NSMutableString alloc] initWithString:@""];
    NSNumber *pPrice;
    _isValid = YES;
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];

    
    
    //validation
    if([self.txtProductName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a product name\n"];
    } else {
        pName =self.txtProductName.text;
    }
    
    if([self.categoryList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a category\n"];
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.categoryList.getSelectedObject[@"IDURI"]];
        NSManagedObject *categoryElement = [managedContext objectWithID:c];
        pCategory = (ProductCategory*)categoryElement;
    }
    
    if([self.brandList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a brand\n"];
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.brandList.getSelectedObject[@"IDURI"]];
        NSManagedObject *brandElement = [managedContext objectWithID:c];
        pBrand = (Brand*)brandElement;
        
    }
    
    if([self.supplierList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a supplier\n"];
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.supplierList.getSelectedObject[@"IDURI"]];
        NSManagedObject *supplierElement = [managedContext objectWithID:c];
        pSupplier = (Supplier*)supplierElement;
        //pSupplier = [self.supplierList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.colourList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a colour\n"];
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.colourList.getSelectedObject[@"IDURI"]];
        NSManagedObject *colourElement = [managedContext objectWithID:c];
        pColour = (Colour*)colourElement;
        //pColour = [self.colourList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.materialList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please select a material\n"];
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.materialList.getSelectedObject[@"IDURI"]];
        NSManagedObject *materialElement = [managedContext objectWithID:c];
        pMaterial = (Material*)materialElement;
        //pMaterial = [self.materialList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.txtProductPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a price\n"];
    } else {
        pPrice = [NSNumber numberWithDouble:[self.txtProductPrice.text doubleValue]];
    }
    
    /*if([self.txtProductCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a product code\n"];
    } else {
        pCode =self.txtProductCode.text;
    }*/
    
    if(!_isDirtyImage){
        _isValid = NO;
        [errorMsg appendString:@"please take a photo or select an image\n"];
    }
    
    
         if(_isValid){
             NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
             NSError *error;
             
             Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
             
             
             product.productName = pName;
             product.productPrice = pPrice;
             
             product.category = pCategory;
             product.brand = pBrand;
             product.colour = pColour;
             product.material = pMaterial;
             product.supplier = pSupplier;
             NSData *imageData;
             if(_selectedImage !=nil){
                imageData  = [NSData dataWithData:UIImageJPEGRepresentation(_selectedImage, 1)];
             }else{
                 imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
             }
             product.productImageData = imageData;
             
             
             if(![managedContext save:&error]) {
                 NSLog(@"Could not save product: %@", [error localizedDescription]);
             }
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
             [alert show];
            }
    
    
    

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

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        image = info[UIImagePickerControllerOriginalImage];
        
        _cameraView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
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

- (IBAction)ddlCategoryList:(id)sender {
}


@end
