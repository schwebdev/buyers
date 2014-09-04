//
//  ProductOrder.h
//  Buyers
//
//  Created by Web Development on 04/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, Product;

@interface ProductOrder : NSManagedObject

@property (nonatomic, retain) NSNumber * productOrder;
@property (nonatomic, retain) NSSet *orderCollection;
@property (nonatomic, retain) NSSet *orderProduct;
@end

@interface ProductOrder (CoreDataGeneratedAccessors)

- (void)addOrderCollectionObject:(Collection *)value;
- (void)removeOrderCollectionObject:(Collection *)value;
- (void)addOrderCollection:(NSSet *)values;
- (void)removeOrderCollection:(NSSet *)values;

- (void)addOrderProductObject:(Product *)value;
- (void)removeOrderProductObject:(Product *)value;
- (void)addOrderProduct:(NSSet *)values;
- (void)removeOrderProduct:(NSSet *)values;

@end
