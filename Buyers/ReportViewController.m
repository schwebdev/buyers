//
//  ReportViewController.m
//  Buyers
//
//  Created by webdevelopment on 18/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ReportViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "SchTextField.h"

#import "Report.h"
#import "ReportData.h"

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
    self.filePath = fileName;
    
    if(fileName.length > 0) {
        /*
        fileName = [fileName stringByAppendingString:@".html"];
        
        NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSString *savePath = [reportsPath stringByAppendingPathComponent:fileName];
        
        NSString *htmlString = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        
        [htmlString writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSLog(@"%@",htmlString);
        */
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",fileName]];
        
        NSError *error;
        NSArray *reports = [managedContext executeFetchRequest:request error:&error];
        
        if(reports.count > 0) {
            //ReportData *report = reports[0];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"a report with this name already exists" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *htmlString = [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];

            ReportData *report = [NSEntityDescription insertNewObjectForEntityForName:@"ReportData" inManagedObjectContext:managedContext];
            report.name = fileName;
            report.content = htmlString;
            report.createdBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            report.lastModified = [NSDate date];
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not save reportdata: %@", [saveError localizedDescription]);
            } else {
                NSLog(@"%@ reportdata entry created", fileName);
            }
            
            [self.popover dismissPopoverAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
        
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"please enter a file name"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)saveNotes {

    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",self.filePath]];
    
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count > 0) {
        ReportData *report = reports[0];
        report.notes = self.notesTextView.text;
        report.lastModified = [NSDate date];
        
        NSError *saveError;
        if(![managedContext save:&saveError]) {
            NSLog(@"Could not save reportdata: %@", [saveError localizedDescription]);
        } else {
            NSLog(@"%@ reportdata entry modified", self.filePath);
        }
    }
    
    [self.popover dismissPopoverAnimated:YES];
}

- (void)deleteReport {
    if(self.filePath != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Are you sure you wish to delete this report?"] delegate:nil cancelButtonTitle:@"no" otherButtonTitles:@"yes",nil];
        [alert show];
    }
}

- (IBAction)addNotesClick:(id)sender {
    
    if(self.filePath != nil) {
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
        
        
    if(self.filePath != nil) {
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",self.filePath]];
        
        NSError *error;
        NSArray *reports = [managedContext executeFetchRequest:request error:&error];
        
        if(reports.count > 0) {
            ReportData *report = reports[0];
            
            self.notesTextView.text = report.notes;
        }
    }

    [popoverView addSubview:self.notesTextView];
    
    
    UIButton *saveConfirm = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveConfirm setTitle:@"save notes" forState:UIControlStateNormal];
    [saveConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveConfirm setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    
    //[saveConfirm setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveConfirm.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f]];
    
    [saveConfirm setFrame:CGRectMake(550, 615, 150, 50)];
    [saveConfirm addTarget:self action:@selector(saveNotes) forControlEvents:UIControlEventTouchUpInside];
    saveConfirm.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [popoverView addSubview:saveConfirm];
    
    popoverContent.view = popoverView;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.popover.delegate = self;
    [self.popover setPopoverContentSize:popoverContent.view.frame.size animated:NO];
    
    [self.popover presentPopoverFromRect:self.menuAddNotes.frame inView:self.menuAddNotes.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"report must be saved before notes can be added."] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)exportPDFClick:(id)sender {
    UIViewController *popoverContent = [[UIViewController alloc] init];
    UIView *popoverView = [[UIView alloc] init];
    
    self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    self.saveText.autocorrectionType = UITextAutocorrectionTypeNo;
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

- (IBAction)saveClick:(UIButton*)sender {
    //[self createPDFFromUIVIew:self.webView saveToDocumentWithFileName:@"test.pdf"];
    //[self savePDFFromWebView:self.webView fileName:@"test2.pdf"];
    
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    
    UIViewController *popoverContent = [[UIViewController alloc] init];
    
    UIView *popoverView = [[UIView alloc] init];
    
    self.saveText = [[SchTextField alloc] initWithFrame:CGRectMake(10, 10, 250, 50)];
    self.saveText.autocorrectionType = UITextAutocorrectionTypeNo;
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
    
    [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    //[self.popover presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
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

    
    //UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
    //UIBarButtonItem *button2 = [[UIBarButtonItem alloc] initWithTitle:@"save pdf" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick:)];
        //self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:button,button2,nil];
    UIView *barButtons = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 85)];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    //[button setBackgroundImage:[UIImage imageNamed:@"schuhMenuIcon-S.png"] forState:UIControlStateNormal];
    
    //[button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"save" forState:UIControlStateNormal];
    [saveButton setBackgroundColor:[UIColor colorWithRed:127.0f/255.0f green:175.0f/255.0f blue:22.0f/255.0f alpha:1.0f]];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[button setTitleEdgeInsets: UIEdgeInsetsMake(0, 20, 0, 0)];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f]];
    saveButton.frame = CGRectMake(0, 0, 100, 50);
    //[button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [saveButton addTarget:self action:@selector(saveClick:) forControlEvents:UIControlEventTouchUpInside];
    [barButtons addSubview:saveButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:barButtons];

    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.menuSavePDF = [self setMenuButton:1 title:@"export as PDF"];
    [self.menuSavePDF addTarget:self action:@selector(exportPDFClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.menuAddNotes = [self setMenuButton:2 title:@"add notes"];
    [self.menuAddNotes addTarget:self action:@selector(addNotesClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self setMenuButton:3 title:@"delete report"] addTarget:self action:@selector(deleteReport) forControlEvents:UIControlEventTouchUpInside];
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
    
    /*
    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"] ;
    
    NSString *reportPath = [reportsPath stringByAppendingPathComponent:fileName];
     
    NSString *htmlString = [NSString stringWithContentsOfFile:report.content encoding:NSUTF8StringEncoding error:nil];
    */
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",fileName]];
    
    NSError *error;
    NSArray *reports = [managedContext executeFetchRequest:request error:&error];
    
    if(reports.count == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[NSString stringWithFormat:@"report %@ was not found", fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    } else {
        ReportData *report = reports[0];
        
        [self.webView loadHTMLString:report.content baseURL:nil];
        self.webView.hidden = YES;
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.webView.hidden = NO;
    //[self.webView.scrollView zoomToRect:CGRectMake(0, 0, 400, 400) animated:YES];
}


@end
