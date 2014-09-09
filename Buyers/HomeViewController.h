//
//  HomeViewController.h
//  Buyers
//
//  Created by webdevelopment on 05/08/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (nonatomic) IBOutlet UILabel *syncLabel;
@property (nonatomic) IBOutlet UIImageView *syncImage;

-(IBAction) btnClick:(id)sender;
@end
