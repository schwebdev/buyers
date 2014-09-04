//
//  Product.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Brand, Collection, Colour, Image, Material, Supplier;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * productCode;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSNumber * productPrice;
@property (nonatomic, retain) NSString * productNotes;
@property (nonatomic, retain) NSString * productBrand;
@property (nonatomic, retain) NSString * productCategory;
@property (nonatomic, retain) NSString * productSupplier;
@property (nonatomic, retain) NSString * productColour;
@property (nonatomic, retain) NSString * productMaterial;
@property (nonatomic, retain) NSData * productImageData;
@property (nonatomic, retain) NSSet *collections;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) Supplier *supplier;
@property (nonatomic, retain) Material *material;
@property (nonatomic, retain) Colour *colour;
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
