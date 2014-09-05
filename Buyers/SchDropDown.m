//
//  SchDropDown.m
//  Buyers
//
//  Created by webdevelopment on 20/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "SchDropDown.h"

@implementation SchDropDown

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

- (void)setUpTextField {
    
    self.borderStyle = UITextBorderStyleNone;
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0f];
    self.textColor = [UIColor darkGrayColor];
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.layer setBorderWidth:2];
    [self.layer setCornerRadius:self.frame.size.height / 2];
    self.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    self.delegate = self;
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
        
//        UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
//        //picker.backgroundColor = [UIColor redColor];
//        picker.delegate = self;
//        picker.dataSource = self;
//        [popoverView addSubview:picker];

        UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 280, 200) style:UITableViewStylePlain];
        //picker.backgroundColor = [UIColor redColor];
        table.separatorInset = UIEdgeInsetsZero;
        table.delegate = self;
        table.dataSource = self;
        [popoverView addSubview:table];
        
        popoverContent.view = popoverView;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        self.popover.delegate = self;
        [self.popover setPopoverContentSize:CGSizeMake(280, 200) animated:NO];
        
        if(![self.text isEqualToString:@""]) {
            for (int i = 0; i < self.listItems.count; i++) {
                
                if([self.text isEqualToString:self.listItems[i][[[self.listItems[i] allKeys] objectAtIndex:0]]]) {
                    //[picker selectRow:i inComponent:0 animated:NO];
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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellID";//[self.listItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *listItem = (NSDictionary *)self.listItems[indexPath.row];
    cell.textLabel.text = listItem[[[listItem allKeys] objectAtIndex:0]];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor clearColor];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *listItem = (NSDictionary *)self.listItems[indexPath.row];
    self.text = listItem[[[listItem allKeys] objectAtIndex:0]];
    [self.popover dismissPopoverAnimated:YES];
}



@end
