//
//  Collection.h
//  Buyers
//
//  Created by Web Development on 06/11/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product, ProductOrder;

@interface Collection : NSManagedObject

@property (nonatomic, retain) NSNumber * collectionBrandRef;
@property (nonatomic, retain) NSDate * collectionCreationDate;
@property (nonatomic, retain) NSString * collectionCreator;
@property (nonatomic, retain) NSString * collectionName;
@property (nonatomic, retain) NSString * collectionNotes;
@property (nonatomic, retain) NSString * collectionGUID;
@property (nonatomic, retain) NSString * collectionLastUpdatedBy;
@property (nonatomic, retain) NSDate * collectionLastUpdateDate;
@property (nonatomic, retain) NSSet *collectionProductOrder;
@property (nonatomic, retain) NSSet *products;
@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addCollectionProductOrderObject:(ProductOrder *)value;
- (void)removeCollectionProductOrderObject:(ProductOrder *)value;
- (void)addCollectionProductOrder:(NSSet *)values;
- (void)removeCollectionProductOrder:(NSSet *)values;

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
