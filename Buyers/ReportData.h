//
//  ReportData.h
//  Buyers
//
//  Created by webdevelopment on 09/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReportData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSDate * lastModified;

@end
