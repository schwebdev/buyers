//
//  AddProductsViewController.m
//  Buyers
//
//  Created by Web Development on 08/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductViewController.h"
#import "AddNewProductViewController.h"
#import "CollectionListViewController.h"
#import "SWRevealViewController.h"
#import "SidebarViewController.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Product.h"
#import "ProductCell.h"
#import "ProductButton.h"
#import "ProductOrder.h"
#import <QuartzCore/QuartzCore.h>
#import "CollectionViewController.h"



static const float kPageWidth = 680.0;

static const float sColumnWidth = 150.0;
static const float sRowHeight = 130.0;
static const float sButtonWidth = 100.0;
static const float sButtonHeight = 100.0;
static const float sPageWidth = 310.0;
static const float sPageHeight = 400.0;
static const float sProductColumnSpacer = 5.0;


@interface ProductsViewController () {
    NSMutableArray *selectedProducts;
    UIButton *filterButton, *clearButton;
    UIButton *allProductsButton;
    UIButton *customProductsButton;
    SchTextField *txtSearch;
    UIView *tools;
    UILabel *numProducts;
    NSString *productText;
    UILabel *noResults;
    UIButton *menu2;
    BOOL isAdvancedSearch;
    NSPredicate *predicate;
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}

@end

@implementation ProductsViewController

@synthesize collection = _collection;
@synthesize clearAll = _clearAll;
@synthesize saveSelection = _saveSelection;
@synthesize displayAdvancedSearchPopover = _displayAdvancedSearchPopover;
@synthesize productSearch = _productSearch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)searchProducts:(id)sender {
    //protocol method callback - empty to avoid warning
}
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //self.products = [self constructsProducts];
    self.fetchedResultsController = nil;
    
    self.fetchedResultsController = [self constructsProducts];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [_scrollView reloadData];
    });

    [self constructsSelectedProducts];
    
    UIButton *menu1 = [self setMenuButton:1 title:@"add new product"];
    
    [menu1 addTarget:self action:@selector(addNewProduct:) forControlEvents:UIControlEventTouchUpInside];
    
    menu2 = [self setMenuButton:2 title:@"advanced search"];
    
    [menu2 addTarget:self action:@selector(displayAdvancedSearchPopover:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}
- (void)addNewProduct:(id)sender {
    
    AddNewProductViewController  *addNewProductVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"addNewProduct"];
    
    [self.navigationController pushViewController:addNewProductVC animated:YES];
    
}

- (void)advancedSearch:(NSNotification *)notification
{
    [self.displayAdvancedSearchPopover dismissPopoverAnimated:YES];
    
    [self.revealViewController revealToggleAnimated:YES];
    
    NSDictionary *dict = [notification userInfo];
    
    isAdvancedSearch = YES;
    NSMutableArray *preds = [[NSMutableArray alloc]initWithCapacity:1];
    
    
    if(dict[@"productName"] != nil) {
        //NSLog(@"userInfo productName: %@", dict[@"productName"]);
        NSPredicate *namePred =[NSPredicate predicateWithFormat:@"(productName CONTAINS[cd] %@ OR productName LIKE[cd] %@) OR (productCode CONTAINS[cd] %@ OR productCode LIKE[cd] %@)",dict[@"productName"],dict[@"productName"],dict[@"productName"],dict[@"productName"]];
        [preds addObject:namePred];
    }
    if(dict[@"productCategoryRef"] != nil) {
        //NSLog(@"userInfo productCategoryRef: %@", dict[@"productCategoryRef"]);
        NSPredicate *categoryPred =[NSPredicate predicateWithFormat:@"productCategoryRef == %d", [dict[@"productCategoryRef"] integerValue]];
        [preds addObject:categoryPred];
    }
    if(dict[@"productBrandRef"] != nil) {
        //NSLog(@"userInfo productBrandRef: %@", dict[@"productBrandRef"]);
        NSPredicate *brandPred =[NSPredicate predicateWithFormat:@"productBrandRef == %d", [dict[@"productBrandRef"] integerValue]];
        [preds addObject:brandPred];
    }
    if(dict[@"productSupplierCode"] != nil) {
        //NSLog(@"userInfo productSupplierCode: %@", dict[@"productSupplierCode"]);
        NSPredicate *supplierPred =[NSPredicate predicateWithFormat:@"productSupplierCode == %@", dict[@"productSupplierCode"]];
        [preds addObject:supplierPred];
    }
    if(dict[@"productColourRef"] != nil) {
        //NSLog(@"userInfo productColourRef: %@", dict[@"productColourRef"]);
        NSPredicate *colourPred =[NSPredicate predicateWithFormat:@"productColourRef == %d", [dict[@"productColourRef"] integerValue]];
        [preds addObject:colourPred];
    }
    if(dict[@"productMaterialRef"] != nil) {
        //NSLog(@"userInfo productMaterialRef: %@", dict[@"productMaterialRef"]);
        NSPredicate *materialPred =[NSPredicate predicateWithFormat:@"productMaterialRef == %d", [dict[@"productMaterialRef"] integerValue]];
        [preds addObject:materialPred];
    }
    //NSLog(@"userInfo productType: %@", dict[@"productType"]);
    
    if([dict[@"productType"]  isEqual: @"custom"]) {
        NSPredicate *typePred =[NSPredicate predicateWithFormat:@"productCode ='0000000000'"];
        [preds addObject:typePred];
    }
    
    if(dict[@"productPrice"] != nil) {
        //NSLog(@"userInfo productPrice: %@", dict[@"productPrice"]);
        NSPredicate *pricePred =[NSPredicate predicateWithFormat:@"productPrice > 0 and productPrice <= %d", [dict[@"productPrice"] integerValue]];
        [preds addObject:pricePred];
    }
    
    predicate=[NSCompoundPredicate andPredicateWithSubpredicates:preds];
    
    [selectedProducts removeAllObjects];
    [self constructsSelectedProducts];
    
    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self constructsProducts];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [_scrollView reloadData];
    });

    //NSLog(@"filter count: %d",[self.fetchedResultsController.fetchedObjects count]);
    
}
- (IBAction)displayAdvancedSearchPopover:(id)sender {
    
    if (_productSearch== nil) {
        self.productSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
        _productSearch.delegate = self;
        
        self.displayAdvancedSearchPopover = [[UIPopoverController alloc] initWithContentViewController:_productSearch];
    }
    
    [self.displayAdvancedSearchPopover presentPopoverFromRect:menu2.bounds  inView:menu2 permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _itemChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    isAdvancedSearch = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    NSFetchRequest *pickerRequest = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
    NSArray *collections = [self.managedContext executeFetchRequest:pickerRequest error:&error];
    
    
    NSString *title2 = _collection.collectionName;
    if(title2.length > 15) {
        NSString *substring = [title2 substringWithRange:NSMakeRange(0,15)];
        title2 = [NSString stringWithFormat:@"%@...",substring];
    }
    
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
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"Add Products To Collection"]];
    
    tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 520, 75)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    allProductsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 28, 100, 24)];
    [allProductsButton setTitle:@" all products" forState:UIControlStateNormal];
    allProductsButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [allProductsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allProductsButton setSelected:YES];
    [allProductsButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [allProductsButton setImage:[UIImage imageNamed:@"checkbox-checked-search.png"] forState:UIControlStateSelected];
    [allProductsButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    customProductsButton = [[UIButton alloc] initWithFrame:CGRectMake(-11, 0, 100, 24)];
    [customProductsButton setTitle:@" custom" forState:UIControlStateNormal];
    customProductsButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [customProductsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [customProductsButton setSelected:NO];
    [customProductsButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [customProductsButton setImage:[UIImage imageNamed:@"checkbox-checked-search.png"] forState:UIControlStateSelected];
    [customProductsButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setTitle:@"filter" forState:UIControlStateNormal];
    filterButton.frame = CGRectMake(310, 0, 100, 50);
    [filterButton addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    filterButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    filterButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    clearButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setTitle:@"clear" forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(420, 0, 100, 50);
    [clearButton addTarget:self action:@selector(clearSearch) forControlEvents:UIControlEventTouchUpInside];
    clearButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    clearButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];

    txtSearch = [[SchTextField alloc] initWithFrame:CGRectMake(100, 0, 200, 50)];
    
    [tools addSubview:allProductsButton];
    [tools addSubview:customProductsButton];
    [tools addSubview:filterButton];
    [tools addSubview:clearButton];
    [tools addSubview:txtSearch];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    
    selectedProducts = [[NSMutableArray alloc]  init];
    
    [self.view addSubview:_clearAll];
    [self.view addSubview:_saveSelection];
    
    
    UILabel *productsAvailable = [[UILabel alloc] init];
    productsAvailable.text = @"products available";
    productsAvailable.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsAvailable.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAvailable.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsAvailable.numberOfLines = 1;
    CGRect productsAvailableTitle = CGRectMake(20.0, 90.0, 300, 30.0);
    productsAvailable.frame = productsAvailableTitle;
    
    [self.view addSubview:productsAvailable];
    
    UILabel *productsAvailableSub = [[UILabel alloc] init];
    productsAvailableSub.text = @"Select a product to add to the list on the right";
    productsAvailableSub.font = [UIFont fontWithName:@"HelveticaNeue" size: 10.0f];
    productsAvailableSub.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAvailableSub.textColor = [UIColor blackColor];
    productsAvailableSub.numberOfLines = 1;
    CGRect productsAvailableSubText = CGRectMake(20.0, 120.0, 300, 20.0);
    productsAvailableSub.frame = productsAvailableSubText;
    
    [self.view addSubview:productsAvailableSub];
    
    CALayer *separator = [CALayer layer];
    separator.frame = CGRectMake(kPageWidth, 100, 1, 589);
    separator.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [self.view.layer addSublayer:separator];
    
    UILabel *productsAdd = [[UILabel alloc] init];
    productsAdd.text = @"products to add";
    productsAdd.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 26.0f];
    productsAdd.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAdd.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    productsAdd.numberOfLines = 1;
    CGRect productsAddTitle = CGRectMake((kPageWidth+20.0), 90.0, 300, 30.0); //kPageWidth, 70.0, 300, 30.0
    productsAdd.frame = productsAddTitle;
    
    [self.view addSubview:productsAdd];
    
    UILabel *productsAddSub = [[UILabel alloc] init];
    productsAddSub.text = @"Select a product to remove it from this list";
    productsAddSub.font = [UIFont fontWithName:@"HelveticaNeue" size: 10.0f];
    productsAddSub.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    productsAddSub.textColor = [UIColor blackColor];
    productsAddSub.numberOfLines = 1;
    CGRect productsAddSubText = CGRectMake((kPageWidth+20.0), 120.0, 300, 20.0);
    productsAddSub.frame = productsAddSubText;
    
    [self.view addSubview:productsAddSub];

    //add notification to listen for the collection being saved and call method to close the pop over
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advancedSearch:) name:@"ProductAdvancedSearch" object:nil];

}
- (NSFetchedResultsController*)constructsProducts
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSError *error;

    //fetch request to retrieve all products
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"productCode" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext:self.managedContext];
    [request setEntity:entity];
    
    // Set batch size
    [request setFetchBatchSize:9];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    if(isAdvancedSearch) {
        
        //use predicates
        if(predicate != nil) {
             [request setPredicate:predicate];
        }
        
    } else {
    
    if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && customProductsButton.selected) {
        //get only custom products
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productCode ='0000000000'"];
        [request setPredicate:pred];
    } else if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && customProductsButton.selected) {
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"(productName CONTAINS[cd] %@ OR productName LIKE[cd] %@) AND productCode ='0000000000'", txtSearch.text, txtSearch.text];
        [request setPredicate:pred];
    } else if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && allProductsButton.selected) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(productName CONTAINS[cd] %@ OR productName LIKE[cd] %@) OR (productCode CONTAINS[cd] %@ OR productCode LIKE[cd] %@)", txtSearch.text, txtSearch.text, txtSearch.text, txtSearch.text];
        [request setPredicate:pred];
    }
    }
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
    [_fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    
    //NSLog(@"count: %d",[_fetchedResultsController.fetchedObjects count]);
    
    productText = @"products";
    if([_fetchedResultsController.fetchedObjects count] ==1) {
        productText = @"product";
        
    }
    [noResults removeFromSuperview];
    [numProducts removeFromSuperview];
    numProducts = [[UILabel alloc] init];
    numProducts.text = [NSString stringWithFormat: @"%d %@", [_fetchedResultsController.fetchedObjects count], productText];
    numProducts.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    numProducts.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    numProducts.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    numProducts.numberOfLines = 1;
    CGRect numProductsTitle = CGRectMake(210.0, 58.0, 500, 30.0);
    numProducts.frame = numProductsTitle;
    
    [self.view addSubview:numProducts];
    
    if ([_fetchedResultsController.fetchedObjects count] == 0) {
        noResults = [[UILabel alloc] init];
        noResults.text = @"no products returned, please search again or sync data";
        noResults.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
        noResults.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
        noResults.textColor = [UIColor colorWithRed:217.0/255.0 green:54.0/255.0 blue:0 alpha:1];
        noResults.numberOfLines = 1;
        CGRect noResultsTitle = CGRectMake(20.0, 160.0, 500.0, 30.0);
        noResults.frame = noResultsTitle;
        
        [self.view addSubview:noResults];
    }
   
    return _fetchedResultsController;

}

- (void) filter {
    
    //dimiss the keyboard
    if([txtSearch isFirstResponder]) {
        [txtSearch resignFirstResponder];
    }
    
    isAdvancedSearch = NO;
    
    [selectedProducts removeAllObjects];
    [self constructsSelectedProducts];
    
    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self constructsProducts];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [_scrollView reloadData];
    });
    
}
- (void) clearSearch {
    //dimiss the keyboard
    if([txtSearch isFirstResponder]) {
        [txtSearch resignFirstResponder];
    }
    txtSearch.text = @"";
    [customProductsButton setSelected:NO];
    [allProductsButton setSelected:YES];
    
}

- (void)filterClicked:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    NSString *buttonTitle = button.currentTitle;
    
    if([buttonTitle  isEqual: @" all products"]) {
        
        customProductsButton.selected = !customProductsButton.selected;
        
    } else {
        allProductsButton.selected = !allProductsButton.selected;
    }
    
}

- (void)viewProductDetails:(id)sender {
    Product *p = (Product*)[[_fetchedResultsController fetchedObjects] objectAtIndex:((UIControl*)sender).tag];
    ProductViewController *detailsView =  [self.storyboard instantiateViewControllerWithIdentifier:@"productDetails"];
    detailsView.product = p;
    [self.navigationController pushViewController:detailsView animated:YES];
    
}
- (void)removeProductFromSelection:(id)sender {
    Product *product = [(ProductButton *)sender product];
    
    int index = [[_fetchedResultsController fetchedObjects] indexOfObject:product];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [indexPaths addObject:indexPath];

    [selectedProducts removeObject:product];
    [self constructsSelectedProducts]; //call method to redraw
    [_scrollView reloadItemsAtIndexPaths:indexPaths];
    

}
- (void)constructsSelectedProducts {
    
    for(UIView *view in self.view.subviews) {
        if(view.tag == 999999999) {
        [view removeFromSuperview];
        }
     }
    
    UIView *selectedProductsListView;
    UIScrollView *selectedProductsScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake((kPageWidth+20.0), 140, sPageWidth, sPageHeight)];
    selectedProductsScrollView.pagingEnabled = NO;
    selectedProductsScrollView.tag=999999999;
    
    int page =1;
    int col= 1;
    int row = 1;
    
    for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
        
        if(selectedProductsListView == nil)
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
    
         NSError *error;
        //get user's full name from app settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *creatorName = [defaults objectForKey:@"username"];
        
        //if no collection then validate for new one or existing one being selected
        if(!_collection){
            if(([self.txtNewCollection.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 && self.collectionList.isHidden) || ([self.txtNewCollection.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0  && [self.collectionList.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) ) {
            //alert user that there is no collection to add to
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"There is no collection to add products to!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            } else {
            
                if([creatorName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length ==0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection Error" message:@"Please add your name to app settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                
                } else {
                
                    
                    if([self.txtNewCollection.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) {
                        
                    //save the new collection
                    Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:self.managedContext];
                        
                    collection.collectionName = self.txtNewCollection.text;
                    collection.collectionCreator = creatorName;
                    collection.collectionCreationDate = [NSDate date];
                    collection.collectionLastUpdatedBy = creatorName;
                    collection.collectionLastUpdateDate = [NSDate date];
                        
                    //add unique identifier for custom product syncing
                    NSString *UUID = [[NSUUID UUID] UUIDString];
                    collection.collectionGUID = UUID;

                        if(![self.managedContext save:&error]) {
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
                        NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
                        NSManagedObjectID *c = [persistentStoreCoordinator managedObjectIDForURIRepresentation:(NSURL*)self.collectionList.getSelectedValue];
                        NSManagedObject *collectionElement = [self.managedContext objectWithID:c];
                        _collection = (Collection*)collectionElement;
                        //NSLog(@"existing collection: %@",_collection.collectionName);
                    }
                }
            }
        }
    
            if(_collection){
                //loop through selectedProducts array and each object to the collection
                //also count the number of products already in the collection and increment this to get the order number
                
                _collection.collectionLastUpdateDate = [NSDate date];
                _collection.collectionLastUpdatedBy = creatorName;
                
                if(![self.managedContext save:&error]) {
                    //NSLog(@"Could not update collection: %@", [error localizedDescription]);
                }
                
                for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
                    Product *product = [selectedProducts objectAtIndex:p];
        
                    //check it doesn't exist in the collection already
                    if(![_collection.products containsObject:product]){
        
                        //add collection
                        [product addCollectionsObject:_collection];
         
                        //add product order
                        ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:self.managedContext];
         
                        int number = [_collection.products count];
         
                        //NSLog(@"number: %d", number);
         
                        productOrder.productOrder = [NSNumber numberWithInt:number];
                        productOrder.orderCollection = _collection;
                        productOrder.orderProduct = product;
        
                        if(![self.managedContext save:&error]) {
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
    
     NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (int p = 0, pc = [selectedProducts count]; p < pc; p++) {
        //NSLog(@"selected list p: %d",p);
        Product *product = [selectedProducts objectAtIndex:p];
        int index = [[_fetchedResultsController fetchedObjects] indexOfObject:product];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [indexPaths addObject:indexPath];
    }
   
    [selectedProducts removeAllObjects];
    [self constructsSelectedProducts];
    [_scrollView reloadItemsAtIndexPaths:indexPaths];
}

-(void)onKeyboardHide:(NSNotification *)notification {
    //only animate if the view frame's y co-ordinate has been shifted up
    if(CGRectGetMaxY(self.view.frame) < 700) {
    [self animateTextField:self.txtNewCollection up:NO];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self animateTextField:textField up:YES];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}
-(void)animateTextField:(UITextField *)textField up:(BOOL)up{
    
    const int movementDistance = -330;
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
#pragma mark - UICollectionViewDataSource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
      return [[self.fetchedResultsController sections] count];
    
}
- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //NSLog(@"number of items in section %d",[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
}

-(void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Product *product = (Product*)object;
    if(![selectedProducts containsObject:product]){
        [selectedProducts addObject:product];
        [self constructsSelectedProducts]; //call method to redraw
        [_scrollView reloadItemsAtIndexPaths:[_scrollView indexPathsForVisibleItems]];
    }
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Product *product = (Product*)object; 
    ProductCell *productCell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    productCell.product = product;

    if([selectedProducts containsObject:product]){
        //add opacity
         productCell.productImageView.layer.opacity  = 0.1;
    } else {
         productCell.productImageView.layer.opacity  = 1.0;
    }
    
    [productCell.productInfoButton addTarget:self action:@selector(viewProductDetails:) forControlEvents:UIControlEventTouchUpInside];
    [productCell.productInfoButton setTag:indexPath.item];
    
    return productCell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _sectionChanges = [[NSMutableArray alloc] init];
    _itemChanges = [[NSMutableArray alloc] init];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if ([_sectionChanges count] > 0)
    {
        [_scrollView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [_scrollView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [_scrollView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [_scrollView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if ([_itemChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || _scrollView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [_scrollView reloadData];
            
        } else {
            
            [_scrollView performBatchUpdates:^{
                
                for (NSDictionary *change in _itemChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [_scrollView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [_scrollView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [_scrollView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [_scrollView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_itemChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    
    for (NSDictionary *change in _itemChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([_scrollView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([_scrollView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    //return shouldReload;
    return YES;
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
