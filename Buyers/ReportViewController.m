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
@interface ReportViewController ()

@property UIPopoverController *popover;
@end

@implementation ReportViewController

- (NSData*) printToPDFWithRenderer:(UIPrintPageRenderer*)renderer  paperRect:(CGRect)paperRect
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, paperRect, nil );
    
    [renderer prepareForDrawingPages: NSMakeRange(0, renderer.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < 1 ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [renderer drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

-(void)savePDFFromWebView:(UIWebView*)webView fileName:(NSString*)_fileName
{
    int height, width, header, sidespace;
    height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] intValue] * 0.8; //1351;// * 0.805;
    width = [[webView stringByEvaluatingJavaScriptFromString:@"document.width"] intValue] * 0.8; //2068;// * 0.805;
    header = 0;
    sidespace = 0;
    NSLog(@"pdf size: %d x %d", width, height);

    // set header and footer spaces
    //[self.webView setFrame:CGRectMake(0, 0, width, height)];
    
    UIEdgeInsets pageMargins = UIEdgeInsetsMake(header, sidespace, header, sidespace);
    
    webView.viewPrintFormatter.contentInsets = pageMargins;
    
    
    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
    
    [renderer addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"paperRect"];
    [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"printableRect"];
    
    
    NSData *pdfData = [self printToPDFWithRenderer:renderer paperRect:rect];
    
    
    NSString *savePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:_fileName];
    [pdfData writeToFile: savePath  atomically: YES];
    
    NSLog(@"file path: %@", savePath);
}

//
//- (void)createPDFFromUIVIew:(UIView*)view saveToDocumentWithFileName:(NSString*)fileName {
//    NSMutableData *pdfData = [NSMutableData data];
//    
//    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
//    UIGraphicsBeginPDFPage();
//    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
//    
//    [view.layer renderInContext:pdfContext];
//    
//    UIGraphicsEndPDFContext();
//    
//    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
//    NSString *documentDirectoryFileName = [documentDirectory stringByAppendingPathComponent:fileName];
//    
//    [pdfData writeToFile:documentDirectoryFileName atomically:YES];
//    
//    NSLog(@"file path: %@", documentDirectoryFileName);
//}

- (IBAction)saveReport:(id)sender {
    //[self createPDFFromUIVIew:self.webView saveToDocumentWithFileName:@"test.pdf"];
    //[self savePDFFromWebView:self.webView fileName:@"test2.pdf"];
    
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] init];
    
    SchTextField *saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    [popoverView addSubview:saveText];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:CGSizeMake(270, 70) animated:NO];
    
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

- (void)preLoadView {
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"OrderVsIntake" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [BaseViewController genNavWithTitle:@"run and view" title2:@"reports" image:@"homeReportsLogo.png"];
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@",self.reportType ]]];

    
    //[self.webView.scrollView setBounces:NO];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"OrderVsIntake" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveReport:)];
    self.navigationItem.rightBarButtonItem = button;
    
//    SchTextField *saveText = [[SchTextField alloc]initWithFrame:CGRectMake(400, 20, 200, 50)];
//    
//    [self.navigationController.navigationBar addSubview:saveText];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self.webView.scrollView setZoomScale:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
