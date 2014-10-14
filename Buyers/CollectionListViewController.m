
#import "CollectionListViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "Collection.h"
#import "NewCollectionViewController.h"
#import "CollectionViewController.h"
#import "CollectionButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Product.h"
#import "Image.h"
#import "ProductOrder.h"
#import "Brand.h"
#import "Supplier.h"
#import "Material.h"
#import "ProductCategory.h"
#import "Colour.h"
#import "SchTextField.h"


#define LX_LIMITED_MOVEMENT 0

static const float kColumnWidth = 341.5;
static const float kRowHeight = 289.0;
static const float kButtonWidth = 341.5;
static const float kButtonHeight = 288.0;
static const float kPageWidth = 1024.0;
static const float kPageHeight = 579.0;
static const float kNavBarHeight = 85.0;
static const float kProductWidth = 68.0;
static const float kProductHeight = 68.0;
static const float kProductColumnSpacer = 14.0;

@interface CollectionListViewController () {
    NSArray *collections;
    NSMutableArray *deletions;
    UIButton *filterButton;
    UIButton *allUsersButton;
    UIButton *yourOwnButton;
    SchTextField *txtSearch;
    UIView *tools;
    UILabel *numCollections;
    NSString *collectionText;
}
@end

@implementation CollectionListViewController

@synthesize addCollectionPopover = _addCollectionPopover;
@synthesize addCollection = _addCollection;
@synthesize addCollectionButton = _addCollectionButton;
@synthesize menu1 = _menu1;
@synthesize menu2 = _menu2;

-(IBAction)saveNewCollection:(id)sender {
    //protocol method callback - empty to avoid warning
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"your" title2:@"collections" image:@"homePaperClipLogo.png"];
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"List of Collections"]];
    
    tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 420, 75)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    
    allUsersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 28, 100, 24)];
    [allUsersButton setTitle:@" all users" forState:UIControlStateNormal];
    allUsersButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [allUsersButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allUsersButton setSelected:YES];
    [allUsersButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [allUsersButton setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [allUsersButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];

    yourOwnButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 100, 24)];
    [yourOwnButton setTitle:@" your own" forState:UIControlStateNormal];
    yourOwnButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [yourOwnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [yourOwnButton setSelected:NO];
    [yourOwnButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [yourOwnButton setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateSelected];
    [yourOwnButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setTitle:@"filter" forState:UIControlStateNormal];
    filterButton.frame = CGRectMake(320, 0, 100, 50);
    [filterButton addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    filterButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    filterButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    txtSearch = [[SchTextField alloc] initWithFrame:CGRectMake(110, 0, 200, 50)];
    
    [tools addSubview:allUsersButton];
    [tools addSubview:yourOwnButton];
    [tools addSubview:filterButton];
    [tools addSubview:txtSearch];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];

    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _menu1 = [self setMenuButton:1 title:@"+ new collection(s)"];
    
    [_menu1 addTarget:self action:@selector(displayNewCollectionPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    _menu2 = [self setMenuButton:2 title:@"delete collections"];

    [_menu2 addTarget:self action:@selector(deleteCollections:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //clear scroll view so it can be redrawn in case of changes
    for(UIView *view in self.view.subviews) {
        if(view.tag == 999999999) {
        [view removeFromSuperview];
        }
        
    }
    [self fetchResults];
    //NSLog(@"count %d", [collections count]);
    
}
- (void) filter {
    [numCollections removeFromSuperview];
    //clear scroll view so it can be redrawn in case of changes
    for(UIView *view in self.view.subviews) {
        if(view.tag == 999999999) {
            [view removeFromSuperview];
        }
        
    }
    [self fetchResults];
    //NSLog(@"count %d", [collections count]);
    
}


- (void)alert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[NSString stringWithFormat:@"test"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}
- (void)fetchResults
{
  
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
    NSError *error;
    NSArray *results = [managedContext executeFetchRequest:request error:&error];
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"collectionID" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"collectionName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
    
    if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && yourOwnButton.selected) {
        //get only user's own collections
         collections = [[results sortedArrayUsingDescriptors:sortDescriptors]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"collectionCreator =[cd] %@", creatorName]];
    } else if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && yourOwnButton.selected) {
        collections = [[results sortedArrayUsingDescriptors:sortDescriptors]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(collectionName CONTAINS[cd] %@ OR collectionName LIKE[cd] %@) AND collectionCreator =[cd] %@", txtSearch.text, txtSearch.text, creatorName]];
    } else if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && allUsersButton.selected) {
        collections = [[results sortedArrayUsingDescriptors:sortDescriptors]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"collectionName CONTAINS[cd] %@ OR collectionName LIKE[cd] %@", txtSearch.text, txtSearch.text]];
    } else {
    
         collections = [results sortedArrayUsingDescriptors:sortDescriptors];
    }
    
    collectionText = @"collections";
    if([collections count] ==1) {
        collectionText = @"collection";
        
    }
    numCollections = [[UILabel alloc] init];
    numCollections.text = [NSString stringWithFormat: @"%d %@", [collections count], collectionText];
    numCollections.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    numCollections.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    numCollections.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    numCollections.numberOfLines = 1;
    CGRect numCollectionsTitle = CGRectMake(210.0, 58.0, 500, 30.0);
    numCollections.frame = numCollectionsTitle;
    
    [self.view addSubview:numCollections];
    
    deletions = [[NSMutableArray alloc] initWithCapacity:[collections count]];
    
    txtSearch.text = @"";
    
    _scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, kNavBarHeight, kPageWidth, kPageHeight)];
    _scrollView.pagingEnabled = NO;
    _scrollView.tag = 999999999;
    _scrollView.delegate = self;
    
    if ([collections count] > 0 ) {
        
        int page = 1;
        int col = 1;
        int row = 1;
        
        UIView *collectionListView;

        
        for (int i = 0, ic = [collections count]; i < ic; i++) {
            
            if(collectionListView == nil)
                //collectionListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * kPageWidth), kNavBarHeight, kPageWidth, kPageHeight)];
                collectionListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * kPageHeight), kPageWidth, kPageHeight)];
            
            int x = (col -1) * kColumnWidth;
            int y = (row - 1) * kRowHeight;
            if(row >1) {
                y=y+1;
            }
            
            Collection *collectionElement = [collections objectAtIndex:i];
            CollectionButton *collectionButton = [[CollectionButton alloc] initWithFrame:CGRectMake(x, y, kButtonWidth, kButtonHeight)];
            
            //[collectionButton setTitle:collectionElement.collectionName forState:UIControlStateNormal];
            [collectionButton setTag:i];
            collectionButton.collection = collectionElement;
            [collectionButton addTarget:self action:@selector(collectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            CALayer *layer = [collectionButton layer];
            
            //add bottom border to all buttons
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.borderColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1].CGColor;
            bottomBorder.borderWidth = 1;
            bottomBorder.frame = CGRectMake(0, layer.frame.size.height, layer.frame.size.width, 1);
            [layer addSublayer:bottomBorder];
            
            
            //add right border for column 1 and column 2 only
            if (col < 3) {
                CALayer *rightBorder = [CALayer layer];
                rightBorder.borderColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1].CGColor;
                rightBorder.borderWidth = 1;
                rightBorder.frame = CGRectMake(layer.frame.size.width, 0, 1, layer.frame.size.height+1); //+1 on height as there is a slight white square on 2nd column???
                [layer addSublayer:rightBorder];
            }
            
            // NSLog(@"layer width: %f",layer.frame.size.width);
            
            
            //set title
            UILabel *collectionTitle = [[UILabel alloc] init];
            collectionTitle.text = [NSString stringWithFormat: @" %@", collectionElement.collectionName];
            collectionTitle.font = [UIFont fontWithName:@"HelveticaNeue" size: 14.0];
            collectionTitle.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
            collectionTitle.layer.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;
            collectionTitle.textColor = [UIColor blackColor];
            collectionTitle.numberOfLines = 1;
            //CGSize sizeTitle = [collectionTitle.text sizeWithAttributes:@{NSFontAttributeName:collectionTitle.font}];
            CGRect frameCTitle;
            if(col == 2) {
                frameCTitle = CGRectMake(2.0, 0.0, (kButtonWidth-2.0), 30.0);
            } else {
                frameCTitle = CGRectMake(1.0, 0.0, kButtonWidth-1.0, 30.0);
            }
            collectionTitle.frame = frameCTitle;
            
            [collectionButton addSubview:collectionTitle];
            
            
            //set date and author
            UILabel *collectionDetails = [[UILabel alloc] init];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"dd MMM yyyy"];
            NSDate *creationDate = collectionElement.collectionCreationDate;
            NSString *formatDate = [dateFormat stringFromDate:creationDate];
            collectionDetails.text = [NSString stringWithFormat: @" %@ - %@", formatDate, collectionElement.collectionCreator];
            collectionDetails.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
            collectionDetails.backgroundColor = [UIColor clearColor];
            collectionDetails.textColor = [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1];
            collectionDetails.numberOfLines = 1;
            //CGSize sizeDetails = [collectionTitle.text sizeWithAttributes:@{NSFontAttributeName:collectionDetails.font}];
            CGRect frameDTitle = CGRectMake(0.0, 30.0, kButtonWidth, 20.0);
            collectionDetails.frame = frameDTitle;
            
            [collectionButton addSubview:collectionDetails];
            
            NSArray *products;
            
            NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"productOrder" ascending:YES];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numericSort,nil];
            products = [collectionElement.collectionProductOrder sortedArrayUsingDescriptors:sortDescriptors];
            
            /*if(i==0){*/
             
             /*Brand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:managedContext];
             
             brand.brandName = @"irregular choice";
             brand.brandRef = [NSNumber numberWithInt:100];
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save brand: %@", [error localizedDescription]);
             
             }*/
             
             /*Supplier *supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:managedContext];
             
             supplier.supplierName = @"irregular choice";
             supplier.supplierCode = @"SUP001";
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save supplier: %@", [error localizedDescription]);
             
             }*/
             
            /*Material *material = [NSEntityDescription insertNewObjectForEntityForName:@"Material" inManagedObjectContext:managedContext];
             
             material.materialName = @"man-made";
             material.materialRef = [NSNumber numberWithInt:20];
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save material: %@", [error localizedDescription]);
             
             }
             
             Colour *colour = [NSEntityDescription insertNewObjectForEntityForName:@"Colour" inManagedObjectContext:managedContext];
             
             colour.colourName = @"multi";
             colour.colourRef = [NSNumber numberWithInt:10];
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save colour: %@", [error localizedDescription]);
             
             }
             
             ProductCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ProductCategory" inManagedObjectContext:managedContext];
             
             category.categoryName = @"high heels";
             category.category2Ref = [NSNumber numberWithInt:7];
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save category: %@", [error localizedDescription]);
             
             }
             
             
             }*/
            
            /*if(i==0) {
             
             //add dummy product to each collection
             Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
             product.productCode = @"1945097370";
             product.productName = @"black & red bow to fly";
             product.productPrice = [NSNumber numberWithDouble:125.00];
             product.productNotes = @"This is a test product inserted manually";
             NSFetchRequest *brandRequest = [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
             NSArray *brands = [managedContext executeFetchRequest:brandRequest error:&error];
             NSFetchRequest *materialRequest = [[NSFetchRequest alloc] initWithEntityName:@"Material"];
             NSArray *materials = [managedContext executeFetchRequest:materialRequest error:&error];
             NSFetchRequest *colourRequest = [[NSFetchRequest alloc] initWithEntityName:@"Colour"];
             NSArray *colours = [managedContext executeFetchRequest:colourRequest error:&error];
             NSFetchRequest *supplierRequest = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
             NSArray *suppliers = [managedContext executeFetchRequest:supplierRequest error:&error];
             NSFetchRequest *catRequest = [[NSFetchRequest alloc] initWithEntityName:@"ProductCategory"];
             NSArray *categories = [managedContext executeFetchRequest:catRequest error:&error];
             product.brand = [brands objectAtIndex:0];
             product.category = [categories objectAtIndex:0];
             product.colour = [colours objectAtIndex:0];
             product.material = [materials objectAtIndex:0];
             product.supplier = [suppliers objectAtIndex:0];
             //add image
             UIImage *image = [UIImage imageNamed:@"1945097370_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
             NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
             product.productImageData = imageData;
                
                product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
                product.productCode = @"1159167270";
                product.productName = @"black & white cheeky moose tweed";
                product.productPrice = [NSNumber numberWithDouble:125.00];
                product.productNotes = @"This is a test product inserted manually";
                product.brand = [brands objectAtIndex:0];
                product.category = [categories objectAtIndex:0];
                product.colour = [colours objectAtIndex:0];
                product.material = [materials objectAtIndex:0];
                product.supplier = [suppliers objectAtIndex:0];
                //add image
                image = [UIImage imageNamed:@"1159167270_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
                imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                product.productImageData = imageData;
                
                product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
                product.productCode = @"1159167060";
                product.productName = @"black cheeky moose glitter";
                product.productPrice = [NSNumber numberWithDouble:125.00];
                product.productNotes = @"This is a test product inserted manually";
                product.brand = [brands objectAtIndex:0];
                product.category = [categories objectAtIndex:0];
                product.colour = [colours objectAtIndex:0];
                product.material = [materials objectAtIndex:0];
                product.supplier = [suppliers objectAtIndex:0];
                //add image
                image = [UIImage imageNamed:@"1159167060_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
                imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                product.productImageData = imageData;
                
                product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
                product.productCode = @"1159155670";
                product.productName = @"turquoise pinky perky court";
                product.productPrice = [NSNumber numberWithDouble:125.00];
                product.productNotes = @"This is a test product inserted manually";
                product.brand = [brands objectAtIndex:0];
                product.category = [categories objectAtIndex:0];
                product.colour = [colours objectAtIndex:0];
                product.material = [materials objectAtIndex:0];
                product.supplier = [suppliers objectAtIndex:0];
                //add image
                image = [UIImage imageNamed:@"1159155670_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
                imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                product.productImageData = imageData;
                
                product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
                product.productCode = @"1159053670";
                product.productName = @"purple oz naughty smile";
                product.productPrice = [NSNumber numberWithDouble:125.00];
                product.productNotes = @"This is a test product inserted manually";
                product.brand = [brands objectAtIndex:0];
                product.category = [categories objectAtIndex:0];
                product.colour = [colours objectAtIndex:0];
                product.material = [materials objectAtIndex:0];
                product.supplier = [suppliers objectAtIndex:0];
                //add image
                image = [UIImage imageNamed:@"1159053670_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
                imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                product.productImageData = imageData;
                
                product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
                product.productCode = @"1158985860";
                product.productName = @"bloxy simba cat t-bar court";
                product.productPrice = [NSNumber numberWithDouble:125.00];
                product.productNotes = @"This is a test product inserted manually";
                product.brand = [brands objectAtIndex:0];
                product.category = [categories objectAtIndex:0];
                product.colour = [colours objectAtIndex:0];
                product.material = [materials objectAtIndex:0];
                product.supplier = [suppliers objectAtIndex:0];
                //add image
                image = [UIImage imageNamed:@"1158985860_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
                imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
                product.productImageData = imageData;
             
             //add additional images
             //Image *productImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedContext];
             //productImage.imageData = imageData;
             
             //[product addImagesObject:productImage];
             
             if(![managedContext save:&error]) {
             NSLog(@"Could not save product: %@", [error localizedDescription]);
             
             }
             
             }*/
            
            //if there are products get first 12 product images
            if ([products count] > 0) {
                
                UIView *productsView = [[UIView alloc] initWithFrame:CGRectMake(2.0, 51.0, kButtonWidth-4, 213.0)];
                productsView.userInteractionEnabled = false; //switch off so the view area is clickable
                
                int pCol =1;
                int pRow = 1;
                
                for (int p = 0, pc = [products count]; p < pc; p++) {
                    
                    if(p==12) {
                        break;
                    }
                    ProductOrder *productOrder = [products objectAtIndex:p];
                    Product *productElement = productOrder.orderProduct;
                    
                    int px = (pCol -1) * kProductWidth;
                    int py = (pRow - 1) * kProductHeight;
                    if(pRow >1) {
                        py=py+1;
                    }
                    UIImage *image = [UIImage imageWithData:(productElement.productImageData)];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    imageView.frame = CGRectMake(px+((pCol -1) * kProductColumnSpacer), py, kProductWidth, kProductHeight);
                    [productsView addSubview:imageView];
                    pCol++;
                    
                    if(pCol > 4) {
                        pRow++;
                        pCol= 1;
                    }
                }
                
                CALayer *productsLayer = [productsView layer];
                CALayer *pTopBorder = [CALayer layer];
                pTopBorder.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;
                pTopBorder.borderWidth = 1;
                pTopBorder.frame = CGRectMake(0, 0, productsLayer.frame.size.width, 1);
                [productsLayer addSublayer:pTopBorder];
                
                
                CALayer *pBottomBorder = [CALayer layer];
                pBottomBorder.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1].CGColor;
                pBottomBorder.borderWidth = 1;
                pBottomBorder.frame = CGRectMake(0, productsLayer.frame.size.height, productsLayer.frame.size.width, 1);
                [productsLayer addSublayer:pBottomBorder];
                
                [collectionButton addSubview:productsView];
            }
            
            
            //set number of products within collection
            UILabel *collectionNumProducts = [[UILabel alloc] init];
            NSString *productText = @"products";
            if([products count] ==1) {
                productText = @"product";
                
            }
            collectionNumProducts.text = [NSString stringWithFormat: @" %d %@", [products count], productText];
            collectionNumProducts.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
            collectionNumProducts.backgroundColor = [UIColor clearColor];
            collectionNumProducts.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
            collectionNumProducts.numberOfLines = 1;
            //CGSize sizeProducts = [collectionTitle.text sizeWithAttributes:@{NSFontAttributeName:collectionProducts.font}];
            CGRect framePNumTitle = CGRectMake(0.0, (kButtonHeight-20.0), (kButtonWidth/2), 20.0);
            collectionNumProducts.frame = framePNumTitle;
            
            [collectionButton addSubview:collectionNumProducts];
            
            
            UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake((kButtonWidth-115.0), (kButtonHeight-20.0), (kButtonWidth/2), 20.0)];
            [deleteButton setTitle:@" delete" forState:UIControlStateNormal];
            deleteButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
            [deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [deleteButton setSelected:NO];
            [deleteButton setImage:[UIImage imageNamed:@"checkboxSML.png"] forState:UIControlStateNormal];
            [deleteButton setImage:[UIImage imageNamed:@"checkboxSML-checked.png"] forState:UIControlStateSelected];
            [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setTag:i];
            [collectionButton addSubview:deleteButton];
            
            
            col++;
            
            if(col > 3) {
                row++;
                col= 1;
            }
            
            [collectionListView addSubview:collectionButton];
            
            BOOL isLastPage = ((ic % 9 > 0) && (ic - i == 1));
            
            if(row > 2 && !isLastPage) {
                //increment page number and add view to scroll view
                [_scrollView addSubview:collectionListView];
                page++;
                row = 1;
                //collectionListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * kPageWidth), kNavBarHeight, kPageWidth, kPageHeight)];
                collectionListView = [[UIView alloc] initWithFrame:CGRectMake(0, ((page - 1) * kPageHeight), kPageWidth, kPageHeight)];
            } else if(isLastPage) {
                [_scrollView addSubview:collectionListView];
            }
            
            
            _scrollView.contentSize = CGSizeMake(kPageWidth,(kPageHeight * page));
            //NSLog(@"x: %f",((page - 1) * kPageWidth));
        }
        [self.view addSubview:_scrollView];
        
        //show or hide next and previous arrows
        _upArrow = [[UIImageView alloc] initWithFrame:CGRectMake(20, (kPageHeight+90), 35.5, 27)];
        _upArrow.hidden = YES;
        [_upArrow setImage:[UIImage imageNamed:@"arrowUP.png"]];
        [self.view addSubview:_upArrow];
        
        _downArrow = [[UIImageView alloc] initWithFrame:CGRectMake(968.5, (kPageHeight+90), 35.5, 27)];
        _downArrow.hidden = YES;
        [_downArrow setImage:[UIImage imageNamed:@"arrowDOWN.png"]];
        [self.view addSubview:_downArrow];

        
        if(page > 0) {
            if(_scrollView.contentOffset.y == 0) {
                _upArrow.hidden = YES;
            } else {
                
                _upArrow.hidden=NO;
            }
            if(_scrollView.contentOffset.y == (_scrollView.contentSize.height - kPageHeight)) {
                _downArrow.hidden = YES;
            } else {
                _downArrow.hidden=NO;
            }
        }
        
    } else {
        
        //display message
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(210, 60, 300, 50))];
        label.text = @"no collections have been returned";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0];
        label.textColor = [UIColor colorWithRed:217.0/255.0 green:54.0/255.0 blue:0 alpha:1];
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        [_scrollView addSubview:label];
        
        //display add new collection button
        _addCollectionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_addCollectionButton setTitle:@"+ new collection(s)" forState:UIControlStateNormal];
        [_addCollectionButton addTarget:self action:@selector(displayNewCollectionPopover:) forControlEvents:UIControlEventTouchUpInside];
        [_addCollectionButton setFrame:CGRectMake(210, 120, 200, 60)];
        [ _addCollectionButton setBackgroundColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229/255.0 alpha:1]];
        [_addCollectionButton setTitleColor:[UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1] forState:UIControlStateNormal];
        _addCollectionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        [_addCollectionButton setTag:1];
        [_scrollView addSubview:_addCollectionButton];
        
        [self.view addSubview:_scrollView];
        
    }
    
    //add notification to listen for the collection being saved and call method to close the pop over and go to collections view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNewCollection:) name:@"GoToNewCollection" object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(_scrollView.contentOffset.y == 0) {
        _upArrow.hidden = YES;
    } else {
        
        _upArrow.hidden=NO;
    }
    if(_scrollView.contentOffset.y == (_scrollView.contentSize.height - kPageHeight)) {
        _downArrow.hidden = YES;
        // NSLog(@"y: %f height: %f pageheight: %f" ,_scrollView.contentOffset.y, _scrollView.contentSize.height, kPageHeight);
    } else {
        _downArrow.hidden=NO;
       
    }
}
- (void)goToNewCollection:(NSNotification *)notification
{
    [self.addCollectionPopover dismissPopoverAnimated:YES];
    
    //calling pushViewController before viewDidAppear is unsafe and is causing the subview tree to get corrupted on occasion - this is resulting in the collection object not being available in the collection view controller after viewDidLoad so aborting this stage and refreshing results instead
    
    /*go to new collection view so user can add products
    CollectionViewController  *collectionViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    NSManagedObjectID *collectionID = [[notification userInfo] valueForKey:@"collectionID"];
    Collection *collection = (Collection *) [managedContext existingObjectWithID:collectionID error:&error];
    
    collectionViewController.collection = collection;
    [self.navigationController pushViewController:collectionViewController animated:YES];
     */
    
    [numCollections removeFromSuperview];
    for(UIView *view in self.view.subviews) {
        if(view.tag == 999999999) {
            [view removeFromSuperview];
        }
        
    }
    [self fetchResults];
    
}
- (void)collectionButtonClicked:(id)sender {
    Collection *collection = [(CollectionButton *)sender collection];

    CollectionViewController  *collectionViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    collectionViewController.collection = collection;
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}

- (void)deleteButtonClicked:(id)sender {
   
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    Collection *collection = [collections objectAtIndex:[sender tag]];
    
    if(button.selected ==YES) {
        //add collection to array for deletion
         if(![deletions containsObject:collection]){
             [deletions addObject:collection];
         }
    } else {
        //remove collection from array for deletion
        if([deletions containsObject:collection]){
            [deletions removeObject:collection];
        }
        
    }
    
    //NSLog(@"deletions: %d", [deletions count]);

}
- (void)filterClicked:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    NSString *buttonTitle = button.currentTitle;
    
    if([buttonTitle  isEqual: @" all users"]) {
        
        yourOwnButton.selected = !yourOwnButton.selected;

    } else {
         allUsersButton.selected = !allUsersButton.selected;
    }
    
}

- (void)deleteCollections:(id)sender {
    
    if([deletions count] > 0) {
     
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        
        for (int i = 0, ic = [deletions count]; i < ic; i++) {
            Collection *collection = [deletions objectAtIndex:i];
            [managedContext deleteObject:collection];
        }
        
        if(![managedContext save:&error]) {
            NSLog(@"Could not save deleted collections: %@", [error localizedDescription]);
            
        }
        
        [numCollections removeFromSuperview];
        //clear scroll view so it can be redrawn in case of changes
        for(UIView *view in self.view.subviews) {
            if(view.tag == 999999999) {
                [view removeFromSuperview];
            }
            
        }
    
        [self fetchResults];
        
    } else {
        //alert user that there are no collections to delete
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"There are no collections to delete!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)displayNewCollectionPopover:(id)sender {
    
    if (_addCollection== nil) {
        self.addCollection = [self.storyboard instantiateViewControllerWithIdentifier:@"addNewCollection"];
        _addCollection.delegate = self;
        
        self.addCollectionPopover = [[UIPopoverController alloc] initWithContentViewController:_addCollection];
    }
    
    if([(UIButton *) sender tag] == 1) {
        
    [self.addCollectionPopover presentPopoverFromRect:_addCollectionButton.bounds  inView:_addCollectionButton permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
    } else {
        //use the slider menu button
         [self.addCollectionPopover presentPopoverFromRect:_menu1.bounds  inView:_menu1 permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return collections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Collection *collection = collections[indexPath.item];
    CollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    collectionCell.collection = collection;
    //playingCardCell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    return collectionCell;
}


#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    Collection *collection = collections[fromIndexPath.item];
    
    [collections removeObjectAtIndex:fromIndexPath.item];
    [collections insertObject:collection atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
#if LX_LIMITED_MOVEMENT == 1
    Collection *collection = collections[indexPath.item];
    
    switch (playingCard.suit) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return YES;
        } break;
        default: {
            return NO;
        } break;
    }
#else
    return YES;
#endif
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
#if LX_LIMITED_MOVEMENT == 1
    Collection *fromPCollection = collections[fromIndexPath.item];
    Collection *toCollection = collections[toIndexPath.item];
    
    //switch order here
    switch (toCollection.collection) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return fromPlayingCard.rank == toPlayingCard.rank;
        } break;
        default: {
            return NO;
        } break;
    }
#else
    return YES;
#endif
}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
}*/



@end
