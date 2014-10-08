//
//  AddProductsViewController.m
//  Buyers
//
//  Created by Web Development on 08/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ProductsViewController.h"
#import "AddNewProductViewController.h"
#import "CollectionListViewController.h"
#import "SWRevealViewController.h"
#import "SidebarViewController.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Product.h"
#import "ProductButton.h"
#import "ProductOrder.h"
#import <QuartzCore/QuartzCore.h>
#import "CollectionViewController.h"


static const float kColumnWidth = 200.0;
static const float kRowHeight = 180.0;
static const float kButtonWidth = 150.0;
static const float kButtonHeight = 150.0;
static const float kPageWidth = 680.0;
static const float kPageHeight = 540.0;
static const float kProductColumnSpacer = 30.0;

static const float sColumnWidth = 150.0;
static const float sRowHeight = 130.0;
static const float sButtonWidth = 100.0;
static const float sButtonHeight = 100.0;
static const float sPageWidth = 310.0;
static const float sPageHeight = 390.0;
static const float sProductColumnSpacer = 5.0;


@interface ProductsViewController () {
    NSArray *products;
    NSMutableArray *selectedProducts;

}

@end

@implementation ProductsViewController

@synthesize collection = _collection;
@synthesize clearAll = _clearAll;
@synthesize saveSelection = _saveSelection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//    
//    
//    //clear menu buttons
//    SidebarViewController *sidebar = (SidebarViewController*)self.revealViewController.rearViewController;
//    
//    if(sidebar.menuItem1 != nil) {
//        [sidebar.menuItem1 removeFromSuperview];
//    }
//    sidebar.menuItem1 = nil;
//    if(sidebar.menuItem2 != nil) {
//        [sidebar.menuItem2 removeFromSuperview];
//    }
//    sidebar.menuItem2 = nil;
//    if(sidebar.menuItem3 != nil) {
//        [sidebar.menuItem3 removeFromSuperview];
//    }
//    sidebar.menuItem3 = nil;
//    
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    
//
//    [button setTitle:@"add new product" forState:UIControlStateNormal];
//    [button setBackgroundColor:[UIColor whiteColor]];
//    [button setBackgroundImage:[UIImage imageNamed:@"rightArrowButtonBG.png"] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
//    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
//    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    
//    button.frame = CGRectMake(20, 40, 200, 60);
//    sidebar.menuItem1 = button;
//    [sidebar.view addSubview:button];
//    
//    [button addTarget:self action:@selector(addNewProduct:) forControlEvents:UIControlEventTouchUpInside];
//    
    
    
    UIButton *menu1 = [self setMenuButton:1 title:@"add new product"];
    
    [menu1 addTarget:self action:@selector(addNewProduct:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)addNewProduct:(id)sender {
    
    AddNewProductViewController  *addNewProductVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"addNewProduct"];
    
    [self.navigationController pushViewController:addNewProductVC animated:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    NSFetchRequest *pickerRequest = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
    NSArray *collections = [managedContext executeFetchRequest:pickerRequest error:&error];
    
    NSString *title2 = _collection.collectionName;
    self.txtNewCollection.hidden = YES;
    self.collectionList.hidden = YES;
    
    if(!_collection){
        title2 = @"collection";
        self.txtNewCollection.hidden = NO;
        self.txtNewCollection.delegate = self;
        if([collections count] >0) {
            self.collectionList.hidden = NO;
            self.collectionList.listItems = [NSMutableArray array];
            for (int c = 0, cc = [collections count]; c < cc; c++) {
               Collection *col = [collections objectAtIndex:c];
                [self.collectionList.listItems addObject:@{[[col objectID]URIRepresentation]:col.collectionName}];
               
            }
        }
        

    }
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"add products to" title2:title2 image:@"homePaperClipLogo.png"];
    
    selectedProducts = [[NSMutableArray alloc]  init];
    
    [self.view addSubview:_clearAll];
    [self.view addSubview:_saveSelection];
    
    UILabel *pageTitle = [[UILabel alloc] init];
    pageTitle.text = @" ADD PRODUCTS TO COLLECTION";
    pageTitle.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    pageTitle.textAlignment = NSTextAlignmentCenter;
    pageTitle.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    pageTitle.layer.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;    pageTitle.textColor = [UIColor blackColor];
    pageTitle.numberOfLines = 1;
    CGRect frameTitle = CGRectMake(0.0, 40.0, 1024.0, 30.0);
    pageTitle.frame = frameTitle;
    
    [self.view addSubview:pageTitle];
    
    UILabel *productsAvailable = [[UILabel alloc] init];
    productsAvailable.text = @"products available";
    productsAvailable.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsAvailable.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAvailable.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsAvailable.numberOfLines = 1;
    CGRect productsAvailableTitle = CGRectMake(20.0, 70.0, 300, 30.0);
    productsAvailable.frame = productsAvailableTitle;
    
    [self.view addSubview:productsAvailable];
    
    UILabel *productsAvailableSub = [[UILabel alloc] init];
    productsAvailableSub.text = @"Select a product to add to the list on the right";
    productsAvailableSub.font = [UIFont fontWithName:@"HelveticaNeue" size: 10.0f];
    productsAvailableSub.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAvailableSub.textColor = [UIColor blackColor];
    productsAvailableSub.numberOfLines = 1;
    CGRect productsAvailableSubText = CGRectMake(20.0, 100.0, 300, 20.0);
    productsAvailableSub.frame = productsAvailableSubText;
    
    [self.view addSubview:productsAvailableSub];
    
    //separator
    UIView *separator = [[UIView alloc] initWithFrame: CGRectMake(kPageWidth, 70.0, 1, 746.0)];
    separator.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1];
    [self.view addSubview:separator];
    
    
    UILabel *productsAdd = [[UILabel alloc] init];
    productsAdd.text = @"products to add";
    productsAdd.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsAdd.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAdd.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsAdd.numberOfLines = 1;
    CGRect productsAddTitle = CGRectMake((kPageWidth+20.0), 70.0, 300, 30.0); //kPageWidth, 70.0, 300, 30.0
    productsAdd.frame = productsAddTitle;
    
    [self.view addSubview:productsAdd];
    
    UILabel *productsAddSub = [[UILabel alloc] init];
    productsAddSub.text = @"Select a product to remove it from this list";
    productsAddSub.font = [UIFont fontWithName:@"HelveticaNeue" size: 10.0f];
    productsAddSub.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAddSub.textColor = [UIColor blackColor];
    productsAddSub.numberOfLines = 1;
    CGRect productsAddSubText = CGRectMake((kPageWidth+20.0), 100.0, 300, 20.0);
    productsAddSub.frame = productsAddSubText;
    
    [self.view addSubview:productsAddSub];

    UIView *productListView;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(20, 140, kPageWidth, kPageHeight)];
    scrollView.pagingEnabled = NO;
    
    
    //fetch request to retrieve all products
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
    NSArray *results = [managedContext executeFetchRequest:request error:&error];
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"productCode" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    products = [results sortedArrayUsingDescriptors:sortDescriptors];
    
    if ([products count] > 0) {
        
        int page =1;
        int col= 1;
        int row = 1;
        
        for (int p = 0, pc = [products count]; p < pc; p++) {
            
            if(productListView == nil)
             productListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * kPageHeight), kPageWidth, kPageHeight)];
            
            int x = (col -1) * kColumnWidth;
            int y = (row - 1) * kRowHeight;
            if(row >1) {
                y=y+1;
            }
            
            Product *productElement = [products objectAtIndex:p];
            
            UIImage *image = [UIImage imageWithData:(productElement.productImageData)];
            ProductButton *productButton = [[ProductButton alloc] initWithFrame:CGRectMake(x+((col -1) * kProductColumnSpacer), y, kButtonWidth, kButtonHeight)];
            [productButton setBackgroundImage:image forState:UIControlStateNormal];
            productButton.product = productElement;
            [productButton setTag:p+1]; //add 1 so that the tags start at 1 and not 0 so viewwithtag works
            [productButton addTarget:self action:@selector(addProductToSelection:) forControlEvents:UIControlEventTouchUpInside];
            [productListView addSubview:productButton];
            
            UILabel *productTitle = [[UILabel alloc] init];
            [productTitle setText:[productElement.productName capitalizedString]];
            productTitle.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
            productTitle.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
            productTitle.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1];
            productTitle.numberOfLines = 2;
            productTitle.textAlignment = NSTextAlignmentCenter;
            CGRect frameTitle = CGRectMake(x+((col -1) * kProductColumnSpacer),y+(kButtonHeight+2.0), kButtonWidth, 20.0);
            productTitle.frame = frameTitle;
            [productListView addSubview:productTitle];

            col++;
            
            if(col > 3) {
                row++;
                col= 1;
            }
            

            BOOL isLastPage = ((pc % 9 > 0) && (pc - p == 1));
            
            if(row > 3 && !isLastPage) {
                //increment page number and add view to scroll view
                [scrollView addSubview:productListView];
                page++;
                row = 1;
                productListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * kPageHeight), kPageWidth, kPageHeight)];
            } else if(isLastPage) {
                [scrollView addSubview:productListView];
            }
            
            
            scrollView.contentSize = CGSizeMake(kPageWidth,(kPageHeight * page));
            // NSLog(@"height: %f",(kPageHeight * page));
        }
        [self.view addSubview:scrollView];
    }
    [self constructsProducts];

}

- (void)addProductToSelection:(id)sender {
    Product *product = [(ProductButton *)sender product];
    UIButton *button = (UIButton *)sender;
    //add product to mutable array for displaying on the right
    //check whether the product already exists and if so don't add it
    
    if(![selectedProducts containsObject:product]){
        //add opacity
        button.layer.opacity = 0.1;
        [selectedProducts addObject:product];
        [self constructsProducts]; //call method to redraw
    }
    
    
}
- (void)removeProductFromSelection:(id)sender {
    Product *product = [(ProductButton *)sender product];
    
    int index = [products indexOfObject:product]+1; //add one as products array tag adds 1 to index for viewWithTag to work (doesn't work with 0)
    UIButton *button = (UIButton *)[self.view viewWithTag:index];
    
    //remove product from array
    //add full opacity
    button.layer.opacity = 1;
    [selectedProducts removeObject:product];
    [self constructsProducts]; //call method to redraw

}
- (void)constructsProducts {
    
    for(UIView *view in self.view.subviews) {
        if(view.tag == 999999999) {
        [view removeFromSuperview];
        }
     }
    
    UIView *selectedProductsListView;
    UIScrollView *selectedProductsScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake((kPageWidth+20.0), 130, sPageWidth, sPageHeight)];
    selectedProductsScrollView.pagingEnabled = NO;
    selectedProductsScrollView.tag=999999999;
    
    int page =1;
    int col= 1;
    int row = 1;
    
    for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
        
        if(selectedProductsListView == nil)
           //productListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * sPageWidth), 0, sPageWidth, sPageHeight)];
            selectedProductsListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * sPageHeight), sPageWidth, sPageHeight)];
        
        
        int x = (col -1) * sColumnWidth;
        int y = (row - 1) * sRowHeight;
        if(row >1) {
            y=y+1;
        }
        
        Product *productElement = [selectedProducts objectAtIndex:p];
        UIImage *image = [UIImage imageWithData:(productElement.productImageData)];
        ProductButton *productButton = [[ProductButton alloc] initWithFrame:CGRectMake(x+((col -1) * sProductColumnSpacer), y, sButtonWidth, sButtonHeight)];
        [productButton setBackgroundImage:image forState:UIControlStateNormal];
        productButton.product = productElement;
        [productButton setTag:p];
        [productButton addTarget:self action:@selector(removeProductFromSelection:) forControlEvents:UIControlEventTouchUpInside];
        [selectedProductsListView addSubview:productButton];
        
        UILabel *productTitle = [[UILabel alloc] init];
        [productTitle setText:[productElement.productName capitalizedString]];
        productTitle.font = [UIFont fontWithName:@"HelveticaNeue" size: 8.0];
        productTitle.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
        productTitle.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1];
        productTitle.numberOfLines = 2;
        productTitle.textAlignment = NSTextAlignmentCenter;
        CGRect frameTitle = CGRectMake(x+((col -1) * sProductColumnSpacer),y+(sButtonHeight+2.0), sButtonWidth, 20.0);
        productTitle.frame = frameTitle;
        [selectedProductsListView addSubview:productTitle];

        col++;
        
        if(col > 2) {
            row++;
            col= 1;
        }
        
        
        BOOL isLastPage = ((pc % 6 > 0) && (pc - p == 1));
        
        if(row > 3 && !isLastPage) {
            //increment page number and add view to scroll view
            [selectedProductsScrollView addSubview:selectedProductsListView];
            page++;
            row = 1;
            //productListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * sPageWidth), 0, sPageWidth, sPageHeight)];
            selectedProductsListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * sPageHeight), sPageWidth, sPageHeight)];
             //NSLog(@"y: %f page: %d",((page - 1) * sPageHeight), page);
        } else if(isLastPage) {
            [selectedProductsScrollView addSubview:selectedProductsListView];
        }
        
        
        selectedProductsScrollView.contentSize = CGSizeMake(sPageWidth,(sPageHeight * page));
         //NSLog(@"y: %f page: %d",((page - 1) * sPageHeight), page);
        
    }
    
    [self.view addSubview:selectedProductsScrollView];
   
}
-(IBAction)saveProducts:(id)sender{
    
    BOOL isNewCollection = NO;
    
    if([selectedProducts count] > 0) {
    
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
        NSError *error;
        
        //if no collection then validate for new one or existing one being selected
        if(!_collection){
            //[self.reportType.getSelectedValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
            if([self.txtNewCollection.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && [self.collectionList.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 ) {
            //alert user that there is no collection to add to
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"There is no collection to add products to!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            } else {
            //get user's full name from app settings
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *creatorName = [defaults objectForKey:@"username"];
            
                if([creatorName length] ==0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"Please add your name to app settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                
                } else {
                
                    
                    if([self.txtNewCollection.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) {
                        
                    //save the new collection
                    Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:managedContext];
                        
                    collection.collectionName = self.txtNewCollection.text;
                    collection.collectionCreator = creatorName;
                    collection.collectionCreationDate = [NSDate date];
                
                        if(![managedContext save:&error]) {
                            NSLog(@"Could not save collection: %@", [error localizedDescription]);
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"Sorry an error occurred" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];

                        } else {
                            //set collection
                            isNewCollection = YES;
                            _collection = collection.self;
                    
                        }
                    } else {
                        //set collection from picker
                        isNewCollection = YES;
                        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.collectionList.getSelectedValue];
                        NSManagedObject *collectionElement = [managedContext objectWithID:c];
                        _collection = (Collection*)collectionElement;
                        //NSLog(@"existing collection: %@",_collection.collectionName);
                    }
                }
            }
        }
    
            if(_collection){
                //loop through selectedProducts array and each object to the collection
                //also count the number of products already in the collection and increment this to get the order number
                
                for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
                    Product *product = [selectedProducts objectAtIndex:p];
        
                    //check it doesn't exist in the collection already
                    if(![_collection.products containsObject:product]){
        
                        //add collection
                        [product addCollectionsObject:_collection];
         
                        //add product order
                        ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:managedContext];
         
                        int number = [_collection.products count];
         
                        //NSLog(@"number: %d", number);
         
                        productOrder.productOrder = [NSNumber numberWithInt:number];
                        productOrder.orderCollection = _collection;
                        productOrder.orderProduct = product;
        
                        if(![managedContext save:&error]) {
                           // NSLog(@"Error saving product to collection: %@",[error localizedDescription]);
                            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
                            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                            if(detailedErrors != nil && [detailedErrors count] > 0) {
                                for(NSError* detailedError in detailedErrors) {
                                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                                }
                            }
                            else {
                                NSLog(@"  %@", [error userInfo]);
                            }
            
                        }
                    }
        
                }
    
            }
            
        if(isNewCollection) {
            //going back to home view - where should this go?
            //CollectionListViewController  *collectionListVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionListView"];
             [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            //pop to root view controller to get back to categories
            [self.navigationController popViewControllerAnimated:YES];
        }

        
    } else {
        //alert user that there is no collection to add to
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Error" message:@"There are no products selected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

    
}
-(IBAction)clearAll:(id)sender{
    //loop through selected products array and reset the opacity on products on the left
    
    
    for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
        NSLog(@"selected list p: %d",p);
        Product *product = [selectedProducts objectAtIndex:p];
        int index = [products indexOfObject:product]+1; //add one as products array tag adds 1 to index for viewWithTag to work (doesn't work with 0)
        UIButton *button = (UIButton *)[self.view viewWithTag:index];
        //add full opacity
        button.layer.opacity = 1;
    }
    
    [selectedProducts removeAllObjects];
    [self constructsProducts];
}

-(void)onKeyboardHide:(NSNotification *)notification {
    [self animateTextField:self.txtNewCollection up:NO];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField:textField up:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(void)animateTextField:(UITextField *)textField up:(BOOL)up{
    
    const int movementDistance = -280;
    const float movementDuration = 0.2f;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations:@"animateTextField" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
