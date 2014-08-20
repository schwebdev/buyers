

#import "CollectionViewController.h"
#import "SWRevealViewController.h"
#import "BaseViewController.h"
#import "PlayingCard.h"
#import "PlayingCardCell.h"

// LX_LIMITED_MOVEMENT:
// 0 = Any card can move anywhere
// 1 = Only Spade/Club can move within same rank

#define LX_LIMITED_MOVEMENT 0

@implementation CollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"collection" title2:@"collection name" image:@"homePaperClipLogo.png"];
    
        
    self.deck = [self constructsDeck];
    
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

- (NSMutableArray *)constructsDeck {
    NSMutableArray *newDeck = [NSMutableArray arrayWithCapacity:52];
    
    for (NSInteger rank = 1; rank <= 13; rank++) {
        // Spade
        {
            PlayingCard *playingCard = [[PlayingCard alloc] init];
            playingCard.suit = PlayingCardSuitSpade;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Heart
        {
            PlayingCard *playingCard = [[PlayingCard alloc] init];
            playingCard.suit = PlayingCardSuitHeart;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Club
        {
            PlayingCard *playingCard = [[PlayingCard alloc] init];
            playingCard.suit = PlayingCardSuitClub;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
        
        // Diamond
        {
            PlayingCard *playingCard = [[PlayingCard alloc] init];
            playingCard.suit = PlayingCardSuitDiamond;
            playingCard.rank = rank;
            [newDeck addObject:playingCard];
        }
    }
    
    return newDeck;
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return self.deck.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayingCard *playingCard = self.deck[indexPath.item];
    PlayingCardCell *playingCardCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayingCardCell" forIndexPath:indexPath];
    playingCardCell.playingCard = playingCard;
    playingCardCell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    return playingCardCell;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    PlayingCard *playingCard = self.deck[fromIndexPath.item];
    
    [self.deck removeObjectAtIndex:fromIndexPath.item];
    [self.deck insertObject:playingCard atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
#if LX_LIMITED_MOVEMENT == 1
    PlayingCard *playingCard = self.deck[indexPath.item];
    
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
    PlayingCard *fromPlayingCard = self.deck[fromIndexPath.item];
    PlayingCard *toPlayingCard = self.deck[toIndexPath.item];
    
    switch (toPlayingCard.suit) {
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
}

@end
