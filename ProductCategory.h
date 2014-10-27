//
//  ProductCategory.h
//  Buyers
//
//  Created by Web Development on 22/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ProductCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * category2Ref;
@property (nonatomic, retain) NSString * categoryName;

@end
