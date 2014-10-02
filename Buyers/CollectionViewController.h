
#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "Collection.h"
#import "CollectionNotesViewController.h"

@interface CollectionViewController : UICollectionViewController <LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout, CollectionNotesViewControllerDelegate> {
    UIPopoverController *_displayNotesPopover;
    CollectionNotesViewController *_collectionNotes;
}

@property (nonatomic, retain) CollectionNotesViewController *collectionNotes;
@property (nonatomic, retain) UIPopoverController *displayNotesPopover;

@property(nonatomic,retain) UIButton *notesButton;
@property (strong, nonatomic) NSMutableArray *products;
@property (weak, nonatomic) Collection *collection;
@property(nonatomic,retain) IBOutlet UIButton *addProductButton;

-(IBAction)saveCollectionNotes:(id)sender;
- (void)deleteProducts:(id)sender;
@end
