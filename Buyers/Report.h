//
//  Report.h
//  Buyers
//
//  Created by webdevelopment on 26/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Report : NSObject

+ (NSArray *)getSuppliers;

+ (NSString *)generateReport:(NSString *)reportType;
+ (void)exportReportAsPDF:(UIWebView *)webView withName:(NSString *)fileName;

@end
