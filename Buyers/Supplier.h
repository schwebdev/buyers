//
//  Supplier.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Supplier : NSManagedObject

@property (nonatomic, retain) NSString * supplierName;
@property (nonatomic, retain) NSSet *productSupplier;
@end

@interface Supplier (CoreDataGeneratedAccessors)

- (void)addProductSupplierObject:(Product *)value;
- (void)removeProductSupplierObject:(Product *)value;
- (void)addProductSupplier:(NSSet *)values;
- (void)removeProductSupplier:(NSSet *)values;

@end
