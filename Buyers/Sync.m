//
//  Sync.m
//  Buyers
//
//  Created by webdevelopment on 05/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "Sync.h"
#import "AppDelegate.h"
#import "SyncStatus.h"
#import "Supplier.h"
#import "Brand.h"


@implementation Sync

+ (BOOL)syncAll {
    
    BOOL result = YES;
    
    [self updateSyncStatus:@"global"];
    
    //stop if result == NO
    result = [self syncSuppliers];
    
    result = [self syncBrands];
    
    return result;
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
    
    NSArray *suppliers = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(suppliers == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    //dictionary[3][@"Sup_Code"]
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
    NSArray *oldSuppliers = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *supplier in oldSuppliers) {
        [managedContext deleteObject:supplier];
    }
    
    for (NSDictionary *supplierData in suppliers) {
        //save the new collection
        Supplier *supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:managedContext];
        
        supplier.supplierCode = supplierData[@"Sup_Code"];
        supplier.supplierName = supplierData[@"Sup_Name"];
        
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save suppliers: %@", [saveError localizedDescription]);
        
        return NO;
    } else {
        
        NSLog(@"%d supplier entries created",suppliers.count);
    }
    
    [self updateSyncStatus:@"suppliers"];
    
    return YES;
}

+ (NSArray *)getSuppliers {
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Supplier"];
    NSError *error;
    NSArray *results = [managedContext executeFetchRequest:request error:&error];

    //NSSortDescriptor *numericSort = [[NSSortDescriptor alloc] initWithKey:@"collectionID" ascending:YES];
    NSSortDescriptor *alphaSort = [[NSSortDescriptor alloc] initWithKey:@"supplierName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:alphaSort,nil];
    results = [results sortedArrayUsingDescriptors:sortDescriptors];

    return results;
}


+ (BOOL)syncBrands {
    
    NSError *error;
    NSURL *url = [[NSURL alloc] initWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getbrands"];
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"download error:%@", error.localizedDescription);
        return NO;
    }
    
    NSArray *brands = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(brands == nil) {
        NSLog(@"json error: %@", error);
        return NO;
    }
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Brand"];
    NSArray *oldBrands = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *brand in oldBrands) {
        [managedContext deleteObject:brand];
    }
    
    for (NSDictionary *brandData in brands) {
        //save the new collection
        Brand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:managedContext];
        
        brand.brandRef = brandData[@"brandRef"];
        brand.brandName = brandData[@"brandName"];
        
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save brands: %@", [saveError localizedDescription]);
        
        return NO;
    } else {
        
        NSLog(@"%d brand entries created",brands.count);
    }
    
    [self updateSyncStatus:@"brand"];
    
    return YES;
}

@end
