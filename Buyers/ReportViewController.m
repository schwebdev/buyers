//
//  ReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 18/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ReportViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SchTextField.h"

#import "Report.h"

@interface ReportViewController ()

@property SchTextField *saveText;
@property UITextView *notesTextView;
@property UIPopoverController *popover;
@property NSString *filePath;

@property UIButton *menuSavePDF;
@property UIButton *menuAddNotes;
@end

@implementation ReportViewController

- (void)exportReport {
    NSString *fileName = [self.saveText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(fileName.length > 0) {
        fileName = [fileName stringByAppendingString:@".pdf"];
       
        [Report exportReportAsPDF:self.webView withName:fileName];
        
        
        [self.popover dismissPopoverAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveReport {
    NSString *fileName = [self.saveText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(fileName.length > 0) {
        fileName = [fileName stringByAppendingString:@".html"];
        
        NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSString *savePath = [reportsPath stringByAppendingPathComponent:fileName];
        
        NSString *htmlString = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        
        [htmlString writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"%@",htmlString);
        
        
        [self.popover dismissPopoverAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)addNotesClick:(id)sender {
    
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 720, 680)];
    
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 50)];
    lblHeader.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0f];
    lblHeader.textColor = [UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f];
    [lblHeader setText:@"report notes"];
    [popoverView addSubview:lblHeader];
    
    self.notesTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, 680, 500)];
    self.notesTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.notesTextView.textColor = [UIColor darkGrayColor];
    [self.notesTextView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.notesTextView.layer setBorderWidth:2];
    
    self.notesTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    self.notesTextView.delegate = self;
    [popoverView addSubview:self.notesTextView];
    
    
    UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveConfirm setTitle:@"save notes" forState:UIControlStateNormal];
    [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    
    //[saveConfirm setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
    
    [saveConfirm setFrame:CGRectMake(550, 615, 150, 50)];
    //[saveConfirm addTarget:self action:@selector(saveReport) forControlEvents:UIControlEventTouchUpInside];
    saveConfirm.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:popoverContent.view.frame.size animated:NO];
    
    [self.popover presentPopoverFromRect:self.menuAddNotes.frame inView:self.menuAddNotes.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)exportPDFClick:(id)sender {
    UIViewController *popoverContent = [[UIViewController alloc] init];
    UIView *popoverView = [[UIView alloc] init];
    
    self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    [popoverView addSubview:self.saveText];
    
    UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveConfirm setTitle:@"confirm" forState:UIControlStateNormal];
    [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    
    //[saveConfirm setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
    
    [saveConfirm setFrame:CGRectMake(60, 70, 150, 50)];
    [saveConfirm addTarget:self action:@selector(exportReport) forControlEvents:UIControlEventTouchUpInside];
    
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:CGSizeMake(270, 130) animated:NO];
    
    [self.popover presentPopoverFromRect:self.menuSavePDF.frame inView:self.menuSavePDF.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}

- (IBAction)saveClick:(id)sender {
    //[self createPDFFromUIVIew:self.webView saveToDocumentWithFileName:@"test.pdf"];
    //[self savePDFFromWebView:self.webView fileName:@"test2.pdf"];
    
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] init];
    
    self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    [popoverView addSubview:self.saveText];
    
    
    UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];    
    [saveConfirm setTitle:@"confirm" forState:UIControlStateNormal];
    [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    
    //[saveConfirm setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
    
    [saveConfirm setFrame:CGRectMake(60, 70, 150, 50)];
    [saveConfirm addTarget:self action:@selector(saveReport) forControlEvents:UIControlEventTouchUpInside];
    
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:CGSizeMake(270, 130) animated:NO];
    
    [self.popover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

     
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];

    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
    //UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"save pdf" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
    self.navigationItem.rightBarButtonItem = button;
    //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:button,button2,nil];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.menuSavePDF = [self setMenuButton:1 title:@"export as PDF"];
    [self.menuSavePDF addTarget:self action:@selector(exportPDFClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.menuAddNotes = [self setMenuButton:2 title:@"add notes"];
    [self.menuAddNotes addTarget:self action:@selector(addNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateReport {
    
    NSString *htmlString = [Report generateReport:self.reportType];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@",self.reportType ]]];
    self.webView.hidden = YES;
}

- (void)loadReport:(NSString *)fileName {
    
    self.filePath = fileName;
    
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@",fileName ]]];
    
    NSLog(@"load report: %@", fileName);
    
    
    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"] ;
    
    NSString *reportPath = [reportsPath stringByAppendingPathComponent:fileName];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:reportPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    self.webView.hidden = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    [self.webView.scrollView zoomToRect:CGRectMake(0, 0, 400, 400) animated:YES];
}


@end
