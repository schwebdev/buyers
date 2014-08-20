
#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"

@interface CollectionViewController : UICollectionViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *deck;

@end
