//
//  AVCameraPreviewView.m
//  Buyers
//
//  Created by Schuh Webdev on 07/10/2014.
//  Copyright (c) 2014 schuh. All rights reserved.
//

#import "AVCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVCameraPreviewView

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session
{
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}

@end
