//
//  Report.m
//  Buyers
//
//  Created by webdevelopment on 26/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "Report.h"

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




+ (NSString *)generateReport:(NSString *)reportType {
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:reportType ofType:@"html"];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
    
    NSString *dateTime = [dateFormatter stringFromDate:[NSDate date]];
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##TITLE##" withString:dateTime];
    
    NSString *htmlRows = @"";
    
    for (int i=0; i < 50; i++) {
        htmlRows = [htmlRows stringByAppendingString:@"<tr>"];
        htmlRows = [htmlRows stringByAppendingString:[NSString stringWithFormat:@"<td>BRAND%d</td>", i]];
        htmlRows = [htmlRows stringByAppendingString:@"<td>4976</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>47.26</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td></td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>26431</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>677068</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>&pound;25.62</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>23</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td></td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>444</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>-25987</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>-98%</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td></td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>11584</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>-665484</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>-98%</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>&pound;26.09</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td></td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>0</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"<td>-23</td>"];
        htmlRows = [htmlRows stringByAppendingString:@"</tr>"];
        
    }
    
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"##ROWS##" withString:htmlRows];
    
    return htmlString;
}

+ (void)exportReportAsPDF:(UIWebView *)webView withName:(NSString *)fileName {
    
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
    
    NSString *reportsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/PDFreports"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:reportsPath]) [[NSFileManager defaultManager] createDirectoryAtPath:reportsPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *filePath = [reportsPath stringByAppendingPathComponent:fileName];
   // NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [pdfData writeToFile:filePath  atomically: YES];
}


@end
