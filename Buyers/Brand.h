//
//  Brand.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSSet *productBrand;
@end

@interface Brand (CoreDataGeneratedAccessors)

- (void)addProductBrandObject:(Product *)value;
- (void)removeProductBrandObject:(Product *)value;
- (void)addProductBrand:(NSSet *)values;
- (void)removeProductBrand:(NSSet *)values;

@end
