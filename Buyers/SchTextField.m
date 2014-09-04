//
//  SchTextField.m
//  Buyers
//
//  Created by webdevelopment on 12/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SchTextField.h"



@interface SchTextField ()

@end

@implementation SchTextField

- (NSString *)getSelectedValue {
    NSString *returnVal = @"";
    if(self.listItems!= nil) {
        for (NSDictionary *item in self.listItems) {
            if([self.text isEqualToString:item[[[item allKeys] objectAtIndex:0]]]) {
                returnVal = [[item allKeys] objectAtIndex:0];
            }
        }
    }
    return returnVal;
}

- (BOOL)test:(NSNotification *)notif{
    
    if(self.listItems!= nil) {
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1"  message:self.items[@"1"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        //[alert show];
        
        //if(self.popover == nil) {
        UIViewController *popoverContent = [[UIViewController alloc] init];
        
        UIView *popoverView = [[UIView alloc] init];
        
        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
        //picker.backgroundColor = [UIColor redColor];
        picker.delegate = self;
        picker.dataSource = self;
        [popoverView addSubview:picker];
        
        popoverContent.view = popoverView;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popover.delegate = self;
        [self.popover setPopoverContentSize:CGSizeMake(280, 180) animated:NO];
        
        if(![self.text isEqualToString:@""]) {
            for (int i = 0; i < self.listItems.count; i++) {
                
                if([self.text isEqualToString:self.listItems[i][[[self.listItems[i] allKeys] objectAtIndex:0]]]) {
                    [picker selectRow:i inComponent:0 animated:NO];
                }
            }
        }
        
        //}
        
        [self.popover presentPopoverFromRect:self.textInputView.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        return NO;
    } else {
        return YES;
    }
}
- (void)setUpTextField {
    
    self.borderStyle = UITextBorderStyleNone;
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    self.textColor = [UIColor darkGrayColor];
    [self.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.layer setBorderWidth:2];
    [self.layer setCornerRadius:self.frame.size.height / 2];
    self.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.delegate = self;//[[SchTextFieldDelegate alloc] init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test:) name:UIKeyboardWillShowNotification object:self];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self setUpTextField];
    }
    return self;

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setUpTextField];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if(self.listItems!= nil) {
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1"  message:self.items[@"1"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        //[alert show];
        
        //if(self.popover == nil) {
            UIViewController *popoverContent = [[UIViewController alloc] init];
            
            UIView *popoverView = [[UIView alloc] init];
            
            UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
            //picker.backgroundColor = [UIColor redColor];
            picker.delegate = self;
            picker.dataSource = self;
            [popoverView addSubview:picker];
            
            popoverContent.view = popoverView;
        
            self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
            self.popover.delegate = self;
            [self.popover setPopoverContentSize:CGSizeMake(280, 180) animated:NO];
        
            if(![self.text isEqualToString:@""]) {
                for (int i = 0; i < self.listItems.count; i++) {
                    
                    if([self.text isEqualToString:self.listItems[i][[[self.listItems[i] allKeys] objectAtIndex:0]]]) {
                        [picker selectRow:i inComponent:0 animated:NO];
                    }
                }
            }

        //}
        
        [self.popover presentPopoverFromRect:textField.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
        return NO;
    } else {
        return YES;
        
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.listItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *listItem = (NSDictionary *)self.listItems[row];
    
    return listItem[[[listItem allKeys] objectAtIndex:0]];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *listItem = (NSDictionary *)self.listItems[row];
    self.text = listItem[[[listItem allKeys] objectAtIndex:0]];
    [self.popover dismissPopoverAnimated:YES];
}

@end
