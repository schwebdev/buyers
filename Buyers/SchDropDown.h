//
//  SchDropDown.h
//  Buyers
//
//  Created by webdevelopment on 20/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchDropDown : UITextField <UITextFieldDelegate, UIPopoverControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property UIPopoverController *popover;
@property (nonatomic) NSMutableArray * listItems;

- (void)setListItems:(NSMutableArray *)listItems withName:(NSString *)listName withValue:(NSString *)listValue;
- (NSString *)getSelectedValue;
- (NSDictionary *)getSelectedObject;
@end
