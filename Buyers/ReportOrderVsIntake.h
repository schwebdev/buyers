//
//  ReportOrderVsIntake.h
//  Buyers
//
//  Created by webdevelopment on 23/09/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ReportOrderVsIntake : NSManagedObject

@property (nonatomic, retain) NSNumber * tydiff;
@property (nonatomic, retain) NSNumber * diffonordvtyintake;
@property (nonatomic, retain) NSNumber * lyunitssold;
@property (nonatomic, retain) NSNumber * lymarginachieved;
@property (nonatomic, retain) NSNumber * lyunitsintake;
@property (nonatomic, retain) NSNumber * lycostintake;
@property (nonatomic, retain) NSNumber * lyavecostintake;
@property (nonatomic, retain) NSNumber * lynewskus;
@property (nonatomic, retain) NSNumber * tyonorderunits;
@property (nonatomic, retain) NSNumber * diffonordvlyintake;
@property (nonatomic, retain) NSNumber * lydiff;
@property (nonatomic, retain) NSNumber * tyonordercost;
@property (nonatomic, retain) NSNumber * tyavecostonorder;
@property (nonatomic, retain) NSNumber * tynewskus;
@property (nonatomic, retain) NSNumber * skusdiff;
@property (nonatomic, retain) NSString * supplierref;

@end
