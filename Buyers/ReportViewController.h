//
//  ReportViewController.h
//  Buyers
//
//  Created by webdevelopment on 18/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"

@interface ReportViewController : BaseViewController <UIWebViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *reportType;

- (void)preLoadView;

@end
