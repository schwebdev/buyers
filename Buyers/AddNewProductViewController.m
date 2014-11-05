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

#import "CameraRollViewController.h"
#import "UIImage+Resize.h"

static const float kPageWidth = 680.0;

@interface AddNewProductViewController (){
    UIImage *image;
    NSArray *categories;
    NSArray *brands;
    NSArray *suppliers;
    NSArray *colours;
    NSArray *material;
}

@property UIImagePickerController *imagePicker;
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
    saveProductButton.frame = CGRectMake(720, 640, 150, 50);
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
    
    self.txtProductPrice.delegate = self;
    self.txtProductNotes.delegate = self;
    [[self.txtProductNotes layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.txtProductNotes layer] setBorderWidth:2.0];
    
    //categories drop down
    [self.categoryList setListItems:(NSMutableArray *)[Sync getTable:@"ProductCategory" sortWith:@"categoryName"] withName:@"categoryName" withValue:@"categoryName"];
    //brand drop down
    [self.brandList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    //supplier drop down
    [self.supplierList setListItems:(NSMutableArray *)[Sync getTable:@"Supplier" sortWith:@"supplierName"] withName:@"supplierName" withValue:@"supplierCode"];
    //colour drop down
    [self.colourList setListItems:(NSMutableArray *)[Sync getTable:@"Colour" sortWith:@"colourName"] withName:@"colourName" withValue:@"colourRef"];
    //material drop down
    [self.materialList setListItems:(NSMutableArray *)[Sync getTable:@"Material" sortWith:@"materialName"] withName:@"materialName" withValue:@"materialRef"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_selectedImage !=nil){
        _cameraView.image = _selectedImage;
        _isDirtyImage = YES;
    }
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
        _newMedia = YES;
        _isDirtyImage = YES;
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCameraOverlay) name:@"_UIImagePickerControllerUserDidCaptureItem" object:nil];
    }
}

- (IBAction)takePhoto:(id)sender {
    [self.imagePicker takePicture];
}

- (IBAction)cancelPhoto:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-(void)removeCameraOverlay {
//    self.imagePicker.cameraOverlayView = nil;
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [self.imagePicker takePicture];
//}
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
        //_isValid = NO;
        //[errorMsg appendString:@"please select a category\n"];
        pCategory = nil;
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.categoryList.getSelectedObject[@"IDURI"]];
        NSManagedObject *categoryElement = [managedContext objectWithID:c];
        pCategory = (ProductCategory*)categoryElement;
    }
    
    if([self.brandList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
       // _isValid = NO;
       // [errorMsg appendString:@"please select a brand\n"];
        pBrand = nil;
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.brandList.getSelectedObject[@"IDURI"]];
        NSManagedObject *brandElement = [managedContext objectWithID:c];
        pBrand = (Brand*)brandElement;
        
    }
    
    if([self.supplierList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a supplier\n"];
        pSupplier = nil;
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.supplierList.getSelectedObject[@"IDURI"]];
        NSManagedObject *supplierElement = [managedContext objectWithID:c];
        pSupplier = (Supplier*)supplierElement;
        //pSupplier = [self.supplierList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.colourList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a colour\n"];
        pColour = nil;
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.colourList.getSelectedObject[@"IDURI"]];
        NSManagedObject *colourElement = [managedContext objectWithID:c];
        pColour = (Colour*)colourElement;
        //pColour = [self.colourList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.materialList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please select a material\n"];
        pMaterial = nil;
        
    } else {
        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.materialList.getSelectedObject[@"IDURI"]];
        NSManagedObject *materialElement = [managedContext objectWithID:c];
        pMaterial = (Material*)materialElement;
        //pMaterial = [self.materialList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if([self.txtProductPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        //_isValid = NO;
        //[errorMsg appendString:@"please enter a price\n"];
        pPrice = [NSNumber numberWithDouble:0.00];
    } else {
        pPrice = [NSNumber numberWithDouble:[self.txtProductPrice.text doubleValue]];
    }
    
    /*if([self.txtProductCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        _isValid = NO;
        [errorMsg appendString:@"please enter a product code\n"];
    } else {
        pCode =self.txtProductCode.text;
    }*/
    
    /*if(!_isDirtyImage){
        _isValid = NO;
        [errorMsg appendString:@"please take a photo or select an image\n"];
    }*/
    
    
         if(_isValid){
             NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
             NSError *error;
             
             Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
             
             
             product.productName = pName;
             product.productPrice = pPrice;
             product.productCode = @"0000000000";
             product.productCategoryRef = pCategory.category2Ref;
             product.productBrandRef = pBrand.brandRef;
             product.productColourRef = pColour.colourRef;
             product.productMaterialRef = pMaterial.materialRef;
             product.productSupplierCode = pSupplier.supplierCode;
             NSData *imageData;
             if(_selectedImage !=nil){
                imageData  = [NSData dataWithData:UIImageJPEGRepresentation(_selectedImage, 1)];
             }else{
                 imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
             }
             
             if([imageData length] ==0){
             UIImage *defaultImage = [UIImage imageNamed:@"shoeOutline.png"];
             imageData = [NSData dataWithData:UIImagePNGRepresentation(defaultImage)];
             }

             product.productImageData = imageData;
             
             product.productNotes =self.txtProductNotes.text;
             
             if(![managedContext save:&error]) {
                 NSLog(@"Could not save product: %@", [error localizedDescription]);
                 [errorMsg appendString:@"Sorry, there has been a problem trying to save this product\n"];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                 [alert show];
             } else{
                 [errorMsg appendString:@"Product saved successfully\n"];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                 [alert show];
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"%@",errorMsg] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
             [alert show];
        }
    
    
    

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view
    
    CameraRollViewController *vc = (CameraRollViewController*)[segue destinationViewController];
    vc.sourceController = self;
    
    
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate



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
        
        
        _cameraView.image = croppedImage;
        
        image = croppedImage;
        if (_newMedia)
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

- (IBAction)ddlCategoryList:(id)sender {
}
-(void)onKeyboardHide:(NSNotification *)notification {

    //only animate if the view frame's y co-ordinate has been shifted up
    if(CGRectGetMaxY(self.view.frame) < 700) {
        
        if([self.txtProductName isFirstResponder]) {
            [self animateTextField:self.txtProductName up:NO];
        }
        if([self.txtProductPrice isFirstResponder]) {
            [self animateTextField:self.txtProductPrice up:NO];
        }

        if([self.txtProductNotes isFirstResponder]) {
            [self animateTextView:self.txtProductNotes up:NO];
        }

    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField:textField up:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(void)animateTextField:(UITextField *)textField up:(BOOL)up{
    
    
    const int movementDistance = -190;
    const float movementDuration = 0.2f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations:@"animateTextField" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self animateTextView:textView up:YES];
}
-(void)animateTextView:(UITextView *)textView up:(BOOL)up{
    
    
    const int movementDistance = -330;
    const float movementDuration = 0.2f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations:@"animateTextView" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}

@end
