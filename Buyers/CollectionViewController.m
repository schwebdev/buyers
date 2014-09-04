

#import "CollectionViewController.h"
#import "SWRevealViewController.h"
#import "BaseViewController.h"
#import "PlayingCard.h"
#import "PlayingCardCell.h"
#import "Product.h"
#import "ProductCell.h"


// LX_LIMITED_MOVEMENT:
// 0 = Any card can move anywhere
// 1 = Only Spade/Club can move within same rank

#define LX_LIMITED_MOVEMENT 0

@implementation CollectionViewController

@synthesize collection=_collection;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"collection" title2:_collection.collectionName image:@"homePaperClipLogo.png"];
    

    self.products = [self constructsProducts];
    
    
    //hack to push content down
    self.collectionView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0);
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSMutableArray *)constructsProducts {
    
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    NSArray *products = [self.collection.products sortedArrayUsingDescriptors:sortDescriptors];

    //NSLog(@"products: %d", [products count]);
    
    NSMutableArray *newDeck = [[NSMutableArray alloc] initWithCapacity:[products count]];
    
    for (int i = 0, ic = [products count]; i < ic; i++) {
         Product *productElement = [products objectAtIndex:i];
        [newDeck addObject:productElement];
    }
    
    return newDeck;
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
    
    return productCell;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    Product *product = self.products[fromIndexPath.item];
    
    [self.products removeObjectAtIndex:fromIndexPath.item];
    [self.products insertObject:product atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
#if LX_LIMITED_MOVEMENT == 1
    Product *product = self.deck[indexPath.item];
    
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
    Product *fromProduct = self.deck[fromIndexPath.item];
    Product *toProduct = self.deck[toIndexPath.item];
    
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
}

@end
