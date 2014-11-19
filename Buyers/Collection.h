//
//  Collection.h
//  Buyers
//
//  Created by Web Development on 19/11/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProductOrder;

@interface Collection : NSManagedObject

@property (nonatomic, retain) NSNumber * collectionBrandRef;
@property (nonatomic, retain) NSDate * collectionCreationDate;
@property (nonatomic, retain) NSString * collectionCreator;
@property (nonatomic, retain) NSNumber * collectionDeleted;
@property (nonatomic, retain) NSString * collectionGUID;
@property (nonatomic, retain) NSDate * collectionLastUpdateDate;
@property (nonatomic, retain) NSString * collectionLastUpdatedBy;
@property (nonatomic, retain) NSString * collectionName;
@property (nonatomic, retain) NSString * collectionNotes;
@property (nonatomic, retain) NSSet *products;
@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addProductsObject:(ProductOrder *)value;
- (void)removeProductsObject:(ProductOrder *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
