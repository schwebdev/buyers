//
//  ReportData.h
//  Buyers
//
//  Created by webdevelopment on 08/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReportData : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * reportID;
@property (nonatomic, retain) NSDate * lastSync;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSNumber * requiresSync;

@end
