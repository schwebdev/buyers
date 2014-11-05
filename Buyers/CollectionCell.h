//
//  CollectionCell.h
//  Buyers
//
//  Created by Web Development on 31/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Collection;

@interface CollectionCell : UICollectionViewCell

@property (strong, nonatomic) Collection *collection;
@property (weak, nonatomic) IBOutlet UILabel *collectionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionNumProductsLabel;
@property (strong, nonatomic) IBOutlet UIView *productsView;
@property (strong, nonatomic) IBOutlet UIButton *collectionDeleteButton;
@end
