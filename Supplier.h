//
//  Supplier.h
//  Buyers
//
//  Created by Web Development on 22/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Supplier : NSManagedObject

@property (nonatomic, retain) NSString * supplierCode;
@property (nonatomic, retain) NSString * supplierName;

@end
