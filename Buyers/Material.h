//
//  Material.h
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Material : NSManagedObject

@property (nonatomic, retain) NSString * materialName;
@property (nonatomic, retain) NSSet *productMaterial;
@end

@interface Material (CoreDataGeneratedAccessors)

- (void)addProductMaterialObject:(Product *)value;
- (void)removeProductMaterialObject:(Product *)value;
- (void)addProductMaterial:(NSSet *)values;
- (void)removeProductMaterial:(NSSet *)values;

@end
