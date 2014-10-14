//
//  ProductCategory.h
//  Buyers
//
//  Created by Schuh Webdev on 10/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface ProductCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * category2Ref;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSSet *productCategory;
@end

@interface ProductCategory (CoreDataGeneratedAccessors)

- (void)addProductCategoryObject:(Product *)value;
- (void)removeProductCategoryObject:(Product *)value;
- (void)addProductCategory:(NSSet *)values;
- (void)removeProductCategory:(NSSet *)values;

@end
