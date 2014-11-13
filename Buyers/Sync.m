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
#import "Material.h"
#import "CalYearWeek.h"
#import "Department.h"
#import "Merch.h"

#import "Report.h"
#import "ReportFilterSet.h"
#import "ReportOrderVsIntake.h"
#import "ReportData.h"
#import "ReportFilterSet.h"
#import "ProductCategory.h"
#import "Colour.h"
#import "Material.h"
#import "Product.h"
#import "Collection.h"
#import "ProductOrder.h"

@implementation Sync
NSDate *globalProductSync;

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

+ (NSDate *)getLastSyncForTable:(NSString *)table {
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    //NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:table];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"SyncStatus"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(type == %@)",table]];
    [request setFetchLimit:1];
    [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"lastSync" ascending:NO]]];
    
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

+ (BOOL)syncTable:(NSString *)type {
    NSError *error;
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSURL *url;
    UIImage *defaultImage = [UIImage imageNamed:@"shoeOutlineNoImage.png"];
    NSData *defaultImageData = [NSData dataWithData:UIImagePNGRepresentation(defaultImage)];
    if([type isEqualToString:@"Supplier"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getsuppliers"];
    if([type isEqualToString:@"Brand"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getbrands"];
    if([type isEqualToString:@"CalYearWeek"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcalyearweeks"];
    if([type isEqualToString:@"Merch"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getmerch"];
    if([type isEqualToString:@"Department"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getdepartments"];
    if([type isEqualToString:@"ProductCategory"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcategory"];
    if([type isEqualToString:@"Colour"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcolour"];
    if([type isEqualToString:@"Material"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getmaterial"];
    if([type isEqualToString:@"Product"]) {
        NSDate *lastProductSync = [Sync getLastSyncForTable:@"Product"];
        globalProductSync = lastProductSync;
        if(lastProductSync == nil) {
            url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getItem/-1"];
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy-MM-dd%20HH_mm"];
            NSString *formatDate = [dateFormat stringFromDate:lastProductSync];
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aws.schuhshark.com:3000/buyingservice.svc/getItem/%@",formatDate]];
   
        }
    }
    /*if([type isEqualToString:@"Collection"]) {
        NSDate *lastCollectionSync = [Sync getLastSyncForTable:@"Collection"];
        if(lastCollectionSync == nil) {
            url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getCollection/-1"];
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"yyyy-MM-dd%20HH_mm"];
            NSString *formatDate = [dateFormat stringFromDate:lastCollectionSync];
            url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aws.schuhshark.com:3000/buyingservice.svc/getCollection/%@",formatDate]];
            
        }
    }*/
    
    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
    
    if(!data) {
        NSLog(@"%@ download error:%@", type, error.localizedDescription);
        return NO;
    }
    
    
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if(results == nil) {
        NSLog(@"%@ json error: %@", type, error);
        return NO;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:type];
    NSArray *currentResults = [managedContext executeFetchRequest:request error:&error];
    
    //only remove support table data for support table items - not products or collections
    if(![type isEqualToString:@"Product"]) { //&& ![type isEqualToString:@"Collection"]) {
        for (NSManagedObject *currentResult in currentResults) {
            [managedContext deleteObject:currentResult];
        }
    }
    
    //run imports on background thread then merge into main context s
    NSPersistentStoreCoordinator *persistentStoreCoordinator =[(AppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator];
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.persistentStoreCoordinator = persistentStoreCoordinator;
    backgroundContext.undoManager = nil;
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSManagedObjectContextDidSaveNotification
     object:backgroundContext
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note)
     {
         [managedContext mergeChangesFromContextDidSaveNotification:note];
     }];
    
    [backgroundContext performBlockAndWait:^
    {
        //import
        for (NSDictionary *result in results) {
            if([type isEqualToString:@"Supplier"]) {
                Supplier *supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:backgroundContext];
                supplier.supplierCode = result[@"Sup_Code"];
                supplier.supplierName = result[@"Sup_Name"];
            }
            if([type isEqualToString:@"Brand"]) {
                Brand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:backgroundContext];
                brand.brandRef = result[@"brandRef"];
                brand.brandName = result[@"brandName"];
            }
            if([type isEqualToString:@"CalYearWeek"]) {
                CalYearWeek *yearWeek = [NSEntityDescription insertNewObjectForEntityForName:@"CalYearWeek" inManagedObjectContext:backgroundContext];
                yearWeek.calYearWeek = result[@"Cal_Year_Week"];
            }
            if([type isEqualToString:@"Merch"]) {
                Merch *merch = [NSEntityDescription insertNewObjectForEntityForName:@"Merch" inManagedObjectContext:backgroundContext];
                merch.merchRef = result[@"MerchRef"];
                merch.merchName = result[@"MerchName"];
            }
            if([type isEqualToString:@"Department"]) {
                Department *department = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:backgroundContext];
                department.depCode = [NSNumber numberWithInt:[result[@"DepCode"] intValue]];
                department.depDesc = result[@"Desc"];
            }
            
            if([type isEqualToString:@"ProductCategory"]) {
                ProductCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ProductCategory" inManagedObjectContext:backgroundContext];
                category.category2Ref = result[@"c2_ref"];
                category.categoryName = result[@"CategoryName"];
            }
            if([type isEqualToString:@"Colour"]) {
                Colour *colour = [NSEntityDescription insertNewObjectForEntityForName:@"Colour" inManagedObjectContext:backgroundContext];
                colour.colourRef= result[@"c_ref"];
                colour.colourName = result[@"c_name"];
            }
            if([type isEqualToString:@"Material"]) {
                Material *material = [NSEntityDescription insertNewObjectForEntityForName:@"Material" inManagedObjectContext:backgroundContext];
                material.materialRef= result[@"m_ref"];
                material.materialName = result[@"m_name"];
            }
            if([type isEqualToString:@"Product"]) {
                NSDate *lastProductSync = [Sync getLastSyncForTable:@"Product"];
                globalProductSync = lastProductSync;
                if(lastProductSync == nil) {
                    //insert all product data
                    Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:backgroundContext];
                    [Sync insertProduct:product withData:result];
                } else {
                    //check for deletion and delete first
                    //get the object from currentResults using predicate with guid
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"productGUID == %@",result[@"Guid"]];
                    NSArray *findObject = [currentResults filteredArrayUsingPredicate:predicate];
                    if([findObject count] > 0) {
                        Product *product = (Product*)[findObject objectAtIndex:0];
                        NSString *deleteProduct = result[@"Deleted"];
                        if([deleteProduct isEqual:@"true"]) {
                            
                                //delete from any collections that contain the product
                                NSError *error;
                                NSPredicate *predicate2 =[NSPredicate predicateWithFormat:@"products contains %@",product];
                            
                                NSFetchRequest *requestCollections = [[NSFetchRequest alloc] initWithEntityName:@"Collection"];
                                NSArray *collections = [backgroundContext executeFetchRequest:requestCollections error:&error];
                                NSArray *foundCollections = [collections filteredArrayUsingPredicate:predicate2];
                                
                                 for (Collection *collection in foundCollections) {
                                     [collection removeProductsObject:product];
                                     collection.collectionLastUpdateDate = [NSDate date];
                                     collection.collectionLastUpdatedBy = @"SHARK";
                                 }
                            
                                //delete from product order
                                NSPredicate *predicate3 =[NSPredicate predicateWithFormat:@"orderProduct = %@",product];
                                NSFetchRequest *requestProductOrders = [[NSFetchRequest alloc] initWithEntityName:@"ProductOrder"];
                                NSArray *orders = [managedContext executeFetchRequest:requestProductOrders error:&error];
                                NSArray *foundOrders = [orders filteredArrayUsingPredicate:predicate3];
                                for (ProductOrder *pOrder in foundOrders) {
                                    [backgroundContext deleteObject:pOrder];
                                }
                            
                                //delete the product
                                [backgroundContext deleteObject:product];
                           

                        } else {
                            //update fields
                            product.productName = result[@"i_name"];
                            product.productPrice = [NSNumber numberWithDouble:[result[@"sellin"] doubleValue]];
                            product.productBrandRef = [NSNumber numberWithInt:[result[@"BrandRef"] intValue]];
                            product.productSupplierCode = result[@"main_sup_code"];
                            product.productCategoryRef = [NSNumber numberWithInt:[result[@"c2_ref"] intValue]];
                            product.productColourRef= [NSNumber numberWithInt:[result[@"c_ref"] intValue]];
                            product.productMaterialRef = [NSNumber numberWithInt:[result[@"m_ref"] intValue]];
                            product.productNotes = result[@"Notes"];
                            
                            NSString *lastUpdateBy = result[@"LastUpdateBy"];;
                            NSString *lastUpdated = result[@"LastUpdated"];
                            
                            if([lastUpdateBy  isEqual: @""]) {
                                product.productLastUpdatedBy = @"SHARK";
                            } else {
                                product.productLastUpdatedBy = result[@"LastUpdateBy"];
                            }
                            if([lastUpdated   isEqual: @"1/1/1900"] || [lastUpdated  isEqual: @""]) {
                                product.productLastUpdateDate = [NSDate date];
                            } else {
                                product.productLastUpdateDate = [Sync dateWithJSONString:lastUpdated];
                            }
                            
                            NSError *error;
                            NSString *strURL = result[@"ImageURL"];
                            NSURL *url = [[NSURL alloc] initWithString:strURL];
                            NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                            if(error) {
                                product.productImageData = defaultImageData;
                            } else {
                                product.productImageData = imageData;
                            }

                        }
                    } else {
                        //insert the product
                        Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:backgroundContext];
                         [Sync insertProduct:product withData:result];
                    }
                
                }
                
            }
            
           if([type isEqualToString:@"Collection"]) {
                NSDate *lastSync = [Sync getLastSyncForTable:@"Collection"];
                if(lastSync == nil) {
                    //insert all collection data
                    Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:backgroundContext];
                    [Sync insertCollection:collection withData:result withContext:backgroundContext withResults:currentResults];
                } else {
                    //check for deletion and delete first
                    //get the object from currentResults using predicate with guid
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"collectionGUID == %@",result[@"Guid"]];
                    NSArray *findObject = [currentResults filteredArrayUsingPredicate:predicate];
                    if([findObject count] > 0) {
                        Collection *collection = (Collection*)[findObject objectAtIndex:0];
                        NSString *deleteCollection = result[@"Deleted"];
                        if([deleteCollection isEqual:@"true"]) {
                            
                            //delete from any product orders
                            [collection removeProducts:collection.products];
                            [collection removeCollectionProductOrder:collection.collectionProductOrder];
                            
                            //delete the collection
                            [backgroundContext deleteObject:collection];
                            
                        } else {
                            //update fields
                            collection.collectionNotes = result[@"Notes"];
                            
                            NSString *lastUpdateBy = result[@"LastUpdateBy"];;
                            NSString *lastUpdated = result[@"LastUpdated"];
                            
                            if([lastUpdateBy  isEqual: @""]) {
                                collection.collectionLastUpdatedBy = @"SHARK";
                            } else {
                                collection.collectionLastUpdatedBy = result[@"LastUpdateBy"];
                            }
                            if([lastUpdated  isEqual: @""]) {
                                collection.collectionLastUpdateDate = [NSDate date];
                            } else {
                                collection.collectionLastUpdateDate = [Sync dateWithJSONString:lastUpdated];
                            }
                            //delete product and ordering in case they have changed
                            [collection removeProducts:collection.products];
                            [collection removeCollectionProductOrder:collection.collectionProductOrder];
                            
                            //insert products with order number to create Product Ordering part
                            NSError *error;
                            NSArray *products = [NSJSONSerialization JSONObjectWithData:result[@"products"] options:kNilOptions error:&error];
                            if(products != nil) {
                                
                                for (NSDictionary *po in products) {
                                    
                                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"productGUID == %@",po[@"Guid"]];
                                    NSArray *findObject = [currentResults filteredArrayUsingPredicate:predicate];
                                    if([findObject count] > 0) {
                                        Product *product = (Product*)[findObject objectAtIndex:0];
                                        
                                        //check it doesn't exist in the collection already and is not flagged for deletion
                                        if(![collection.products containsObject:product] && !product.productDeleted.boolValue){
                                            
                                            //add collection
                                            [product addCollectionsObject:collection];
                                            
                                            //add product order
                                            ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:backgroundContext];
                                            int number = (int)po[@"orderNumber"];
                                            productOrder.productOrder = [NSNumber numberWithInt:number];
                                            productOrder.orderCollection = collection;
                                            productOrder.orderProduct = product;
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    } else {
                        //insert the collection data
                        Collection *collection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection" inManagedObjectContext:backgroundContext];
                        [Sync insertCollection:collection withData:result withContext:backgroundContext withResults:currentResults];

                    }
                    
                }
            }
           
            
        }
        
      
   }];
    
    NSError *saveError;
    if(![backgroundContext save:&saveError]) {
        NSLog(@"Could not save %@ data: %@",type, [saveError localizedDescription]);
        
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
        
        NSLog(@"%lu %@ entries created",(unsigned long)results.count, type);
    }
    
    
    [self updateSyncStatus:type];
    
    return YES;
    
}
     
+(void)insertCollection:(Collection*)collection withData:(NSDictionary*)result withContext:(NSManagedObjectContext*)context withResults:(NSArray*)currentResults {
   
    collection.collectionName = result[@"collectionName"];
    collection.collectionGUID =result[@"Guid"];
    collection.collectionBrandRef = [NSNumber numberWithInt:[result[@"BrandRef"] intValue]];
    collection.collectionNotes = result[@"Notes"];
    collection.collectionDeleted = [NSNumber numberWithBool:NO];
    
    NSString *createdBy = result[@"CreatedBy"];
    NSString *lastUpdateBy = result[@"LastUpdateBy"];
    NSString *createdDate = result[@"CreatedDate"];
    NSString *lastUpdated = result[@"LastUpdated"];
    
    if([createdBy  isEqual: @""]) {
        collection.collectionCreator = @"SHARK";
    } else {
        collection.collectionCreator = result[@"CreatedBy"];
    }
    if([lastUpdateBy  isEqual: @""]) {
        collection.collectionLastUpdatedBy = @"SHARK";
    } else {
        collection.collectionLastUpdatedBy = result[@"LastUpdateBy"];
    }
    if([createdDate  isEqual:@""]) {
        collection.collectionCreationDate = [NSDate date];
    } else {
        collection.collectionCreationDate = [Sync dateWithJSONString:createdDate];
    }
    if([lastUpdated  isEqual: @""]) {
        collection.collectionLastUpdateDate = [NSDate date];
    } else {
        collection.collectionLastUpdateDate = [Sync dateWithJSONString:lastUpdated];
    }
    
    //  insert products with order number to create Product Ordering part
    NSError *error;
    NSArray *products = [NSJSONSerialization JSONObjectWithData:result[@"products"] options:kNilOptions error:&error];
    if(products != nil) {
        
        for (NSDictionary *po in products) {
            
            NSPredicate *predicate =[NSPredicate predicateWithFormat:@"productGUID == %@",po[@"Guid"]];
            NSArray *findObject = [currentResults filteredArrayUsingPredicate:predicate];
            if([findObject count] > 0) {
                Product *product = (Product*)[findObject objectAtIndex:0];
                
                //check it doesn't exist in the collection already and is not flagged for deletion
                if(![collection.products containsObject:product] && !product.productDeleted.boolValue){
                    
                    //add collection
                    [product addCollectionsObject:collection];
                    
                    //add product order
                    ProductOrder *productOrder = [NSEntityDescription insertNewObjectForEntityForName:@"ProductOrder" inManagedObjectContext:context];
                    int number = (int)po[@"orderNumber"];
                    productOrder.productOrder = [NSNumber numberWithInt:number];
                    productOrder.orderCollection = collection;
                    productOrder.orderProduct = product;
                }
            }
        }
    }
}

+(void)insertProduct:(Product*)product withData:(NSDictionary*)result {
    product.productCode =result[@"i_Code"];
    product.productName = result[@"i_name"];
    product.productPrice = [NSNumber numberWithDouble:[result[@"sellin"] doubleValue]];
    product.productBrandRef = [NSNumber numberWithInt:[result[@"BrandRef"] intValue]];
    product.productSupplierCode = result[@"main_sup_code"];
    product.productCategoryRef = [NSNumber numberWithInt:[result[@"c2_ref"] intValue]];
    product.productColourRef= [NSNumber numberWithInt:[result[@"c_ref"] intValue]];
    product.productMaterialRef = [NSNumber numberWithInt:[result[@"m_ref"] intValue]];
    product.productNotes = result[@"Notes"];
    product.productGUID =result[@"Guid"];
    product.productDeleted = [NSNumber numberWithBool:NO];
    NSString *createdBy = result[@"CreatedBy"];
    NSString *lastUpdateBy = result[@"LastUpdateBy"];
    NSString *createdDate = result[@"CreatedDate"];
    NSString *lastUpdated = result[@"LastUpdated"];
    
    if([createdBy  isEqual: @""]) {
        product.productCreator = @"SHARK";
    } else {
        product.productCreator = result[@"CreatedBy"];
    }
    if([lastUpdateBy  isEqual: @""]) {
        product.productLastUpdatedBy = @"SHARK";
    } else {
        product.productLastUpdatedBy = result[@"LastUpdateBy"];
    }
    if([createdDate  isEqual: @"1/1/1900"] || [createdDate  isEqual:@""]) {
        product.productCreationDate = [NSDate date];
    } else {
        product.productCreationDate = [Sync dateWithJSONString:createdDate];
    }
    if([lastUpdated   isEqual: @"1/1/1900"] || [lastUpdated  isEqual: @""]) {
        product.productLastUpdateDate = [NSDate date];
    } else {
        product.productLastUpdateDate = [Sync dateWithJSONString:lastUpdated];
    }
    UIImage *defaultImage = [UIImage imageNamed:@"shoeOutlineNoImage.png"];
    NSData *defaultImageData = [NSData dataWithData:UIImagePNGRepresentation(defaultImage)];
    NSError *error;
    NSString *strURL = result[@"ImageURL"];
    NSURL *url = [[NSURL alloc] initWithString:strURL];
    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    if(error) {
        product.productImageData = defaultImageData;
    } else {
        product.productImageData = imageData;
    }
   
}

+(NSDate*)dateWithJSONString:(NSString*)dateStr {
    //convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    //NSLog(@"Date: %@",dateStr);
    
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    return date;
}

//
//+ (BOOL)syncReportsOrderVsIntake {
//
//    NSError *error;
//    NSURL *url = [[NSURL alloc] initWithString:@"http://mie.schuh.co.uk/test.txt"];
//
//    NSData *data=[NSURLConnection sendSynchronousRequest:[[NSURLRequest alloc] initWithURL:url] returningResponse:nil error:&error];
//
//    if(!data) {
//        NSLog(@"download error:%@", error.localizedDescription);
//        return NO;
//    }
//
//    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    if(results == nil) {
//        NSLog(@"json error: %@", error);
//        return NO;
//    }
//    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportOrderVsIntake"];
//    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
//    
//    for (NSManagedObject *oldResult in oldResults) {
//        [managedContext deleteObject:oldResult];
//    }
//    
//    for (NSDictionary *result in results) {
//        //save the new collection
//        ReportOrderVsIntake *row = [NSEntityDescription insertNewObjectForEntityForName:@"ReportOrderVsIntake" inManagedObjectContext:managedContext];
//        
//        for(NSString *key in result.allKeys) {
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportOrderVsIntake" inManagedObjectContext:managedContext];
//            
//            NSDictionary *attributes = [entity attributesByName];
//            NSAttributeDescription *attrDesc = [attributes objectForKey:[key lowercaseString]];
//            if([attrDesc attributeType] == NSInteger32AttributeType) {
//                [row setValue:[NSNumber numberWithInt:[result[key] intValue]] forKey:[key lowercaseString]];
//            } else if([attrDesc attributeType] == NSFloatAttributeType) {
//                [row setValue:[NSNumber numberWithFloat:[result[key] floatValue]] forKey:[key lowercaseString]];
//            } else {
//                [row setValue:result[key] forKey:[key lowercaseString]];
//            }
//        }
//    }
//    
//    NSError *saveError;
//    if(![managedContext save:&saveError]) {
//        NSLog(@"Could not save ReportOrderVsIntake: %@", [saveError localizedDescription]);
//        
//        NSArray *detailedErrors = [[saveError userInfo] objectForKey:NSDetailedErrorsKey];
//        if(detailedErrors != nil && [detailedErrors count] > 0) {
//            for(NSError* detailedError in detailedErrors) {
//                NSLog(@" detailed error:%@", [detailedError userInfo]);
//                NSLog(@" detailed error:%ld", (long)[detailedError code]);
//            }
//        } else {
//            NSLog(@" detailed error:%@", [saveError userInfo]);
//        }
//        return NO;
//    } else {
//        
//        NSLog(@"%lu ReportOrderVsIntake entries created",(unsigned long)results.count);
//    }
//    
//    
//    [self updateSyncStatus:@"reportordervsintake"];
//    return YES;
//}

+ (BOOL)syncCollectionData {
    //get user's full name from app settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
    BOOL syncSuccess = YES;
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    //get modified data for upload which include products that have been flagged for deletion and products that have been updated since last sync date
    NSError *error;
    NSArray *collections = [Sync getNestedTable:@"Collection" sortWith:@"collectionName" withPredicate:[NSPredicate predicateWithFormat:@"collectionLastUpdateDate > %@  AND collectionLastUpdatedBy = %@",globalProductSync,creatorName]];
    
    if([collections count] > 0 ) {
        for (NSMutableDictionary *collection in collections) {
            
            //NSMutableArray *products = [[NSMutableArray alloc] init];
            NSMutableDictionary *main_dictionary = [NSMutableDictionary dictionary];
            NSMutableDictionary *item_dictionary = [NSMutableDictionary dictionary];
            [item_dictionary setObject:@"ABCDEFGHI" forKey:@"GUID"];
            [item_dictionary setObject:@"1" forKey:@"productOrder"];
            [main_dictionary setObject:item_dictionary forKey:@"product1"];
            
            [item_dictionary setObject:@"JKLMNOPQR" forKey:@"GUID"];
            [item_dictionary setObject:@"2" forKey:@"productOrder"];
            [main_dictionary setObject:item_dictionary forKey:@"product2"];
            
            
            [collection removeObjectForKey:@"IDURI"];
            [collection removeObjectForKey:@"products"];
            [collection removeObjectForKey:@"collectionProductOrder"];
            
            [collection setObject:main_dictionary forKey:@"products"];
            
            for (NSString *key in [collection allKeys]) {
                id object = collection[key];
              
                if([object isKindOfClass:[NSDate class]]) {
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    
                    collection[key] = [dateFormat stringFromDate:(NSDate*)collection[key]];
                }
                
                if([object isKindOfClass:[NSSet class]]) {
                    
                    NSLog(@"NSSET:  %@",object);
                }

            }
        }
        
        NSData *jsonCollectionData = [NSJSONSerialization dataWithJSONObject:collections options:kNilOptions error:&error];
        NSString *collectionData = [[NSString alloc] initWithData:jsonCollectionData encoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/postItem"]];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:collectionData forKey:@"JsonData"];
    }
    
    
    return syncSuccess;
}


+ (BOOL)syncProductData {
    
    //get user's full name from app settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *creatorName = [defaults objectForKey:@"username"];
    BOOL syncSuccess = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSString *formatDate = [dateFormat stringFromDate:globalProductSync];
    NSLog(@"global product sync: %@", formatDate);
    
       if(globalProductSync != nil) {
           NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
         //get modified data for upload which include products that have been flagged for deletion and products that have been updated since last sync date
        NSError *error;
        NSArray *products = [Sync getTable:@"Product" sortWith:@"productName" withPredicate:[NSPredicate predicateWithFormat:@"productLastUpdateDate > %@  AND productLastUpdatedBy = %@",globalProductSync,creatorName]];
           
        if([products count] > 0 ) {
           
        //get modified data for upload and remove relationship keys for collections and product ordering
        for (NSMutableDictionary *product in products) {
            [product removeObjectForKey:@"IDURI"];
            [product removeObjectForKey:@"collections"];
            [product removeObjectForKey:@"productOrder"];
            
            //if product is a schuh product or is flagged for deletion don't send the image data
            NSString *p_iCode = [product valueForKey:@"productCode"];
            NSNumber *p_delete = [product valueForKey:@"productDeleted"];
            
            for (NSString *key in [product allKeys]) {
                id object = product[key];
                if([object isKindOfClass:[NSData class]]) {
                    
                    if(![p_iCode isEqual:@"0000000000"] || p_delete == [NSNumber numberWithInt:1]) {
                         product[key] = @"";
                    } else {
                        NSString *imageString = [product[key] base64EncodedStringWithOptions:0];
                        product[key] = imageString;
                    }
                 }
               
                if([object isKindOfClass:[NSDate class]]) {
                    
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    
                    product[key] = [dateFormat stringFromDate:(NSDate*)product[key]];
                }
            }
            NSLog(@"uploading product: %@ with GUID: %@", product[@"productName"], product[@"productGUID"]);
        
        }
            
        //NSLog(@"products: %@",products);
        NSData *jsonProductData = [NSJSONSerialization dataWithJSONObject:products options:kNilOptions error:&error];
        NSString *productData = [[NSString alloc] initWithData:jsonProductData encoding:NSUTF8StringEncoding];
       
        //NSLog(@"JSON: %@",productData);
            
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/postItem"]];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:productData forKey:@"JsonData"];
            
        NSData *jsonParams = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
            
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonParams length]]  forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonParams];
            
        NSLog(@"request: %@", productData);
            
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSLog(@"response: %@", response);
         
        NSFetchRequest *productRequest = [[NSFetchRequest alloc] initWithEntityName:@"Product"];
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"productLastUpdateDate > %@ AND productLastUpdatedBy = %@",globalProductSync,creatorName];
        [productRequest setPredicate:pred];
        NSArray *updatedProducts = [managedContext executeFetchRequest:productRequest error:&error];
            if([response  statusCode] != 200) {
                syncSuccess = NO;
            }
        for (Product *product in updatedProducts) {

            if([response  statusCode] == 200) {
                if(product.productDeleted.boolValue) {
                    [managedContext deleteObject:product];
                }
            } else {
                NSString *note = [NSString stringWithFormat:@"\n\nProduct updates failed to  sync on last sync on %@. Please resave changes and sync again.",[dateFormat stringFromDate:[NSDate date]]];
                    if(product.productDeleted.boolValue) {
                        product.productDeleted = [NSNumber numberWithBool:NO];
                        note = [NSString stringWithFormat:@"\n\nProduct failed to be deleted on last sync on %@. Please delete and sync again.",[dateFormat stringFromDate:[NSDate date]]];
                    }
                product.productNotes = [product.productNotes stringByAppendingString:note];
                product.productLastUpdateDate = [NSDate date];
                product.productLastUpdatedBy = @"Sync";
            }
        }
            
            NSError *saveError;
            if(![managedContext save:&saveError]) {
                NSLog(@"Could not sync product data");
                
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
                NSLog(@"product data entry sync");
            }
            
        } //product count
       } //sync
    
    
    
    
    return syncSuccess;
}


+ (BOOL)syncReportData {
    NSError *error;
    NSArray *reports = [Sync getTable:@"ReportData" sortWith:@"reportID" withPredicate:[NSPredicate predicateWithFormat:@"(requiresSync == 1)"]];
    
    //get modified data for upload
    for (NSMutableDictionary *report in reports) {
        [report removeObjectForKey:@"IDURI"];
        for (NSString *key in [report allKeys]) {
            id object = report[key];
            
            if([object isKindOfClass:[NSDate class]]) {
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                
                report[key] = [dateFormat stringFromDate:(NSDate*)report[key]];
            }
        }
        NSLog(@"uploading report %@ - %@", report[@"name"], report[@"reportID"]);
    }
    NSData *jsonReportData = [NSJSONSerialization dataWithJSONObject:reports options:kNilOptions error:&error];
    NSString *reportData = [[NSString alloc] initWithData:jsonReportData encoding:NSUTF8StringEncoding];
    
    
    
    
    //get table last sync date
    NSDate *lastSync = [Sync getLastSyncForTable:@"ReportData"];
    if(lastSync == nil) {
        lastSync = [NSDate dateWithTimeIntervalSince1970:0];
    } else {
        lastSync = [lastSync dateByAddingTimeInterval:1];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //post request to web service
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://m.amazingfootwear.com/mstest.asmx/mstestsync"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:reportData forKey:@"jsonData"];
    [params setObject:[dateFormat stringFromDate:lastSync] forKey:@"lastSync"];
    
    NSData *jsonParams = [NSJSONSerialization dataWithJSONObject:params
                                                       options:kNilOptions
                                                         error:&error];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"json" forHTTPHeaderField:@"Data-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonParams length]]  forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonParams];
    
    NSURLResponse *response;
    NSData *resultData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(response) {
        //save data
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:resultData options:kNilOptions error:nil];
        NSString *jsonString = [json objectForKey:@"d"];
        NSArray *jsonReports = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        
        NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        
        NSDateFormatter *jsonDateFormat = [[NSDateFormatter alloc] init];
        jsonDateFormat.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        for (NSDictionary *jsonReport in jsonReports) {
            
            NSString *reportID = [jsonReport[@"reportID"] uppercaseString];
            //save report
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(reportID == %@)", reportID]];
            
            NSError *error;
            NSArray *reports = [managedContext executeFetchRequest:request error:&error];
            ReportData *report;
            
            if(![jsonReport[@"isActive"] isEqualToString:@"True"] && reports.count > 0) {
                [managedContext deleteObject:reports[0]];
                NSLog(@"deleted report %@ - %@", jsonReport[@"name"], reportID);
            } else {
                if(reports.count > 0) {
                    report = reports[0];
                } else {
                    report = [NSEntityDescription insertNewObjectForEntityForName:@"ReportData" inManagedObjectContext:managedContext];
                }
                report.reportID = reportID;
                report.name = jsonReport[@"name"];
                report.createdBy = jsonReport[@"createdBy"];
                report.content = jsonReport[@"content"];
                report.notes = jsonReport[@"notes"];
                report.isActive = ([jsonReport[@"isActive"] isEqualToString:@"True"]) ? @YES : @NO;
                report.requiresSync = @NO;
                report.lastModified = [jsonDateFormat dateFromString:jsonReport[@"lastModified"]];
                report.lastSync = [jsonDateFormat dateFromString:jsonReport[@"lastSync"]];
                
                
                NSLog(@"syncing report %@ - %@", jsonReport[@"name"], reportID);
            }
        }
        
        
        NSError *saveError;
        if(![managedContext save:&saveError]) {
            NSLog(@"Could not sync reportdata");
            
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
            NSLog(@"reportdata entry sync");
        }
    }
    return YES;
}

+ (BOOL)syncFilterReports {
    NSError *error;
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ReportFilterSet"];
    NSArray *results = [managedContext executeFetchRequest:request error:&error];
    
    for (ReportFilterSet *filterSet in results) {
        NSString *htmlString = [Report generateReport:filterSet.reportType withFilters:filterSet.filterValues];
        
        if(htmlString.length > 0) {
            NSString *reportName = [NSString stringWithFormat:@"filterReport:%@",filterSet.filterSetName];
            
            request = [[NSFetchRequest alloc] initWithEntityName:@"ReportData"];
            [request setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)",reportName]];
            
            NSError *error;
            NSArray *reports = [managedContext executeFetchRequest:request error:&error];
            ReportData *report;
            
            if(reports.count > 0) {
                report = reports[0];
            } else {
                report = [NSEntityDescription insertNewObjectForEntityForName:@"ReportData" inManagedObjectContext:managedContext];
                report.name = reportName;
            }
            
            report.content = htmlString;
            report.lastModified = [NSDate date];
            report.createdBy = @"sync";
            report.requiresSync = @NO;
            
            
            filterSet.lastSync = [NSDate date];
            
        }

    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
        NSLog(@"Could not save filter set reports: %@", [saveError localizedDescription]);
        
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
        NSLog(@"filter sets synced");
        
    }

    return YES;

}

+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column {
    return [self getTable:entityName sortWith:column withPredicate:nil];
}

+ (NSArray *)getTable:(NSString*)entityName sortWith:(NSString*)column withPredicate:(NSPredicate *)predicate {
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if(predicate != nil) {
        [request setPredicate:predicate];
    }
    
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

+ (NSArray *)getNestedTable:(NSString*)entityName sortWith:(NSString*)column withPredicate:(NSPredicate *)predicate {
    //fetch request to retrieve all collections
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    if(predicate != nil) {
        [request setPredicate:predicate];
    }
    
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


+ (NSMutableDictionary *)dictionaryWithPropertiesOfObject:(id)obj {
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
            else [dict setObject:[NSNull null] forKey:key];
        }
    }
    free(properties);
    
    
    [dict setObject:[[obj objectID]URIRepresentation] forKey:@"IDURI"];
    return dict;
}

@end
