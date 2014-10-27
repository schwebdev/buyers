//
//  Product.h
//  Buyers
//
//  Created by Web Development on 27/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, ProductOrder;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSData * productImageData;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productNotes;
@property (nonatomic, retain) NSNumber * productPrice;
@property (nonatomic, retain) NSNumber * productBrandRef;
@property (nonatomic, retain) NSString * productSupplierCode;
@property (nonatomic, retain) NSNumber * productCategoryRef;
@property (nonatomic, retain) NSNumber * productColourRef;
@property (nonatomic, retain) NSNumber * productMaterialRef;
@property (nonatomic, retain) NSSet *collections;
@property (nonatomic, retain) NSSet *productOrder;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addCollectionsObject:(Collection *)value;
- (void)removeCollectionsObject:(Collection *)value;
- (void)addCollections:(NSSet *)values;
- (void)removeCollections:(NSSet *)values;

- (void)addProductOrderObject:(ProductOrder *)value;
- (void)removeProductOrderObject:(ProductOrder *)value;
- (void)addProductOrder:(NSSet *)values;
- (void)removeProductOrder:(NSSet *)values;

@end
