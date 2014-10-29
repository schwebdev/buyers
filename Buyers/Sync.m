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
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:table];
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
    //type = @"Supplier"
    NSError *error;
    NSURL *url;
    if([type isEqualToString:@"Supplier"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getsuppliers"];
    if([type isEqualToString:@"Brand"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getbrands"];
    if([type isEqualToString:@"CalYearWeek"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcalyearweeks"];
    if([type isEqualToString:@"Merch"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getmerch"];
    if([type isEqualToString:@"Department"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getdepartments"];
    if([type isEqualToString:@"ProductCategory"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcategory"];
    if([type isEqualToString:@"Colour"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getcolour"];
    if([type isEqualToString:@"Material"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getmaterial"];
    if([type isEqualToString:@"Product"]) url = [NSURL URLWithString:@"http://aws.schuhshark.com:3000/buyingservice.svc/getItem"];
    
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
    
    NSManagedObjectContext *managedContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:type];
    NSArray *oldResults = [managedContext executeFetchRequest:request error:&error];
    
    for (NSManagedObject *oldResult in oldResults) {
        [managedContext deleteObject:oldResult];
    }
    
    for (NSDictionary *result in results) {
        if([type isEqualToString:@"Supplier"]) {
            Supplier *supplier = [NSEntityDescription insertNewObjectForEntityForName:@"Supplier" inManagedObjectContext:managedContext];
            supplier.supplierCode = result[@"Sup_Code"];
            supplier.supplierName = result[@"Sup_Name"];
        }
        if([type isEqualToString:@"Brand"]) {
            Brand *brand = [NSEntityDescription insertNewObjectForEntityForName:@"Brand" inManagedObjectContext:managedContext];
            brand.brandRef = result[@"brandRef"];
            brand.brandName = result[@"brandName"];
        }
        if([type isEqualToString:@"CalYearWeek"]) {
            CalYearWeek *yearWeek = [NSEntityDescription insertNewObjectForEntityForName:@"CalYearWeek" inManagedObjectContext:managedContext];
            yearWeek.calYearWeek = result[@"Cal_Year_Week"];
        }
        if([type isEqualToString:@"Merch"]) {
            Merch *merch = [NSEntityDescription insertNewObjectForEntityForName:@"Merch" inManagedObjectContext:managedContext];
            merch.merchRef = result[@"MerchRef"];
            merch.merchName = result[@"MerchName"];
        }
        if([type isEqualToString:@"Department"]) {
            Department *department = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:managedContext];
            department.depCode = [NSNumber numberWithInt:[result[@"DepCode"] intValue]];
            department.depDesc = result[@"Desc"];
        }
        
        if([type isEqualToString:@"ProductCategory"]) {
            ProductCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ProductCategory" inManagedObjectContext:managedContext];
            category.category2Ref = result[@"c2_ref"];
            category.categoryName = result[@"CategoryName"];
        }
        if([type isEqualToString:@"Colour"]) {
            Colour *colour = [NSEntityDescription insertNewObjectForEntityForName:@"Colour" inManagedObjectContext:managedContext];
            colour.colourRef= result[@"c_ref"];
            colour.colourName = result[@"c_name"];
        }
        if([type isEqualToString:@"Material"]) {
            Material *material = [NSEntityDescription insertNewObjectForEntityForName:@"Material" inManagedObjectContext:managedContext];
            material.materialRef= result[@"m_ref"];
            material.materialName = result[@"m_name"];
        }
        if([type isEqualToString:@"Product"]) {
            Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:managedContext];
            product.productCode =result[@"i_Code"];
            product.productName = result[@"i_name"];
            product.productPrice = [NSNumber numberWithDouble:[result[@"sellin"] doubleValue]];
            product.productBrandRef = [NSNumber numberWithInt:[result[@"BrandRef"] intValue]];
            product.productSupplierCode = result[@"main_sup_code"];
            product.productCategoryRef = [NSNumber numberWithInt:[result[@"c2_ref"] intValue]];
            product.productColourRef= [NSNumber numberWithInt:[result[@"c_ref"] intValue]];
            product.productMaterialRef = [NSNumber numberWithInt:[result[@"m_ref"] intValue]];
            product.productNotes = @"test notes"; //result[@"productNotes"];
            
            NSError *error = nil;
            NSString *strURL = result[@"ImageURL"];
            NSURL *url = [[NSURL alloc] initWithString:strURL];
            NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            if(error) {
                 product.productImageData = nil; //could have holding image here
            } else {
                product.productImageData = imageData;
                NSLog(@"image: %@",strURL);
            }
        }
        
    }
    
    NSError *saveError;
    if(![managedContext save:&saveError]) {
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
//
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
