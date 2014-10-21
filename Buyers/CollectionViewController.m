

#import "CollectionViewController.h"
#import "SWRevealViewController.h"
#import "BaseViewController.h"
#import "Product.h"
#import "ProductOrder.h"
#import "ProductCell.h"
#import "ProductsViewController.h"
#import "AppDelegate.h"
#import "ProductViewController.h"
#import "SidebarViewController.h"
#import <QuartzCore/QuartzCore.h>

// LX_LIMITED_MOVEMENT:
// 0 = Any card can move anywhere
// 1 = Only Spade/Club can move within same rank

#define LX_LIMITED_MOVEMENT 0

@implementation CollectionViewController {
    NSMutableArray *deletions;
    NSString *productText;
    UILabel *numProducts;
    UIView *tools;
    UIButton *saveCollectionButton;
}

@synthesize displayNotesPopover = _displayNotesPopover;
@synthesize collectionNotes = _collectionNotes;
@synthesize collection=_collection;
@synthesize addProductButton = _addProductButton;

-(IBAction)saveCollectionNotes:(id)sender {
    //protocol method callback - empty to avoid warning
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"collection" title2:_collection.collectionName image:@"homePaperClipLogo.png"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd MMMM yyyy"];
    NSDate *creationDate = _collection.collectionCreationDate;
    NSString *formatDate = [dateFormat stringFromDate:creationDate];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@ - %@", formatDate, _collection.collectionCreator]]];
   
    //hack to push content down
    self.collectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    //add notification to listen for the collection being saved and call method to close the pop over
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionNotesSaved:) name:@"CollectionNotesSaved" object:nil];

    
}
- (void)collectionNotesSaved:(NSNotification *)notification
{
    [self.displayNotesPopover dismissPopoverAnimated:YES];
    
    /*NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    NSManagedObjectID *collectionID = [[notification userInfo] valueForKey:@"collectionID"];
    Collection *collection = (Collection *) [managedContext existingObjectWithID:collectionID error:&error];
    NSLog(@"notes *: %@", collection.collectionNotes);*/
    
    
}
- (IBAction)displayNotesPopover:(id)sender {
    
    if (_collectionNotes== nil) {
        self.collectionNotes = [self.storyboard instantiateViewControllerWithIdentifier:@"collectionNotes"];
        _collectionNotes.delegate = self;
        _collectionNotes.collection = _collection;
        
        self.displayNotesPopover = [[UIPopoverController alloc] initWithContentViewController:_collectionNotes];
    }
    
    [self.displayNotesPopover presentPopoverFromRect:_notesButton.bounds  inView:_notesButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    
}
- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //clear menu buttons
    SidebarViewController *sidebar = (SidebarViewController*)self.revealViewController.rearViewController;
    
    if(sidebar.menuItem1 != nil) {
        [sidebar.menuItem1 removeFromSuperview];
    }
    sidebar.menuItem1 = nil;
    if(sidebar.menuItem2 != nil) {
        [sidebar.menuItem2 removeFromSuperview];
    }
    sidebar.menuItem2 = nil;
    if(sidebar.menuItem3 != nil) {
        [sidebar.menuItem3 removeFromSuperview];
    }
    sidebar.menuItem3 = nil;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"schuhMenuIcon-S.png"] forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"+ product(s)" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setBackgroundImage:[UIImage imageNamed:@"rightArrowButtonBG.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    button.frame = CGRectMake(20, 40, 200, 60);
    sidebar.menuItem1 = button;
    [sidebar.view addSubview:button];
    
    [button addTarget:self action:@selector(addProductToCollection:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //should only show this if there are products but in view will appear the number of products isn't known
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"delete product(s)" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor whiteColor]];
    [button2 setBackgroundImage:[UIImage imageNamed:@"rightArrowButtonBG.png"] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button2 setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [button2.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    [button2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    button2.frame = CGRectMake(20, 120, 200, 60);
    sidebar.menuItem2 = button2;
    [sidebar.view addSubview:button2];
    
    [button2 addTarget:self action:@selector(deleteProducts:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.products = [self constructsProducts];
    deletions = [[NSMutableArray alloc] initWithCapacity:[self.products count]];
    
    //set all the checkbox buttons back to a not selected state
    if([self.products count] > 0) {
        NSMutableArray *cells = [[NSMutableArray alloc] init];
        for (NSInteger j = 0; j < [self.collectionView numberOfSections]; j++)
        {
            for (NSInteger i = 0; i < [self.collectionView numberOfItemsInSection:j]; i++)
            {
                
                [cells addObject:[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]];
                
            }
        }
        
        for (ProductCell *cell in cells)
        {
            UIButton *productDeleteButton = [cell productDeleteButton];
            [productDeleteButton setSelected:NO];
            
        }
    }
    
    [self.collectionView reloadData];
    
    
    tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 310, 65)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    
    saveCollectionButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [saveCollectionButton setTitle:@"save collection" forState:UIControlStateNormal];
    saveCollectionButton.frame = CGRectMake(160, 0, 150, 50);
    [saveCollectionButton addTarget:self action:@selector(saveCollection:) forControlEvents:UIControlEventTouchUpInside];
    saveCollectionButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    saveCollectionButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    
    _notesButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_notesButton setTitle:@"notes" forState:UIControlStateNormal];
    if([self.products count] > 0 ) {
        _notesButton.frame = CGRectMake(0, 0, 150, 50);
    } else {
        _notesButton.frame = CGRectMake(160, 0, 150, 50);
    }
    _notesButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    _notesButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:133.0/255.0 blue:178.0/255.0 alpha:1];
    [_notesButton addTarget:self action:@selector(displayNotesPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    if([self.products count] > 0 ) {
        [tools addSubview:saveCollectionButton];
    }
    [tools addSubview:_notesButton];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    

}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}


- (void)addProductToCollection:(id)sender {

    ProductsViewController  *productsViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"ProductsViewController"];
    
    productsViewController.collection = _collection;
    //NSLog(@"collection: %@",self.collection.collectionName);
    [self.navigationController pushViewController:productsViewController animated:YES];
    
}
- (NSMutableArray *)constructsProducts {
    
    
    NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"productOrder" ascending:YES];
    //NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numericSort,nil];
    NSArray *products = [self.collection.collectionProductOrder sortedArrayUsingDescriptors:sortDescriptors];
    
   // NSLog(@"products: %d", [products count]);
    
    NSMutableArray *newProducts = [[NSMutableArray alloc] initWithCapacity:[products count]];
    
    for (int i = 0, ic = [products count]; i < ic; i++) {
        ProductOrder *productOrder = [products objectAtIndex:i];
        Product *productElement = productOrder.orderProduct;
        [newProducts addObject:productElement];
    }
    
    if([products count] == 0){
        //display message
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(210, 60, 300, 50))];
        label.text = @"no products have been added to this collection";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0];
        label.textColor = [UIColor colorWithRed:217.0/255.0 green:54.0/255.0 blue:0 alpha:1];
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        [self.collectionView addSubview:label];
        
        //display add new product button
        _addProductButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_addProductButton setTitle:@"+ product(s)" forState:UIControlStateNormal];
        [_addProductButton addTarget:self action:@selector(addProductToCollection:) forControlEvents:UIControlEventTouchUpInside];
        [_addProductButton setFrame:CGRectMake(210, 120, 200, 60)];
        [ _addProductButton setBackgroundColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229/255.0 alpha:1]];
        [_addProductButton setTitleColor:[UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1] forState:UIControlStateNormal];
        _addProductButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        [_addProductButton setTag:1];
        [self.collectionView addSubview:_addProductButton];
        [saveCollectionButton removeFromSuperview];
         _notesButton.frame = CGRectMake(160, 0, 150, 50);
    } else {
        for(UIView *view in self.collectionView.subviews) {
            [view removeFromSuperview];
        }
    }
    
    productText = @"products";
    if([products count] ==1) {
        productText = @"product";
        
    }
    [numProducts removeFromSuperview];
    numProducts = [[UILabel alloc] init];
    numProducts.text = [NSString stringWithFormat: @"%d %@", [products count], productText];
    numProducts.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    numProducts.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    numProducts.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    numProducts.numberOfLines = 1;
    CGRect numProductsTitle = CGRectMake(210.0, 58.0, 500, 30.0);
    numProducts.frame = numProductsTitle;
    
    [self.view addSubview:numProducts];
    
    return newProducts;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return self.products.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = self.products[indexPath.item];
    ProductCell *productCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    productCell.product = product;
    productCell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    [productCell.productDeleteButton setSelected:NO];
    [productCell.productDeleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [productCell.productDeleteButton setTag:indexPath.row];
    
    return productCell;
}
- (void)deleteButtonClicked:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    Product *product = [self.products objectAtIndex:[sender tag]];
    
    if(button.selected ==YES) {
        //add collection to array for deletion
         if(![deletions containsObject:product]){
        [deletions addObject:product];
         }
    } else {
        //remove collection from array for deletion
         if([deletions containsObject:product]){
        [deletions removeObject:product];
         }
        
    }
    
    //NSLog(@"deletions: %d", [deletions count]);
    
}

- (void)deleteProducts:(id)sender {
    
    if([deletions count] > 0) {
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error;
        
        for (int i = 0, ic = [deletions count]; i < ic; i++) {
            Product *product = [deletions objectAtIndex:i];
            if([self.products containsObject:product]){
            //[product removeCollectionsObject:_collection];
            //[_collection removeProductsObject:product];
                [self.products removeObject:product];
               //NSLog(@"product being deleted %@ product in array %@", &product,  );
            }
            
          
        }
        
        
        //remove set of products and ordering from collection - had to do this as object is not removed from relationship by calling the accessor methods above
        [_collection removeProducts:_collection.products];
        [_collection removeCollectionProductOrder:_collection.collectionProductOrder];
        if(![managedContext save:&error]) {
            NSLog(@"Error removing products and product ordering from collection: %@",[error localizedDescription]);
            
        }
        
        
        for (int p = 0, pc = [self.products count]; p < pc; p++) {
            
            Product *product = [self.products objectAtIndex:p];
            
            //NSLog(@"product: %@", product.productName);
            
            //add  product back into collection
            [product addCollectionsObject:_collection];
            
            //add product order
            ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:managedContext];
            
            int number = (p+1);
            
            //NSLog(@"number: %d", number);
            
            productOrder.productOrder = [NSNumber numberWithInt:number];
            productOrder.orderCollection = _collection;
            productOrder.orderProduct = product;
            
            if(![managedContext save:&error]) {
                NSLog(@"Error saving products and product ordering to collection: %@",[error localizedDescription]);
                
            }
            
        }

        
        self.products = [self constructsProducts];
        deletions = [[NSMutableArray alloc] initWithCapacity:[self.products count]];
        
        [self.collectionView reloadData];
        
        
    } else {
        //alert user that there are no collections to delete
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Error" message:@"There are no products to delete!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    Product *product = self.products[fromIndexPath.item];
    
    [self.products removeObjectAtIndex:fromIndexPath.item];
    [self.products insertObject:product atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
#if LX_LIMITED_MOVEMENT == 1
    Product *product = self.products[indexPath.item];
    
    /*switch (playingCard.suit) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return YES;
        } break;
        default: {
            return NO;
        } break;
    }*/
#else
    return YES;
#endif
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
#if LX_LIMITED_MOVEMENT == 1
    Product *fromProduct = self.products[fromIndexPath.item];
    Product *toProduct = self.products[toIndexPath.item];
    
    
    NSLog(@"product: %@", fromProduct.productName);
    /*switch (toPlayingCard.suit) {
        case PlayingCardSuitSpade:
        case PlayingCardSuitClub: {
            return fromPlayingCard.rank == toPlayingCard.rank;
        } break;
        default: {
            return NO;
        } break;
    }*/
#else
    return YES;
#endif
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"will begin drag");
   // NSLog(@"start index: %ld", (long)indexPath.row);
    
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    // NSLog(@"did end drag");
    // NSLog(@"end index: %ld", (long)indexPath.row);
    Product *product = [self.products objectAtIndex:indexPath.row];
    //NSLog(@"product to be deleted from deletions array is %@ index: %ld", product.productName, (long)indexPath.row);
    if([deletions containsObject:product]){
        [deletions removeObject:product];
    }

}

-(IBAction)saveCollection:(id)sender{
    
    //loop through selectedProducts array and each object to the collection
     //also count the number of products already in the collection and increment this to get the order number
     NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
     NSError *error;
    
     //remove set of product ordering from collection
     [_collection removeCollectionProductOrder:_collection.collectionProductOrder];
     if(![managedContext save:&error]) {
         NSLog(@"Error removing product ordering from collection: %@",[error localizedDescription]);
         
     }
     
     
     for (int p = 0, pc = [self.products count]; p < pc; p++) {
         
         Product *product = [self.products objectAtIndex:p];
         
         //NSLog(@"product: %@", product.productName);
         
         //add product order
         ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:managedContext];
         
         int number = (p+1);
         
         //NSLog(@"number: %d", number);
         
         productOrder.productOrder = [NSNumber numberWithInt:number];
         productOrder.orderCollection = _collection;
         productOrder.orderProduct = product;
         
         if(![managedContext save:&error]) {
             NSLog(@"Error saving product ordering: %@",[error localizedDescription]);
             
         }
         
     }
    
    
    //alert user that collection has been save
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Collection" message:@"The collection has been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {       
        
        if([segue.identifier compare:@"productDetail"] == NSOrderedSame) {
            ProductViewController *detailsView = segue.destinationViewController;
            NSIndexPath *index = [self.collectionView indexPathForCell:sender];
            Product *p= [self.products objectAtIndex:index.row];
            detailsView.collection = _collection;
            detailsView.product = p;
        }
    
}

@end
