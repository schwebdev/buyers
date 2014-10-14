//
//  Report.h
//  Buyers
//
//  Created by webdevelopment on 26/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Report : NSObject


+ (NSString *)generateReport:(NSString *)reportType withFilters:(NSString *)filters;
+ (NSString *)exportReportAsPDF:(UIWebView *)webView withName:(NSString *)fileName;

@end
