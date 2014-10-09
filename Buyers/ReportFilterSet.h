//
//  ReportFilterSet.h
//  Buyers
//
//  Created by webdevelopment on 06/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReportFilterSet : NSManagedObject

@property (nonatomic, retain) NSString * filterSetName;
@property (nonatomic, retain) NSString * filterValues;
@property (nonatomic, retain) NSString * reportType;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSDate * lastSync;

@end
