
#import "CollectionListViewController.h"
#import "SWRevealViewController.h"

@interface CollectionListViewController ()

@end

@implementation CollectionListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"your" title2:@"collections" image:@"homePaperClipLogo.png"];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
