//
//  Sync.m
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <objc/runtime.h>
#import "Reachability.h"
#import "Sync.h"
#import "AppDelegate.h"
#import "SyncStatus.h"
#import "Supplier.h"
#import "Brand.h"
#import "material.h"
#import "CalYearWeek.h"
#import "Department.h"
#import "Merch.h"
#import "ReportOrderVsIntake.h"

@implementation Sync

+ (BOOL)syncAll {
    
    //internet check
    
    Reachability *network = [Reachability reachabilityWithHostName:@"aws.schuhshark.com"];
    
    if ([network currentReachabilityStatus] == ReachableViaWiFi) {
    
        
        [self updateSyncStatus:@"global"];
        
        if(![self syncSuppliers]) return NO;
        
        if(![self syncBrands]) return NO;
        
        if(![self syncCalYearWeeks]) return NO;
        
        return YES;
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"no wifi found" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
}

+ (NSDate *)getLastSyncDate {
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SyncStatus"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(type == %@)",@"global"]];
    
    NSError *error;
    NSArray *syncStatuses = [managedContext executeFetchRequest:request error:&error];
    
    if(syncStatuses.count > 0) {
        SyncStatus *syncStatus = syncStatuses[0];
        
        return syncStatus.lastSync;
    } else {
        return nil;
    }
}

+ (void)updateSyncStatus:(NSString *)type {
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SyncStatus"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(type == %@)",type]];
    
    NSError *error;
    NSArray *syncStatuses = [managedContext executeFetchRequest:request error:&error];
    
    if(syncStatuses.count > 0) {
        SyncStatus *syncStatus = syncStatuses[0];
        
        NSLog(@"%@ sync last updated on %@", type, syncStatus.lastSync);
        
        syncStatus.lastSync = [NSDate date];
        
        NSError *saveError;
        if(![managedContext save:&saveError]) {
            NSLog(@"Could not save %@ SyncStatus: %@", type,[saveError localizedDescription]);
            NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@" detailed error:%@", [detailedError userInfo]);
                }
            } else {
                NSLog(@" detailed error:%@", [saveError userInfo]);
            }
        } else {
            NSLog(@"%@ sync entry found and updated", type);
        }
    } else {
        
        SyncStatus *syncStatus = [NSEntityDescription insertNewObjectForEntityForName:@"SyncStatus" inManagedObjectContext:managedContext];
        syncStatus.type = type;
        syncStatus.lastSync = [NSDate date];
        
        NSError *saveError;
        if(![managedContext save:&saveError]) {
            NSLog(@"Could not save %@ SyncStatus: %@", type,[saveError localizedDescription]);
        } else {
            NSLog(@"%@ sync status entry created", type);
        }
    }

}

+ (BOOL)syncSuppliers {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getsuppliers"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    //dictionary[3][@"Sup_Code"]
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        Supplier *supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:managedContext];
        
        supplier.supplierCode = result[@"Sup_Code"];
        supplier.supplierName = result[@"Sup_Name"];
        
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save suppliers: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu supplier entries created",(unsigned long)results.count);
    }
    
    [self updateSyncStatus:@"suppliers"];
    
    return YES;
}

+ (BOOL)syncBrands {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getbrands"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        if(result[@"brandRef"]) {
            
        }
        Brand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:managedContext];
        brand.brandRef = result[@"brandRef"];
        brand.brandName = result[@"brandName"];
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save brands: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu brand entries created",(unsigned long)results.count);
    }
    
    [self updateSyncStatus:@"brand"];
    
    return YES;
}

+ (BOOL)syncCalYearWeeks {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcalyearweeks"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CalYearWeek"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        CalYearWeek *yearWeek = [NSEntityDescription insertNewObjectForEntityForName:@"CalYearWeek" inManagedObjectContext:managedContext];
        yearWeek.calYearWeek = result[@"Cal_Year_Week"];
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save CalYearWeek: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu CalYearWeek entries created",(unsigned long)results.count);
    }
    
    [self updateSyncStatus:@"calyearweek"];
    
    return YES;
}


+ (BOOL)syncMerch {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getmerch"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Merch"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        Merch *merch = [NSEntityDescription insertNewObjectForEntityForName:@"Merch" inManagedObjectContext:managedContext];
        merch.merchRef = result[@"MerchRef"];
        merch.merchName = result[@"MerchName"];
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save Merch: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu Merch entries created",(unsigned long)results.count);
    }
    
    [self updateSyncStatus:@"merch"];
    
    return YES;
}


+ (BOOL)syncDepartments {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getdepartments"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Department"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        Department *department = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:managedContext];
        department.depCode = [NSNumber numberWithInt:[result[@"DepCode"] intValue]];
        department.depDesc = result[@"Desc"];
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save Department: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu Department entries created",(unsigned long)results.count);
    }
    
    [self updateSyncStatus:@"department"];
    
    return YES;
}

+ (BOOL)syncReportsOrderVsIntake {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://mie.schuh.co.uk/test.txt"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportOrderVsIntake"];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        //save the new collection
        ReportOrderVsIntake *row = [NSEntityDescription insertNewObjectForEntityForName:@"ReportOrderVsIntake" inManagedObjectContext:managedContext];
        
        for(NSString *key in result.allKeys) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportOrderVsIntake" inManagedObjectContext:managedContext];
            
            NSDictionary *attributes = [entity attributesByName];
            NSAttributeDescription *attrDesc = [attributes objectForKey:[key lowercaseString]];
            if([attrDesc attributeType] == NSInteger32AttributeType) {
                [row setValue:[NSNumber numberWithInt:[result[key] intValue]] forKey:[key lowercaseString]];
            } else if([attrDesc attributeType] == NSFloatAttributeType) {
                [row setValue:[NSNumber numberWithFloat:[result[key] floatValue]] forKey:[key lowercaseString]];
            } else {
                [row setValue:result[key] forKey:[key lowercaseString]];
            }
        }
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save ReportOrderVsIntake: %@", [saveError localizedDescription]);
        
        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
        if(detailedErrors != nil && [detailedErrors count] > 0) {
            for(NSError* detailedError in detailedErrors) {
                NSLog(@" detailed error:%@", [detailedError userInfo]);
                NSLog(@" detailed error:%ld", (long)[detailedError code]);
            }
        } else {
            NSLog(@" detailed error:%@", [saveError userInfo]);
        }
        return NO;
    } else {
        
        NSLog(@"%lu ReportOrderVsIntake entries created",(unsigned long)results.count);
    }
    
    
    [self updateSyncStatus:@"reportordervsintake"];
    return YES;
}

+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column {
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSError *error;
    NSArray *results = [managedContext executeFetchRequest:request error:&error];
    
    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"collectionID" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:column ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    results = [results sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray *resultsArray = [NSMutableArray array];
    
    for (NSObject *row in results) {
        [resultsArray addObject:[self dictionaryWithPropertiesOfObject:row]];
    }
    
    return [NSArray arrayWithArray:resultsArray];
}


+ (NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);
    
    for (int i =0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        Class classObject = NSClassFromString([key capitalizedString]);
        if(classObject) {
            id subObj = [self dictionaryWithPropertiesOfObject:[obj valueForKey:key]];
            [dict setObject:subObj forKey:key];
        } else {
            id value = [obj valueForKey:key];
            if(value) [dict setObject:value forKey:key];
        }
    }
    free(properties);
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
