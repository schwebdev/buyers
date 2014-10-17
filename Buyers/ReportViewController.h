//
//  ReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 18/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>

@interface ReportViewController : BaseViewController <UIWebViewDelegate, UIPopoverControllerDelegate, UITextViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *reportType;
@property (strong, nonatomic) NSString *reportTypeName;

- (void)generateReport:(NSString *)reportFilter;
- (void)loadReport:(NSString *)fileName;
@end
