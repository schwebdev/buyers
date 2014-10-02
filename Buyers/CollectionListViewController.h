

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewCollectionViewController.h"
#import "LXReorderableCollectionViewFlowLayout.h"


@interface CollectionListViewController : BaseViewController <NewCollectionViewControllerDelegate, UIScrollViewDelegate> {
    UIPopoverController *_addCollectionPopover;
    NewCollectionViewController *_addCollection;
}

@property (nonatomic, retain) NewCollectionViewController *addCollection;
@property (nonatomic, retain) UIPopoverController *addCollectionPopover;
@property(nonatomic,retain) IBOutlet UIButton *addCollectionButton;
@property(nonatomic,retain) IBOutlet UIButton *menu1;
@property(nonatomic,retain) IBOutlet UIButton *menu2;
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIImageView *upArrow;
@property(nonatomic,retain) UIImageView *downArrow;


//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)goToNewCollection:(NSNotification *)notification;
-(IBAction)saveNewCollection:(id)sender;
-(void)deleteCollections:(id)sender;
@end
