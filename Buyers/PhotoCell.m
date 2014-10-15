//
//  PhotoCell.m
//  Buyers
//
//  Created by Schuh Webdev on 09/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell ()
// 1
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end

@implementation PhotoCell
- (void) setAsset:(ALAsset *)asset
{
    // 2
    _asset = asset;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}
@end
