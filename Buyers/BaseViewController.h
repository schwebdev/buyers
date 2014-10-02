//
//  ReportsViewController.h
//  Buyers
//
//  Created by webdevelopment on 08/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "SidebarViewController.h"

@interface BaseViewController : UIViewController <UINavigationControllerDelegate>

+ (UIView *)genNavWithTitle:(NSString*)title1 title2:(NSString*)title2 image:(NSString*)image;
+ (UIView *)genTopBarWithTitle:(NSString*)title;
- (UIButton *)setMenuButton:(NSInteger)index title:(NSString*)title;
@end
