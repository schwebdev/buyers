//
//  Brand.h
//  Buyers
//
//  Created by Web Development on 22/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSNumber * brandRef;

@end
