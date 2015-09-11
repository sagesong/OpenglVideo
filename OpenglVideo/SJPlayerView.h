//
//  SJPlayerView.h
//  OpenglVideo
//
//  Created by Lightning on 15/9/9.
//  Copyright (c) 2015年 Lightning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface SJPlayerView : UIView

@property CGSize preferSize;
@property GLfloat preferredRotation;
@property GLfloat chromaThreshold;
@property GLfloat lumaThreshold;

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)setupGL;
@end
