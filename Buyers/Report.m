//
//  Report.m
//  Buyers
//
//  Created by webdevelopment on 26/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "Report.h"
#import "Sync.h"
#import "Reachability.h"
#import "AppDelegate.h"

@implementation Report



//- (NSData*) printToPDFWithRenderer:(UIPrintPageRenderer*)renderer  paperRect:(CGRect)paperRect
//{
//    NSMutableData *pdfData = [NSMutableData data];
//
//    UIGraphicsBeginPDFContextToData( pdfData, paperRect, nil );
//
//    [renderer prepareForDrawingPages: NSMakeRange(0, renderer.numberOfPages)];
//
//    CGRect bounds = UIGraphicsGetPDFContextBounds();
//
//    for ( int i = 0 ; i < 1 ; i++ )
//    {
//        UIGraphicsBeginPDFPage();
//
//        [renderer drawPageAtIndex: i inRect: bounds];
//    }
//
//    UIGraphicsEndPDFContext();
//
//    return pdfData;
//}
//
//-(void)savePDFFromWebView:(UIWebView*)webView fileName:(NSString*)_fileName
//{
//    int height, width, header, sidespace;
//    height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] intValue] * 0.8; //1351;// * 0.805;
//    width = [[webView stringByEvaluatingJavaScriptFromString:@"document.width"] intValue] * 0.8; //2068;// * 0.805;
//    header = 0;
//    sidespace = 0;
//    NSLog(@"pdf size: %d x %d", width, height);
//
//    // set header and footer spaces
//    //[self.webView setFrame:CGRectMake(0, 0, width, height)];
//
//    UIEdgeInsets pageMargins = UIEdgeInsetsMake(header, sidespace, header, sidespace);
//
//    webView.viewPrintFormatter.contentInsets = pageMargins;
//
//
//    UIPrintPageRenderer *renderer = [[UIPrintPageRenderer alloc] init];
//
//    [renderer addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
//
//    CGRect rect = CGRectMake(0, 0, width, height);
//
//    [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"paperRect"];
//    [renderer setValue:[NSValue valueWithCGRect:rect] forKey:@"printableRect"];
//
//
//    NSData *pdfData = [self printToPDFWithRenderer:renderer paperRect:rect];
//
//    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/reports"];
//
//    if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
//
//    NSString *savePath = [reportsPath stringByAppendingPathComponent:_fileName];
//    [pdfData writeToFile: savePath  atomically: YES];
//
//    NSLog(@"file path: %@", savePath);
//
//    [self.popover dismissPopoverAnimated:YES];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:[NSString stringWithFormat:@"report has been saved as %@", _fileName] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
//}

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




+ (NSString *)generateReport:(NSString *)reportType withFilters:(NSString *)filters {
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:reportType ofType:@"html"];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
    
    NSString *dateTime = [dateFormatter stringFromDate:[NSDate date]];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##TITLE##" withString:dateTime];
    
    if([htmlString containsString:@"##JS##"]) {
        NSString *jsFile = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
        NSString *jsString = [NSString stringWithContentsOfFile:jsFile encoding:NSUTF8StringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##JS##" withString:jsString];
    }
    
    NSMutableString *htmlRows = [NSMutableString new];
    
    
    Reachability *network = [(AppDelegate *)[[UIApplication sharedApplication] delegate] reachability];
    
    if ([network currentReachabilityStatus] == ReachableViaWiFi) {
        
        
        if([reportType isEqualToString:@"OrderVsIntake"]) {
            //NSArray *results = [Sync getTable:@"ReportOrderVsIntake" sortWith:@"supplierref"];
            
            filters = [filters stringByReplacingOccurrencesOfString:@";" withString:@"/"];
            
            NSError *error;
            NSURL *url = [[NSURL alloc] initWithString:[@"http://aws.schuhshark.com:3000/buyingservice.svc/OnOrderVIntakeByWeek/" stringByAppendingString:filters]];
            
            NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
            
            if(!data) {
                NSLog(@"download error:%@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"there was problem accessing the report service" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return @"";
            }
            
            NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if(results == nil ) {
                NSLog(@"json error: %@", error);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"there was problem generating the report" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return @"";
            }
            
            if(results.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"there is no report data for the specified filter" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return @"";
            }
            
            for (NSDictionary *row in results) {
                
                if([row[@"Supplier_Ref"] isEqualToString:@"zzzzzTotal"]) {
                    [htmlRows appendFormat:@"<tr><td colspan=20></td></tr><tr>"];
                }
                [htmlRows appendFormat:@"<tr class=\"row\">"];
                [htmlRows appendFormat:@"<td>%@</td>", [row[@"Supplier_Ref"] stringByReplacingOccurrencesOfString:@"zzzzzTotal" withString:@"Total"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"LY_Units_Sold"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"LY_Margin_Acheived"]];
                [htmlRows appendFormat:@"<td></td>"];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"LY_Units_Intake"]];
                [htmlRows appendFormat:@"<td>£%.2f</td>", [row[@"LY_Cost_Intake"] floatValue]];
                [htmlRows appendFormat:@"<td>£%.2f</td>", [row[@"LY_Ave_Cost_intake"] floatValue]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"LY_New_SKUs"]];
                [htmlRows appendFormat:@"<td></td>"];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"TY_On_Order_Units"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"Diff_On_Ord_V_LY_Intake"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"LY_Perc_Diff"]];
                [htmlRows appendFormat:@"<td></td>"];
                [htmlRows appendFormat:@"<td>£%.2f</td>", [row[@"TY_On_Order_Cost"] floatValue]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"Diff_On_Ord_V_TY_Intake"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"TY_Perc_Diff"]];
                [htmlRows appendFormat:@"<td>£%.2f</td>", [row[@"TY_Ave_Cost_On_Order"] floatValue]];
                [htmlRows appendFormat:@"<td></td>"];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"TY_New_SKUs"]];
                [htmlRows appendFormat:@"<td>%@</td>", row[@"SKUs_Diff"]];
                [htmlRows appendFormat:@"</tr>"];
            }
//            CGFloat tot1 = 0, tot2 = 0, tot3 = 0, tot4 = 0, tot5 = 0, tot6 = 0, tot7 = 0, tot8 = 0, tot9 = 0, tot10 = 0, tot11 = 0, tot12 = 0 ,tot13 = 0, tot14 = 0, tot15 = 0;
//            
//            for (NSDictionary *row in results) {
//                [htmlRows appendFormat:@"<tr>"];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"SupplierRef"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"LYUnitsSold"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"LYMarginAchieved"]];
//                [htmlRows appendFormat:@"<td></td>"];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"LYUnitsIntake"]];
//                [htmlRows appendFormat:@"<td>£%@</td>", row[@"LYCostIntake"]];
//                [htmlRows appendFormat:@"<td>£%@</td>", row[@"LYAveCostIntake"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"LYNewSKUs"]];
//                [htmlRows appendFormat:@"<td></td>"];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"TYOnOrderUnits"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"DiffOnOrdVLYIntake"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"LYDiff"]];
//                [htmlRows appendFormat:@"<td></td>"];
//                [htmlRows appendFormat:@"<td>£%@</td>", row[@"TYOnOrderCost"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"DiffOnOrdVTYIntake"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"TYDiff"]];
//                [htmlRows appendFormat:@"<td>£%@</td>", row[@"TYAveCostOnOrder"]];
//                [htmlRows appendFormat:@"<td></td>"];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"TYNewSKUs"]];
//                [htmlRows appendFormat:@"<td>%@</td>", row[@"SkusDiff"]];
//                [htmlRows appendFormat:@"</tr>"];
//                
//                tot1 += [row[@"LYUnitsSold"] floatValue];
//                tot2 += [row[@"LYMarginAchieved"] floatValue];
//                tot3 += [row[@"LYUnitsIntake"] floatValue];
//                tot4 += [row[@"LYCostIntake"] floatValue];
//                tot5 += [row[@"LYAveCostIntake"] floatValue];
//                tot6 += [row[@"LYNewSKUs"] floatValue];
//                tot7 += [row[@"TYOnOrderUnits"] floatValue];
//                tot8 += [row[@"DiffOnOrdVLYIntake"] floatValue];
//                tot9 += [row[@"LYDiff"] floatValue];
//                tot10 += [row[@"TYOnOrderCost"] floatValue];
//                tot11 += [row[@"DiffOnOrdVTYIntake"] floatValue];
//                tot12 += [row[@"TYDiff"] floatValue];
//                tot13 += [row[@"TYAveCostOnOrder"] floatValue];
//                tot14 += [row[@"TYNewSKUs"] floatValue];
//                tot15 += [row[@"SkusDiff"] floatValue];
//            }
//            
//            [htmlRows appendFormat:@"<tr><td colspan=20></td></tr><tr>"];
//            [htmlRows appendFormat:@"<td>Totals</td>"];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot1];
//            [htmlRows appendFormat:@"<td>%.2f</td>", tot2];
//            [htmlRows appendFormat:@"<td></td>"];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot3];
//            [htmlRows appendFormat:@"<td>£%.2f</td>", tot4];
//            [htmlRows appendFormat:@"<td>£%.2f</td>", tot5/results.count];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot6];
//            [htmlRows appendFormat:@"<td></td>"];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot7];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot8];
//            [htmlRows appendFormat:@"<td>%.2f</td>", tot9];
//            [htmlRows appendFormat:@"<td></td>"];
//            [htmlRows appendFormat:@"<td>£%.2f</td>", tot10];
//            [htmlRows appendFormat:@"<td>%.2f</td>", tot11];
//            [htmlRows appendFormat:@"<td>%.2f</td>", tot12];
//            [htmlRows appendFormat:@"<td>£%.2f</td>", tot13/results.count];
//            [htmlRows appendFormat:@"<td></td>"];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot14];
//            [htmlRows appendFormat:@"<td>%d</td>", (int)tot15];
//            [htmlRows appendFormat:@"</tr>"];
            htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##ROWS##" withString:htmlRows];
            
        }
        return htmlString;
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"no wifi connection was found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];        
        
        return @"";
    }
    
}

+ (NSString *)exportReportAsPDF:(UIWebView *)webView withName:(NSString *)fileName {
    
    int height, width, header, sidespace;
    height = [[webView stringByEvaluatingJavaScriptFromString:@"document.height"] intValue] * 0.8; //1351;// * 0.805;
    width = [[webView stringByEvaluatingJavaScriptFromString:@"document.width"] intValue] * 0.8; //2068;// * 0.805;
    header = 0;
    sidespace = 0;
    NSLog(@"report size: %d x %d", width, height);
    
    //generate temp pdf
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
    
    NSString *reportsPath = NSTemporaryDirectory();
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *filePath = [reportsPath stringByAppendingPathComponent:fileName];
   // NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [pdfData writeToFile:filePath  atomically: YES];
    
    return filePath;
}


@end
