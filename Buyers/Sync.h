//
//  Sync.h
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sync : NSObject

+ (BOOL)syncAll;

+ (NSDate *)getLastSyncDate;

+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column;
@end
