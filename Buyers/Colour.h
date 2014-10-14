//
//  Colour.h
//  Buyers
//
//  Created by Schuh Webdev on 10/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Colour : NSManagedObject

@property (nonatomic, retain) NSString * colourName;
@property (nonatomic, retain) NSNumber * colourRef;
@property (nonatomic, retain) NSSet *productColour;
@end

@interface Colour (CoreDataGeneratedAccessors)

- (void)addProductColourObject:(Product *)value;
- (void)removeProductColourObject:(Product *)value;
- (void)addProductColour:(NSSet *)values;
- (void)removeProductColour:(NSSet *)values;

@end
