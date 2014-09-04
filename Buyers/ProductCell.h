//
//  ProductCell.h
//  Buyers
//
//  Created by Web Development on 29/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@interface ProductCell : UICollectionViewCell

@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) IBOutlet UIImageView *productImageView;
@end
