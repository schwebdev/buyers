//
//  ReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 18/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"
#import "SchPDFView.h"
@interface ReportViewController : BaseViewController <UIWebViewDelegate, UIPopoverControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *reportType;

- (void)generateReport;
- (void)loadReport:(NSString *)fileName;
@end
