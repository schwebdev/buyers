
#import "CollectionListViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "Collection.h"
#import "CollectionCell.h"
#import "NewCollectionViewController.h"
#import "CollectionViewController.h"
#import "CollectionButton.h"
#import <QuartzCore/QuartzCore.h>
#import "Product.h"
#import "ProductOrder.h"
#import "Brand.h"
#import "Supplier.h"
#import "Material.h"
#import "ProductCategory.h"
#import "Colour.h"
#import "Sync.h"
#import "SchTextField.h"
#import "SchDropDown.h"


#define LX_LIMITED_MOVEMENT 0

static const float kPageHeight = 576.0;

@interface CollectionListViewController () {
    NSMutableArray *deletions;
    UIButton *filterButton, *clearButton;
    UIButton *allUsersButton;
    UIButton *yourOwnButton;
    SchTextField *txtSearch;
    SchDropDown *brandsList;
    UIView *tools;
    UILabel *numCollections, *brandListLabel, *searchTextLabel;
    NSString *collectionText;
    NSPredicate *predicate;
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
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
    
     self.managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    _itemChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"your" title2:@"collections" image:@"homePaperClipLogo.png"];
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:@"List of Collections"]];
    
    tools=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 610, 100)];
    tools.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.navigationController.toolbar.clipsToBounds = YES;
    
    allUsersButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 38, 100, 24)];
    [allUsersButton setTitle:@" all users" forState:UIControlStateNormal];
    allUsersButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [allUsersButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allUsersButton setSelected:YES];
    [allUsersButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [allUsersButton setImage:[UIImage imageNamed:@"checkbox-checked-search.png"] forState:UIControlStateSelected];
    [allUsersButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];

    yourOwnButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 3, 100, 24)];
    [yourOwnButton setTitle:@" your own" forState:UIControlStateNormal];
    yourOwnButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size: 12.0];
    [yourOwnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [yourOwnButton setSelected:NO];
    [yourOwnButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
    [yourOwnButton setImage:[UIImage imageNamed:@"checkbox-checked-search.png"] forState:UIControlStateSelected];
    [yourOwnButton addTarget:self action:@selector(filterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    filterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [filterButton setTitle:@"filter" forState:UIControlStateNormal];
    filterButton.frame = CGRectMake(400, 10, 100, 50);
    [filterButton addTarget:self action:@selector(filter) forControlEvents:UIControlEventTouchUpInside];
    filterButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    filterButton.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    
    clearButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setTitle:@"clear" forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(510, 10, 100, 50);
    [clearButton addTarget:self action:@selector(clearSearch) forControlEvents:UIControlEventTouchUpInside];
    clearButton.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Thin" size: 18.0f];
    clearButton.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    
    txtSearch = [[SchTextField alloc] initWithFrame:CGRectMake(190, 35, 200, 30)];
    brandsList = [[SchDropDown alloc] initWithFrame:CGRectMake(190, 0, 200, 30)];
    searchTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 35, 80, 30)];
    brandListLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 80, 30)];
    searchTextLabel.text = @"search term";
    brandListLabel.text = @"select brand";
    searchTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    brandListLabel.font= [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    
    //brand drop down
    [brandsList setListItems:(NSMutableArray *)[Sync getTable:@"Brand" sortWith:@"brandName"] withName:@"brandName" withValue:@"brandRef"];
    
    
    CALayer *searchDivider = [CALayer layer];
    searchDivider.frame = CGRectMake(100, 6, 1, 56);
    searchDivider.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1].CGColor;
    [tools.layer addSublayer:searchDivider];
    
    [tools addSubview:allUsersButton];
    [tools addSubview:yourOwnButton];
    [tools addSubview:filterButton];
    [tools addSubview:clearButton];
    [tools addSubview:txtSearch];
    [tools addSubview:brandsList];
    [tools addSubview:searchTextLabel];
    [tools addSubview:brandListLabel];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];

    
    //show or hide next and previous arrows
    _upArrow = [[UIImageView alloc] initWithFrame:CGRectMake(20, (kPageHeight+90), 35.5, 27)];
    _upArrow.hidden = YES;
    [_upArrow setImage:[UIImage imageNamed:@"arrowUP.png"]];
    [self.view addSubview:_upArrow];
    
    _downArrow = [[UIImageView alloc] initWithFrame:CGRectMake(968.5, (kPageHeight+90), 35.5, 27)];
    _downArrow.hidden = YES;
    [_downArrow setImage:[UIImage imageNamed:@"arrowDOWN.png"]];
    [self.view addSubview:_downArrow];
    
    //add notification to listen for the collection being saved and call method to close the pop over and go to collections view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNewCollection:) name:@"GoToNewCollection" object:nil];
    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
       
    _menu1 = [self setMenuButton:1 title:@"+ new collection(s)"];
    
    [_menu1 addTarget:self action:@selector(displayNewCollectionPopover:) forControlEvents:UIControlEventTouchUpInside];
    
    _menu2 = [self setMenuButton:2 title:@"delete collections"];

    [_menu2 addTarget:self action:@selector(deleteCollections:) forControlEvents:UIControlEventTouchUpInside];
    
    self.fetchedResultsController = nil;
    
    self.fetchedResultsController = [self constructsCollections];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [_scrollView reloadData];
    });
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void) filter {
    //dimiss the keyboard
    if([txtSearch isFirstResponder]) {
        [txtSearch resignFirstResponder];
    }
    
    NSMutableArray *preds = [[NSMutableArray alloc]initWithCapacity:1];

    if([txtSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
        NSPredicate *namePred =[NSPredicate predicateWithFormat:@"collectionName CONTAINS[cd] %@ OR collectionName LIKE[cd] %@",txtSearch.text,txtSearch.text];
        [preds addObject:namePred];
    }
    
    if(yourOwnButton.selected) {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
        NSPredicate *creatorPred =[NSPredicate predicateWithFormat:@"collectionCreator =[cd] %@",creatorName];
        [preds addObject:creatorPred];
        
    }
    
    if([brandsList.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {

        NSPredicate *brandPred =[NSPredicate predicateWithFormat:@"collectionBrandRef == %d", [brandsList.getSelectedValue integerValue]];
        [preds addObject:brandPred];
    }
    
    NSPredicate *deletionPred =[NSPredicate predicateWithFormat:@"collectionDeleted == %@", [NSNumber numberWithBool:NO]];
    [preds addObject:deletionPred];

    
    predicate=[NSCompoundPredicate andPredicateWithSubpredicates:preds];
    
    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self constructsCollections];
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
    brandsList.text = @"";
    [yourOwnButton setSelected:NO];
    [allUsersButton setSelected:YES];
    
    
}
- (void)viewDidUnload {
    self.fetchedResultsController = nil;
}

- (NSFetchedResultsController*)constructsCollections
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    //hide for refresh
    _upArrow.hidden = YES;
    _downArrow.hidden = YES;
    
    //fetch request to retrieve all collections
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
    NSError *error;
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"collectionID" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"collectionName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.managedContext];
    [request setEntity:entity];
    
    
    // Set batch size
    [request setFetchBatchSize:6];
    
    [request setSortDescriptors:sortDescriptors];
    
    
    if(predicate != nil) {
        
        [request setPredicate:predicate];
        
    } else {
        NSPredicate *deletionPred =[NSPredicate predicateWithFormat:@"collectionDeleted == %@", [NSNumber numberWithBool:NO]];
        [request setPredicate:deletionPred];

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
    
    //NSLog(@"insertion count %d",[self.fetchedResultsController.fetchedObjects count]);
   
    collectionText = @"collections";
    if([self.fetchedResultsController.fetchedObjects count] ==1) {
        collectionText = @"collection";
        
    }

    [numCollections removeFromSuperview];
    numCollections = [[UILabel alloc] init];
    numCollections.text = [NSString stringWithFormat: @"%d %@", [_fetchedResultsController.fetchedObjects count], collectionText];
    numCollections.font = [UIFont fontWithName:@"HelveticaNeue" size: 12.0f];
    numCollections.backgroundColor = [UIColor clearColor]; //gets rid of right border on uilabel
    numCollections.textColor = [UIColor colorWithRed:128.0/255.0 green:175.0/255.0 blue:23.0/255.0 alpha:1];
    numCollections.numberOfLines = 1;
    CGRect numCollectionsTitle = CGRectMake(210.0, 58.0, 500, 30.0);
    numCollections.frame = numCollectionsTitle;
    
    [self.view addSubview:numCollections];
    
    deletions = [[NSMutableArray alloc] initWithCapacity:[_fetchedResultsController.fetchedObjects count]];
    
   
    if ([_fetchedResultsController.fetchedObjects count] == 0 ) {
        
        //display message
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(210, 60, 500, 50))];
        label.text = @"no collections returned, please search again or add a new collection";
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
        
    } else {
            for(UIView *view in _scrollView.subviews) {
                [view removeFromSuperview];
            }
    }
    
    if ([_fetchedResultsController.fetchedObjects count] > 6 ) {
        _downArrow.hidden = NO;
    }
    return _fetchedResultsController;
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
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
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //NSLog(@"y: %f height: %f pageheight: %f" ,_scrollView.contentOffset.y, _scrollView.contentSize.height, kPageHeight);
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
- (void)goToNewCollection:(NSNotification *)notification
{
    [self.addCollectionPopover dismissPopoverAnimated:YES];

    predicate=nil;
    txtSearch.text=@"";
    brandsList.text=@"";
    
    self.fetchedResultsController = nil;
    self.fetchedResultsController = [self constructsCollections];
    dispatch_async(dispatch_get_main_queue(),^{
        [_scrollView reloadData];
    });
    
    if(self.revealViewController.frontViewPosition ==4) {
        [self.revealViewController revealToggleAnimated:YES];
    }

    //calling pushViewController before viewDidAppear is unsafe and is causing the subview tree to get corrupted on occasion - this is resulting in the collection object not being available in the collection view controller after viewDidLoad so aborting this stage and refreshing results instead
    
    /*go to new collection view so user can add products
    CollectionViewController  *collectionViewController =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    self.managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    
    NSManagedObjectID *collectionID = [[notification userInfo] valueForKey:@"collectionID"];
    Collection *collection = (Collection *) [self.managedContext existingObjectWithID:collectionID error:&error];
    
    collectionViewController.collection = collection;
    [self.navigationController pushViewController:collectionViewController animated:YES];
    */
    
    
}

- (void)deleteButtonClicked:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    

    Collection *collection = (Collection*)[[_fetchedResultsController fetchedObjects] objectAtIndex:[sender tag]];
    
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
     
        NSError *error;
        
        for (int i = 0, ic = [deletions count]; i < ic; i++) {
            Collection *collection = [deletions objectAtIndex:i];
            collection.collectionDeleted = [NSNumber numberWithBool:YES];
            //get user's full name from app settings
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *creatorName = [defaults objectForKey:@"username"];
            collection.collectionLastUpdatedBy = creatorName;
            collection.collectionLastUpdateDate = [NSDate date];
            [collection removeProducts:collection.products];
            if(![self.managedContext save:&error]) {
                NSLog(@"Could not save deleted collection: %@ error: %@", collection.collectionName,[error localizedDescription]);
                
            }
        }
        
       
        self.fetchedResultsController = nil;
        self.fetchedResultsController = [self constructsCollections];
        dispatch_async(dispatch_get_main_queue(),^{
            [_scrollView reloadData];
        });
        
        [self.revealViewController revealToggleAnimated:YES];
        
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


#pragma mark - UICollectionViewDataSource methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //NSLog(@"number of sections: %d",[[self.fetchedResultsController sections] count]);
    return [[self.fetchedResultsController sections] count];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    //NSLog(@"number of items in section %d",[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
   
}
-(void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    

    Collection *collection = (Collection*)object; //self.collections[indexPath.item];
    CollectionViewController  *collectionVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"collectionView"];
    
    collectionVC.collection = collection;
    [self.navigationController pushViewController:collectionVC animated:YES];

    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Collection *collection = (Collection*)object; //self.collections[indexPath.item];
    CollectionCell *collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    collectionCell.collection = collection;

    [collectionCell.collectionDeleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [collectionCell.collectionDeleteButton setTag:indexPath.item];
    
    return collectionCell;
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
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeMove:
        default:
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
                        case NSFetchedResultsChangeMove:
                        default:
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
@end
