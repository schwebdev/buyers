//
//  Sync.h
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sync : NSObject

+ (BOOL)syncTable:(NSString *)type;

+ (BOOL)syncProductData;
+ (BOOL)syncReportData;
+ (BOOL)syncFilterReports;



+ (void)updateSyncStatus:(NSString *)type;
+ (NSDate *)getLastSyncDate;
+ (NSDate *)getLastSyncForTable:(NSString *)table;
+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column;
+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column withPredicate:(NSPredicate *)predicate;
@end
