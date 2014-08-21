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

@property SchTextField *saveText;
@property UIPopoverController *popover;
@property UIWebView *tempWebView;
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
    
    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *savePath = [reportsPath stringByAppendingPathComponent:_fileName];
    [pdfData writeToFile: savePath  atomically: YES];
    
    NSLog(@"file path: %@", savePath);
    
    [self.popover dismissPopoverAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", _fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
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

- (void)saveReport {
    NSString *fileName = [self.saveText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(fileName.length > 0) {
        fileName = [fileName stringByAppendingString:@".pdf"];
        
        //copy temp pdf
        NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSString *savePath = [reportsPath stringByAppendingPathComponent:fileName];
        
        NSLog(@"temp file path: %@", self.webView.request.URL.path);
        
        [[NSFileManager defaultManager] copyItemAtPath:self.webView.request.URL.path toPath:savePath error:nil];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
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
    
    [saveConfirm setFrame:CGRectMake(60, 70, 150, 56)];
    [saveConfirm addTarget:self action:@selector(saveReport) forControlEvents:UIControlEventTouchUpInside];
    
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:CGSizeMake(270, 136) animated:NO];
    
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
    [self.view addSubview:[BaseViewController genTopBarWithTitle:[NSString stringWithFormat:@"%@",self.reportType ]]];

    
    //[self.webView.scrollView setBounces:NO];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"OrderVsIntake" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    self.tempWebView = [[UIWebView alloc] init];
    [self.tempWebView loadHTMLString:htmlString baseURL:nil];
    self.tempWebView.delegate = self;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
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

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(webView.tag == 0) {
        int height, width, header, sidespace;
        height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] intValue] * 0.8; //1351;// * 0.805;
        width = [[webView stringByEvaluatingJavaScriptFromString:@"document.width"] intValue] * 0.8; //2068;// * 0.805;
        header = 0;
        sidespace = 0;
        NSLog(@"report size: %d x %d", width, height);
        
        
        UIEdgeInsets pageMargins = UIEdgeInsetsMake(header, sidespace, header, sidespace);
        
        webView.viewPrintFormatter.contentInsets = pageMargins;
        
        UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
        
        [renderer addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
        
        CGRect rect = CGRectMake(0, 0, width, height);
        
        [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"paperRect"];
        [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"printableRect"];
        
        
        NSMutableData *pdfData = [NSMutableData data];
        
        UIGraphicsBeginPDFContextToData( pdfData, rect, nil );
        
        [renderer prepareForDrawingPages: NSMakeRange(0, renderer.numberOfPages)];
        
        CGRect bounds = UIGraphicsGetPDFContextBounds();
        
        for ( int i = 0 ; i < 1 ; i++ )
        {
            UIGraphicsBeginPDFPage();
            
            [renderer drawPageAtIndex: i inRect: bounds];
        }
        
        UIGraphicsEndPDFContext();
        
        NSString *savePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.pdf"];
        [pdfData writeToFile: savePath  atomically: YES];
        
        NSLog(@"temp file path: %@", savePath);
        
        //[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:savePath]]];
        
        //CFURLRef pdfURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)savePath, kCFURLPOSIXPathStyle, false);
        //self.pdfView.pdf = CGPDFDocumentCreateWithURL(pdfURL);
        
        //[self.pdfView drawRect:self.pdfView.bounds];
        
        //self.pdfView.scrollEnabled = YES;
        self.scrollView.scrollEnabled = YES;
        SchPDFView *pageView = [[SchPDFView alloc] initWithFrame:rect];
        
        CFURLRef pdfURL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)savePath, kCFURLPOSIXPathStyle, false);
        pageView.pdf = CGPDFDocumentCreateWithURL(pdfURL);
        //[self.scrollView setBackgroundColor:[UIColor greenColor]];
        [self.scrollView addSubview:pageView];
        
        [self.scrollView setContentSize:pageView.frame.size];
        NSLog(@"pageView size: %f x %f", pageView.frame.size.width, pageView.frame.size.height);
        NSLog(@"pageView size: %f x %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}
@end
