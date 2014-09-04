//
//  SchTextField.h
//  Buyers
//
//  Created by webdevelopment on 12/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchTextField : UITextField <UITextFieldDelegate, UIPopoverControllerDelegate, UIPickerViewDelegate,UIPickerViewDataSource>

@property UIPopoverController *popover;
@property (nonatomic) NSMutableArray * listItems;

- (NSString *)getSelectedValue;
@end
