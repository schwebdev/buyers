//
//  SettingsHomeViewController.h
//  Buyers
//
//  Created by webdevelopment on 11/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingsHomeViewController : BaseViewController

@property(nonatomic,retain) IBOutlet UITextField *userName;
@property (nonatomic,retain) IBOutlet UILabel *syncLabel;
@property (nonatomic,retain) IBOutlet UILabel *syncDays;

-(IBAction)saveUserName:(id)sender;

-(IBAction)startSync:(id)sender;
@end
