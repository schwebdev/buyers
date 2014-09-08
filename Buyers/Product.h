//
//  Product.h
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Brand, Collection, Colour, Image, Material, ProductCategory, ProductOrder, Supplier;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSData * productImageData;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productNotes;
@property (nonatomic, retain) NSNumber * productPrice;
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) ProductCategory *category;
@property (nonatomic, retain) NSSet *collections;
@property (nonatomic, retain) Colour *colour;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Material *material;
@property (nonatomic, retain) ProductOrder *productOrder;
@property (nonatomic, retain) Supplier *supplier;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addCollectionsObject:(Collection *)value;
- (void)removeCollectionsObject:(Collection *)value;
- (void)addCollections:(NSSet *)values;
- (void)removeCollections:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
