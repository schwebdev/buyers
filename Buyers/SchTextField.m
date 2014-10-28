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

- (void)setUpTextField {
    
    self.borderStyle = UITextBorderStyleNone;
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
    self.textColor = [UIColor darkGrayColor];
    [self.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.layer setBorderWidth:2];
    [self.layer setCornerRadius:self.frame.size.height / 2];
    //self.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    
    
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

-(CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 10, 0, 10))];
}

-(CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 10, 0, 10))];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
