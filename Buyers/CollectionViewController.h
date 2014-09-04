
#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "Collection.h"

@interface CollectionViewController : UICollectionViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *products;
@property (weak, nonatomic) Collection *collection;

@end
