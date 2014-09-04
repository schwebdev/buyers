//
//  HomeViewController.h
//  Buyers
//
//  Created by webdevelopment on 05/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

-(IBAction) btnClick:(id)sender;
@end
