//
//  Collection.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * collectionName;
@property (nonatomic, retain) NSString * collectionCreator;
@property (nonatomic, retain) NSDate * collectionCreationDate;
@property (nonatomic, retain) NSString * collectionNotes;
@property (nonatomic, retain) NSSet *products;
@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addProductsObject:(Product *)value;
- (void)removeProductsObject:(Product *)value;
- (void)addProducts:(NSSet *)values;
- (void)removeProducts:(NSSet *)values;

@end
