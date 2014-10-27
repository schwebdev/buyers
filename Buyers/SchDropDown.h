//
//  SchDropDown.h
//  Buyers
//
//  Created by webdevelopment on 20/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchDropDown : UITextField <UITextFieldDelegate, UIPopoverControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) NSString *observerName;
@property (nonatomic) NSMutableArray * listItems;

- (void)setListItems:(NSMutableArray *)listItems withName:(NSString *)listName withValue:(NSString *)listValue;
- (NSString *)getSelectedValue;
- (NSString *)getSelectedText;
- (NSDictionary *)getSelectedObject;
- (void)setSelectedValue:(NSString *)value;

@end
