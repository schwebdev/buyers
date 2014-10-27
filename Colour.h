//
//  Colour.h
//  Buyers
//
//  Created by Web Development on 22/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Colour : NSManagedObject

@property (nonatomic, retain) NSString * colourName;
@property (nonatomic, retain) NSNumber * colourRef;

@end
