//
//  ProductCell.m
//  Buyers
//
//  Created by Web Development on 29/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "ProductCell.h"
#import "Product.h"

@implementation ProductCell

@synthesize product = _product;

- (void)setProduct:(Product *)product {
    _product = product;
    self.productImageView.image = [UIImage imageWithData:(_product.productImageData)];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.productImageView.alpha = highlighted ? 0.75f : 1.0f;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
