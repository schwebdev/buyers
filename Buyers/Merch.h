//
//  Merch.h
//  Buyers
//
//  Created by webdevelopment on 02/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Merch : NSManagedObject

@property (nonatomic, retain) NSNumber * merchRef;
@property (nonatomic, retain) NSString * merchName;

@end
