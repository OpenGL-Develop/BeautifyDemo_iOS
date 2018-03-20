/*
     File: OpenGLPixelBufferView.h
 Abstract: The OpenGL ES view
  Version: 2.1
 
 */

#import <Foundation/Foundation.h>
#import "MGOpenGLConfig.h"


@interface MGOpenGLView : UIView

@property (nonatomic, copy) NSString *debugStr;
@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, copy) NSString *fps;

- (void)displayPixelBuffer:(CVPixelBufferRef )pixelBuffer;


- (void)flushPixelBufferCache;
- (void)reset;



@end
