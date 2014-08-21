//
//  SchPDFView.m
//  Buyers
//
//  Created by webdevelopment on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SchPDFView.h"

@implementation SchPDFView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGPDFPageRef page = CGPDFDocumentGetPage(self.pdf, 1);
    
    CGContextSaveGState(context);
    
    //CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, self.bounds, 0, true);
    
    //CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
}


@end
