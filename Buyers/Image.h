//
//  Image.h
//  Buyers
//
//  Created by Web Development on 21/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) Product *product;

@end
