//
//  Product.h
//  Buyers
//
//  Created by Web Development on 19/11/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProductOrder;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSNumber * productBrandRef;
@property (nonatomic, retain) NSNumber * productCategoryRef;
@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSNumber * productColourRef;
@property (nonatomic, retain) NSDate * productCreationDate;
@property (nonatomic, retain) NSString * productCreator;
@property (nonatomic, retain) NSNumber * productDeleted;
@property (nonatomic, retain) NSString * productGUID;
@property (nonatomic, retain) NSData * productImageData;
@property (nonatomic, retain) NSDate * productLastUpdateDate;
@property (nonatomic, retain) NSString * productLastUpdatedBy;
@property (nonatomic, retain) NSNumber * productMaterialRef;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productNotes;
@property (nonatomic, retain) NSNumber * productPrice;
@property (nonatomic, retain) NSString * productSupplierCode;
@property (nonatomic, retain) NSNumber * productCostPrice;
@property (nonatomic, retain) NSSet *productOrder;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addProductOrderObject:(ProductOrder *)value;
- (void)removeProductOrderObject:(ProductOrder *)value;
- (void)addProductOrder:(NSSet *)values;
- (void)removeProductOrder:(NSSet *)values;

@end
