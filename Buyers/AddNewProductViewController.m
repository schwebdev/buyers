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
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"product" title2:@"your custom product" image:@"homePaperClipLogo.png"];
    
    
    UIButton *saveProductButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [saveProductButton setTitle:@"add product" forState:UIControlStateNormal];
    saveProductButton.frame = CGRectMake(720, 600, 150, 50);
    [saveProductButton addTarget:self action:@selector(saveCustomProduct:) forControlEvents:UIControlEventTouchUpInside];
    saveProductButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    saveProductButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    [self.view addSubview:saveProductButton];
    
    UILabel *pageTitle = [[UILabel alloc] init];
    pageTitle.text = @" PRODUCT DETAIL";
    pageTitle.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    pageTitle.textAlignment = NSTextAlignmentCenter;
    pageTitle.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    pageTitle.layer.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor; pageTitle.textColor = [UIColor blackColor];
    pageTitle.numberOfLines = 1;
    CGRect frameTitle = CGRectMake(0.0, 40.0, 1024.0, 30.0);
    pageTitle.frame = frameTitle;
    
    [self.view addSubview:pageTitle];
    
    //separator
    UIView *separator = [[UIView alloc] initWithFrame: CGRectMake(kPageWidth, 70.0, 1, 746.0)];
    separator.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
    [self.view addSubview:separator];
    
    
    UILabel *productsInfo = [[UILabel alloc] init];
    productsInfo.text = @"Info";
    productsInfo.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsInfo.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsInfo.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsInfo.numberOfLines = 1;
    CGRect productsInfoTitle = CGRectMake((kPageWidth+20.0), 70.0, 300, 30.0); //kPageWidth, 70.0, 300, 30.0
    productsInfo.frame = productsInfoTitle;
    
    [self.view addSubview:productsInfo];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    //categories drop down
    NSFetchRequest *categoryRequest = [[NSFetchRequest alloc] initWithEntityName:@"ProductCategory"];
    categories = [managedContext executeFetchRequest:categoryRequest error:&error];
    
    if([categories count] >0) {
        
        self.categoryList.hidden = NO;
        self.categoryList.listItems = [NSMutableArray array];
        for (int c = 0, cc = [categories count]; c < cc; c++) {
            ProductCategory *col = [categories objectAtIndex:c];
            [self.categoryList.listItems addObject:@{[[col objectID]URIRepresentation]:col.categoryName}];
            
        }
    }
    
    //brand drop down
    NSFetchRequest *brandRequest = [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
    brands = [managedContext executeFetchRequest:brandRequest error:&error];
    
    if([brands count] >0) {
        self.brandList.hidden = NO;
        self.brandList.listItems = [NSMutableArray array];
        for (int c = 0, cc = [brands count]; c < cc; c++) {
            Brand *col = [brands objectAtIndex:c];
            [self.brandList.listItems addObject:@{[[col objectID]URIRepresentation]:col.brandName}];
            
        }
    }
    
    //supplier drop down
    NSFetchRequest *supplierRequest = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
    suppliers = [managedContext executeFetchRequest:supplierRequest error:&error];
    
    if([suppliers count] >0) {
        self.supplierList.hidden = NO;
        self.supplierList.listItems = [NSMutableArray array];
        for (int c = 0, cc = [suppliers count]; c < cc; c++) {
            Supplier *col = [suppliers objectAtIndex:c];
            [self.supplierList.listItems addObject:@{[[col objectID]URIRepresentation]:col.supplierName}];
            
        }
    }
    
    //colour drop down
    NSFetchRequest *colourRequest = [[NSFetchRequest alloc] initWithEntityName:@"Colour"];
    colours = [managedContext executeFetchRequest:colourRequest error:&error];
    
    if([colours count] >0) {
        self.colourList.hidden = NO;
        self.colourList.listItems = [NSMutableArray array];
        for (int c = 0, cc = [colours count]; c < cc; c++) {
            Colour *col = [colours objectAtIndex:c];
            [self.colourList.listItems addObject:@{[[col objectID]URIRepresentation]:col.colourName}];
            
        }
    }
    
    //material drop down
    NSFetchRequest *materialRequest = [[NSFetchRequest alloc] initWithEntityName:@"Material"];
    material = [managedContext executeFetchRequest:materialRequest error:&error];
    
    if([material count] >0) {
        self.materialList.hidden = NO;
        self.materialList.listItems = [NSMutableArray array];
        for (int c = 0, cc = [material count]; c < cc; c++) {
            Material *col = [material objectAtIndex:c];
            [self.materialList.listItems addObject:@{[[col objectID]URIRepresentation]:col.materialName}];
            
        }
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
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        //UIImagePickerControllerCameraFlashModeAuto;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useCameraRoll:(id)sender
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
    }
}

- (IBAction)categoryList:(id)sender {
    [_txtProductName resignFirstResponder];
}

- (void)saveCustomProduct:(id)sender {
    
    
    //validation
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
    
    product.productName = @"test";
    product.productPrice = [NSNumber numberWithDouble:125.00];
   // product.productNotes = @""; //user can add notes via edit so may not need this field
    
    /*NSFetchRequest *brandRequest = [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
    NSArray *brands = [managedContext executeFetchRequest:brandRequest error:&error];
    NSFetchRequest *materialRequest = [[NSFetchRequest alloc] initWithEntityName:@"Material"];
    NSArray *materials = [managedContext executeFetchRequest:materialRequest error:&error];
    NSFetchRequest *colourRequest = [[NSFetchRequest alloc] initWithEntityName:@"Colour"];
    NSArray *colours = [managedContext executeFetchRequest:colourRequest error:&error];
    NSFetchRequest *supplierRequest = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
    NSArray *suppliers = [managedContext executeFetchRequest:supplierRequest error:&error];
    NSFetchRequest *catRequest = [[NSFetchRequest alloc] initWithEntityName:@"ProductCategory"];
    NSArray *categories = [managedContext executeFetchRequest:catRequest error:&error];*/
    
    
    
    /*for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
        NSLog(@"selected list p: %d",p);
        Product *product = [selectedProducts objectAtIndex:p];
        int index = [products indexOfObject:product]+1; //add one as products array tag adds 1 to index for viewWithTag to work (doesn't work with 0)
        UIButton *button = (UIButton *)[self.view viewWithTag:index];
        //add full opacity
        button.layer.opacity = 1;
    }*/
    
    
    //picker control index for all of these
    
    
    NSString *filePath = [self.categoryList.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    product.category = [categories objectAtIndex:0];
    product.brand = [brands objectAtIndex:0];
    product.colour = [colours objectAtIndex:0];
    product.material = [material objectAtIndex:0];
    product.supplier = [suppliers objectAtIndex:0];

    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
    product.productImageData = imageData;

    
    if(![managedContext save:&error]) {
        NSLog(@"Could not save product: %@", [error localizedDescription]);
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
