//
//  SyncStatus.h
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SyncStatus : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * lastSync;

@end
