//
//  AVCameraPreviewView.h
//  Buyers
//
//  Created by Schuh Webdev on 07/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface AVCameraPreviewView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
