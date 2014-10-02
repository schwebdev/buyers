//
//  Department.h
//  Buyers
//
//  Created by webdevelopment on 02/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Department : NSManagedObject

@property (nonatomic, retain) NSNumber * depCode;
@property (nonatomic, retain) NSString * depDesc;

@end
