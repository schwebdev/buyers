//
//  DeletedProducts.h
//  Buyers
//
//  Created by Schuh Webdev on 10/11/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeletedProducts : NSManagedObject

@property (nonatomic, retain) NSString * productGUID;

@end
