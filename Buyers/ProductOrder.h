//
//  ProductOrder.h
//  Buyers
//
//  Created by Schuh Webdev on 02/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, Product;

@interface ProductOrder : NSManagedObject

@property (nonatomic, retain) NSNumber * productOrder;
@property (nonatomic, retain) Collection *orderCollection;
@property (nonatomic, retain) Product *orderProduct;

@end
