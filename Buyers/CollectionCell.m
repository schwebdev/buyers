//
//  CollectionCell.m
//  Buyers
//
//  Created by Web Development on 31/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "CollectionCell.h"
#import "Collection.h"
#import "ProductOrder.h"
#import "Product.h"

@implementation CollectionCell

@synthesize collection = _collection;

- (void)setCollection:(Collection *)collection {
    _collection = collection;
    self.collectionNameLabel.text = [NSString stringWithFormat: @" %@", _collection.collectionName];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    NSDate *creationDate = _collection.collectionCreationDate;
    NSString *formatDate = [dateFormat stringFromDate:creationDate];
    self.collectionDetailsLabel.text = [NSString stringWithFormat: @" %@ - %@", formatDate, _collection.collectionCreator];
    
    NSString *productText = @"products";
    if([_collection.products count] ==1) {
        productText = @"product";
    }
    self.collectionNumProductsLabel.text = [NSString stringWithFormat: @" %d %@", [_collection.products count], productText];
    
    NSArray *products;
    
    NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"productOrder" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numericSort,nil];
    products = [_collection.collectionProductOrder sortedArrayUsingDescriptors:sortDescriptors];
    
    for(UIImageView *IV in [self.productsView subviews]){
        [IV removeFromSuperview];
    }
    
    //if there are products get first 12 product images
    if ([products count] > 0) {
        
        self.productsView.userInteractionEnabled = false; //switch off so the view area is clickable
        
        int pCol =1;
        int pRow = 1;
        
        for (int p = 0, pc = [products count]; p < pc; p++) {
            
            if(p==12) {
                break;
            }
            ProductOrder *productOrder = [products objectAtIndex:p];
            Product *productElement = productOrder.orderProduct;
            
            int px = (pCol -1) * 68.0 +4.0;
            int py = (pRow - 1) * 68.0;
            if(pRow >1) {
                py=py+1;
            }
            UIImage *image = [UIImage imageWithData:(productElement.productImageData)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(px+((pCol -1) * 12.0), py, 68.0, 68.0);
            [self.productsView addSubview:imageView];
            pCol++;
            
            if(pCol > 4) {
                pRow++;
                pCol= 1;
            }
        }
    }

    
    [self.collectionDeleteButton setSelected:NO];
    
    
}


@end
