
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


#define LX_LIMITED_MOVEMENT 0

static const float kColumnWidth = 341.5;
static const float kRowHeight = 288.0;
static const float kButtonWidth = 341.5;
static const float kButtonHeight = 288.0;
static const float kPageWidth = 1024.0;
static const float kPageHeight = 746.0;
static const float kNavBarHeight = 40.0;
static const float kProductWidth = 68.0;
static const float kProductHeight = 68.0;
static const float kProductColumnSpacer = 14.0;

@interface CollectionListViewController () {
    NSArray *collections;
}
@end

@implementation CollectionListViewController

@synthesize addCollectionPopover = _addCollectionPopover;
@synthesize addCollection = _addCollection;
@synthesize addCollectionButton = _addCollectionButton;
@synthesize menu1 = _menu1;

-(IBAction)saveNewCollection:(id)sender {
    //protocol method callback - empty to avoid warning
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _menu1 = [self setMenuButton:1 title:@"+ new collection"];
    
    [_menu1 addTarget:self action:@selector(displayNewCollectionPopover:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)alert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"alert" message:[NSString stringWithFormat:@"test"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"your" title2:@"collections" image:@"homePaperClipLogo.png"];
    
    //self.deck = [self constructsDeck];
    
    //hack to push content down
    //self.collectionView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);

    
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
    NSError *error;
    NSArray *results = [managedContext executeFetchRequest:request error:&error];
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"collectionID" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"collectionName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    collections = [results sortedArrayUsingDescriptors:sortDescriptors];
    
     //[managedContext deleteObject:collectionsElement];
    
    if ([collections count] > 0 ) {
        
        int page = 1;
        int col = 1;
        int row = 1;
        
        UIView *collectionListView;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, kPageWidth, kPageHeight)];
        scrollView.pagingEnabled = NO;
        
        for (int i = 0, ic = [collections count]; i < ic; i++) {
        
            /*if(i==0) {

            //add dummy product to each collection
            Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
            
            product.productCode = @"1461031160";
            product.productName = @"iced gem abigail";
            product.productBrand = @"irregular choice";
            product.productCategory = @"high heels";
            product.productColour = @"Stone";
            product.productMaterial = @"Man-Made";
            product.productPrice = [NSNumber numberWithDouble:90.00];
            product.productSupplier = @"irregular choice";
            product.productNotes = @"This is a test product inserted manually";
            
            //add collection
            [product addCollectionsObject:[collections objectAtIndex:i]];
            
            //add image
            UIImage *image = [UIImage imageNamed:@"1461031160_main.jpg"];//[UIImage imageWithBase64Data:brand.brandHeaderLogo];
            NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1)];
            
            product.productImageData = imageData;
            
            //add additional images
            //Image *productImage = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedContext];
            //productImage.imageData = imageData;
            
            //[product addImagesObject:productImage];
            
                if(![managedContext save:&error]) {
                    NSLog(@"Could not save product: %@", [error localizedDescription]);
                    
                }
            }*/
            
            if(collectionListView == nil)
                collectionListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * kPageWidth), kNavBarHeight, kPageWidth, kPageHeight)];
            
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
            NSSortDescriptor *alphaSortProducts = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
            NSArray *sortDescriptorsProducts = [[NSArray alloc] initWithObjects:alphaSortProducts,nil];
            products = [collectionElement.products sortedArrayUsingDescriptors:sortDescriptorsProducts];
        
            
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
                Product *productElement = [products objectAtIndex:p];
                
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
            CGRect framePNumTitle = CGRectMake(0.0, (kButtonHeight-20.0), kButtonWidth, 20.0);
            collectionNumProducts.frame = framePNumTitle;
            
            [collectionButton addSubview:collectionNumProducts];
            col++;
            
            if(col > 3) {
                row++;
                col= 1;
            }
            
            [collectionListView addSubview:collectionButton];
            
            BOOL isLastPage = ((ic % 9 > 0) && (ic - i == 1));
            
            if(row > 3 && !isLastPage) {
                //increment page number and add view to scroll view
                [scrollView addSubview:collectionListView];
                page++;
                row = 1;
                collectionListView = [[UIView alloc] initWithFrame:CGRectMake(((page - 1) * kPageWidth), kNavBarHeight, kPageWidth, kPageHeight)];
            } else if(isLastPage) {
                [scrollView addSubview:collectionListView];
            }
            
        
        scrollView.contentSize = CGSizeMake(kPageWidth,(kPageHeight * page));
            // NSLog(@"height: %f",(kPageHeight * page));
        }
        [self.view addSubview:scrollView];
       
    } else {
        
        //display message
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(210, 60, 300, 50))];
        label.text = @"no collections have been added";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:30.0];
        label.textColor = [UIColor colorWithRed:217.0/255.0 green:54.0/255.0 blue:0 alpha:1];
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:label];
        
        //display add new collection button
        _addCollectionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_addCollectionButton setTitle:@"+ new collection" forState:UIControlStateNormal];
        [_addCollectionButton addTarget:self action:@selector(displayNewCollectionPopover:) forControlEvents:UIControlEventTouchUpInside];
        [_addCollectionButton setFrame:CGRectMake(210, 120, 200, 60)];
        [ _addCollectionButton setBackgroundColor:[UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229/255.0 alpha:1]];
        [_addCollectionButton setTitleColor:[UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1] forState:UIControlStateNormal];
        _addCollectionButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        [_addCollectionButton setTag:1];
        [self.view addSubview:_addCollectionButton];
        
    }
    
    //add notification to listen for the collection being saved and call method to close the pop over and go to collections view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNewCollection:) name:@"GoToNewCollection" object:nil];
    
}
- (void)goToNewCollection:(NSNotification *)notification
{
    [self.addCollectionPopover dismissPopoverAnimated:YES];
    
    //need to refresh this view so when back button is clicked the new collection appears
    
    //go to new collection view so user can add products
    CollectionViewController  *collectionViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    NSManagedObjectID *collectionID = [[notification userInfo] valueForKey:@"collectionID"];
    Collection *collection = (Collection *) [managedContext existingObjectWithID:collectionID error:&error];
    
    collectionViewController.collection = collection;
    [self.navigationController pushViewController:collectionViewController animated:YES];

    
}
- (void)collectionButtonClicked:(id)sender {
    Collection *collection = [(CollectionButton *)sender collection];

    CollectionViewController  *collectionViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    collectionViewController.collection = collection;
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
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
