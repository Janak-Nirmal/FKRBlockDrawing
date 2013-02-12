//
//  FKRViewController.m
//  FKRBlockDrawing
//
//  Created by Fabian Kreiser on 12.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "FKRViewController.h"
#import "FKRBlockDrawing.h"

@interface FKRViewController () {
    
}

+ (FKRBlockDrawingRenderBlock)simpleIconRenderBlock;
+ (FKRBlockDrawingRenderBlock)powerButtonRenderBlock;
+ (FKRBlockDrawingRenderBlock)blueButtonRenderBlock;

@end

@implementation FKRViewController

- (id)init
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"FKRBlockDrawing";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    /*
//     This would create a red circle with "Hello World!" written on it.
//    */
//
//    FKRBlockDrawingRenderBlock simpleRedIconRenderBlock = ^(CGContextRef context, CGSize size) {
//        CGRect rect = CGRectMake(0, 0, size.width, size.height);
//
//        [[UIColor redColor] set];
//        CGContextAddEllipseInRect(context, rect);
//        CGContextFillEllipseInRect(context, rect);
//
//        [[UIColor blackColor] set];
//        [@"Hello World!" drawInRect:CGRectInset(rect, 5, 10) withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
//    };
    
    // Create the render blocks
    FKRBlockDrawingRenderBlock simpleIconRenderBlock = [[self class] simpleIconRenderBlock];
    FKRBlockDrawingRenderBlock powerButtonRenderBlock = [[self class] powerButtonRenderBlock];
    FKRBlockDrawingRenderBlock blueButtonRenderBlock = [[self class] blueButtonRenderBlock];
	
    // 1) FKRBockDrawingView
    
    void (^blockDrawingViewDemo)(void) = ^(void) {
        FKRBlockDrawingView *view = [[FKRBlockDrawingView alloc] initWithFrame:self.view.bounds renderBlock:blueButtonRenderBlock];
        [self.view addSubview:view];
    };
    
    // 2) UIImage+FKRBlockDrawing
    
    void (^imageBlockDrawingDemo)(void) = ^(void) {
        UIImage *image = [UIImage imageWithRenderBlock:simpleIconRenderBlock size:CGSizeMake(72, 72)];
        
        for (NSUInteger i = 0; i < 10; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            
            imageView.frame = CGRectMake(20 * i, 40 * i, 72, 72);
            [self.view addSubview:imageView];
        }
    };
    
    // 3) FKRBlockDrawingLayer
    
    void (^layerBlockDrawingDemo)(void) = ^(void) {
        FKRBlockDrawingLayer *layer = [FKRBlockDrawingLayer layerWithRenderBlock:blueButtonRenderBlock];
        layer.frame = self.view.bounds;
        
        [self.view.layer addSublayer:layer];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.autoreverses = YES;
        animation.duration = 2.5;
        
        animation.fromValue = @1;
        animation.toValue = @0.1;
        
        [layer addAnimation:animation forKey:@"transform.scale"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            layer.renderBlock = powerButtonRenderBlock; // Implicit animation!
        });
    };
    
    // Run the demo with five seconds for each part
    blockDrawingViewDemo();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        imageBlockDrawingDemo();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            for (UIView *view in self.view.subviews) {
                [view removeFromSuperview];
            }
        });
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        layerBlockDrawingDemo();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
            for (CALayer *layer in self.view.layer.sublayers) {
                [layer removeFromSuperlayer];
            }
        });
    });
}

/*
 PaintCode is a great app and it's even better in conjunction with FKRBlockDrawing. Give it a try!
 All these examples are from: http://www.paintcodeapp.com/examples
*/

+ (FKRBlockDrawingRenderBlock)simpleIconRenderBlock
{
    return ^(CGContextRef context, CGSize size) {
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* iconShadow = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.8];
        UIColor* baseColor = [UIColor colorWithRed: 0.156 green: 0.364 blue: 0.687 alpha: 1];
        CGFloat baseColorRGBA[4];
        [baseColor getRed: &baseColorRGBA[0] green: &baseColorRGBA[1] blue: &baseColorRGBA[2] alpha: &baseColorRGBA[3]];
        
        UIColor* baseGradientBottomColor = [UIColor colorWithRed: (baseColorRGBA[0] * 0.8) green: (baseColorRGBA[1] * 0.8) blue: (baseColorRGBA[2] * 0.8) alpha: (baseColorRGBA[3] * 0.8 + 0.2)];
        UIColor* strokeColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.23];
        UIColor* upperShine = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        UIColor* bottomShine = [upperShine colorWithAlphaComponent: 0.1];
        UIColor* topShine = [upperShine colorWithAlphaComponent: 0.9];
        
        //// Gradient Declarations
        NSArray* shineGradientColors = [NSArray arrayWithObjects:
                                        (id)topShine.CGColor,
                                        (id)[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.5].CGColor,
                                        (id)bottomShine.CGColor, nil];
        CGFloat shineGradientLocations[] = {0, 0.42, 1};
        CGGradientRef shineGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)shineGradientColors, shineGradientLocations);
        NSArray* baseGradientColors = [NSArray arrayWithObjects:
                                       (id)baseColor.CGColor,
                                       (id)baseGradientBottomColor.CGColor, nil];
        CGFloat baseGradientLocations[] = {0, 1};
        CGGradientRef baseGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)baseGradientColors, baseGradientLocations);
        
        //// Shadow Declarations
        UIColor* iconBottomShadow = iconShadow;
        CGSize iconBottomShadowOffset = CGSizeMake(0.1, 2.1);
        CGFloat iconBottomShadowBlurRadius = 4;
        UIColor* upperShineShadow = upperShine;
        CGSize upperShineShadowOffset = CGSizeMake(0.1, 1.1);
        CGFloat upperShineShadowBlurRadius = 1;
        
        //// ShadowGroup
        {
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, iconBottomShadowOffset, iconBottomShadowBlurRadius, iconBottomShadow.CGColor);
            
            CGContextSetBlendMode(context, kCGBlendModeMultiply);
            CGContextBeginTransparencyLayer(context, NULL);
            
            
            //// shadowRectangle Drawing
            UIBezierPath* shadowRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(6, 3, 57, 57) cornerRadius: 11];
            [baseColor setFill];
            [shadowRectanglePath fill];
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        
        //// Button
        {
            //// ButtonRectangle Drawing
            UIBezierPath* buttonRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(6, 3, 57, 57) cornerRadius: 11];
            CGContextSaveGState(context);
            [buttonRectanglePath addClip];
            CGContextDrawLinearGradient(context, baseGradient, CGPointMake(34.5, 3), CGPointMake(34.5, 60), 0);
            CGContextRestoreGState(context);
            
            ////// ButtonRectangle Inner Shadow
            CGRect buttonRectangleBorderRect = CGRectInset([buttonRectanglePath bounds], -upperShineShadowBlurRadius, -upperShineShadowBlurRadius);
            buttonRectangleBorderRect = CGRectOffset(buttonRectangleBorderRect, -upperShineShadowOffset.width, -upperShineShadowOffset.height);
            buttonRectangleBorderRect = CGRectInset(CGRectUnion(buttonRectangleBorderRect, [buttonRectanglePath bounds]), -1, -1);
            
            UIBezierPath* buttonRectangleNegativePath = [UIBezierPath bezierPathWithRect: buttonRectangleBorderRect];
            [buttonRectangleNegativePath appendPath: buttonRectanglePath];
            buttonRectangleNegativePath.usesEvenOddFillRule = YES;
            
            CGContextSaveGState(context);
            {
                CGFloat xOffset = upperShineShadowOffset.width + round(buttonRectangleBorderRect.size.width);
                CGFloat yOffset = upperShineShadowOffset.height;
                CGContextSetShadowWithColor(context,
                                            CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                            upperShineShadowBlurRadius,
                                            upperShineShadow.CGColor);
                
                [buttonRectanglePath addClip];
                CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(buttonRectangleBorderRect.size.width), 0);
                [buttonRectangleNegativePath applyTransform: transform];
                [[UIColor grayColor] setFill];
                [buttonRectangleNegativePath fill];
            }
            CGContextRestoreGState(context);
            
            [strokeColor setStroke];
            buttonRectanglePath.lineWidth = 1;
            [buttonRectanglePath stroke];
            
            
            //// UpperShinner
            {
                CGContextSaveGState(context);
                CGContextSetBlendMode(context, kCGBlendModeHardLight);
                CGContextBeginTransparencyLayer(context, NULL);
                
                
                //// UpperShinnyPart Drawing
                UIBezierPath* upperShinnyPartPath = [UIBezierPath bezierPath];
                [upperShinnyPartPath moveToPoint: CGPointMake(63, 17)];
                [upperShinnyPartPath addLineToPoint: CGPointMake(63, 27)];
                [upperShinnyPartPath addCurveToPoint: CGPointMake(35, 33) controlPoint1: CGPointMake(55, 32) controlPoint2: CGPointMake(45.03, 33)];
                [upperShinnyPartPath addCurveToPoint: CGPointMake(6, 27) controlPoint1: CGPointMake(26, 33) controlPoint2: CGPointMake(14, 32)];
                [upperShinnyPartPath addLineToPoint: CGPointMake(6, 17)];
                [upperShinnyPartPath addCurveToPoint: CGPointMake(17, 4) controlPoint1: CGPointMake(6, 7) controlPoint2: CGPointMake(11, 4)];
                [upperShinnyPartPath addLineToPoint: CGPointMake(52, 4)];
                [upperShinnyPartPath addCurveToPoint: CGPointMake(63, 17) controlPoint1: CGPointMake(58, 4) controlPoint2: CGPointMake(63, 7)];
                [upperShinnyPartPath closePath];
                CGContextSaveGState(context);
                [upperShinnyPartPath addClip];
                CGContextDrawLinearGradient(context, shineGradient, CGPointMake(34.5, 4), CGPointMake(34.5, 33), 0);
                CGContextRestoreGState(context);
                
                ////// UpperShinnyPart Inner Shadow
                CGRect upperShinnyPartBorderRect = CGRectInset([upperShinnyPartPath bounds], -upperShineShadowBlurRadius, -upperShineShadowBlurRadius);
                upperShinnyPartBorderRect = CGRectOffset(upperShinnyPartBorderRect, -upperShineShadowOffset.width, -upperShineShadowOffset.height);
                upperShinnyPartBorderRect = CGRectInset(CGRectUnion(upperShinnyPartBorderRect, [upperShinnyPartPath bounds]), -1, -1);
                
                UIBezierPath* upperShinnyPartNegativePath = [UIBezierPath bezierPathWithRect: upperShinnyPartBorderRect];
                [upperShinnyPartNegativePath appendPath: upperShinnyPartPath];
                upperShinnyPartNegativePath.usesEvenOddFillRule = YES;
                
                CGContextSaveGState(context);
                {
                    CGFloat xOffset = upperShineShadowOffset.width + round(upperShinnyPartBorderRect.size.width);
                    CGFloat yOffset = upperShineShadowOffset.height;
                    CGContextSetShadowWithColor(context,
                                                CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                                upperShineShadowBlurRadius,
                                                upperShineShadow.CGColor);
                    
                    [upperShinnyPartPath addClip];
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(upperShinnyPartBorderRect.size.width), 0);
                    [upperShinnyPartNegativePath applyTransform: transform];
                    [[UIColor grayColor] setFill];
                    [upperShinnyPartNegativePath fill];
                }
                CGContextRestoreGState(context);
                
                
                
                CGContextEndTransparencyLayer(context);
                CGContextRestoreGState(context);
            }
        }
        
        
        //// Cleanup
        CGGradientRelease(shineGradient);
        CGGradientRelease(baseGradient);
        CGColorSpaceRelease(colorSpace);
    };
}

+ (FKRBlockDrawingRenderBlock)powerButtonRenderBlock
{
    return ^(CGContextRef context, CGSize size) {
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* symbolShadow = [UIColor colorWithRed: 0.496 green: 0.496 blue: 0.496 alpha: 1];
        UIColor* symbolONColor = [UIColor colorWithRed: 0.798 green: 0.949 blue: 1 alpha: 1];
        UIColor* backGroundColorTop = [UIColor colorWithRed: 0.769 green: 0.813 blue: 0.827 alpha: 1];
        CGFloat backGroundColorTopHSBA[4];
        [backGroundColorTop getHue: &backGroundColorTopHSBA[0] saturation: &backGroundColorTopHSBA[1] brightness: &backGroundColorTopHSBA[2] alpha: &backGroundColorTopHSBA[3]];
        
        UIColor* backGroundColorBottom = [UIColor colorWithHue: backGroundColorTopHSBA[0] saturation: 0.154 brightness: backGroundColorTopHSBA[2] alpha: backGroundColorTopHSBA[3]];
        UIColor* smallShadowColor = [UIColor colorWithRed: 0.296 green: 0.296 blue: 0.296 alpha: 1];
        UIColor* testColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
        UIColor* baseColor2 = [UIColor colorWithRed: 0.26 green: 0.451 blue: 0.745 alpha: 1];
        CGFloat baseColor2RGBA[4];
        [baseColor2 getRed: &baseColor2RGBA[0] green: &baseColor2RGBA[1] blue: &baseColor2RGBA[2] alpha: &baseColor2RGBA[3]];
        
        CGFloat baseColor2HSBA[4];
        [baseColor2 getHue: &baseColor2HSBA[0] saturation: &baseColor2HSBA[1] brightness: &baseColor2HSBA[2] alpha: &baseColor2HSBA[3]];
        
        UIColor* bottomColor2 = [UIColor colorWithHue: baseColor2HSBA[0] saturation: baseColor2HSBA[1] brightness: 0.8 alpha: baseColor2HSBA[3]];
        CGFloat bottomColor2RGBA[4];
        [bottomColor2 getRed: &bottomColor2RGBA[0] green: &bottomColor2RGBA[1] blue: &bottomColor2RGBA[2] alpha: &bottomColor2RGBA[3]];
        
        UIColor* bottomOutColor2 = [UIColor colorWithRed: (bottomColor2RGBA[0] * 0.9) green: (bottomColor2RGBA[1] * 0.9) blue: (bottomColor2RGBA[2] * 0.9) alpha: (bottomColor2RGBA[3] * 0.9 + 0.1)];
        UIColor* topColor2 = [UIColor colorWithRed: (baseColor2RGBA[0] * 0.2 + 0.8) green: (baseColor2RGBA[1] * 0.2 + 0.8) blue: (baseColor2RGBA[2] * 0.2 + 0.8) alpha: (baseColor2RGBA[3] * 0.2 + 0.8)];
        CGFloat topColor2RGBA[4];
        [topColor2 getRed: &topColor2RGBA[0] green: &topColor2RGBA[1] blue: &topColor2RGBA[2] alpha: &topColor2RGBA[3]];
        
        UIColor* topOutColor2 = [UIColor colorWithRed: (topColor2RGBA[0] * 0 + 1) green: (topColor2RGBA[1] * 0 + 1) blue: (topColor2RGBA[2] * 0 + 1) alpha: (topColor2RGBA[3] * 0 + 1)];
        
        //// Gradient Declarations
        NSArray* backgroundGradientColors = [NSArray arrayWithObjects:
                                             (id)backGroundColorTop.CGColor,
                                             (id)backGroundColorBottom.CGColor, nil];
        CGFloat backgroundGradientLocations[] = {0, 1};
        CGGradientRef backgroundGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)backgroundGradientColors, backgroundGradientLocations);
        NSArray* buttonOutGradient2Colors = [NSArray arrayWithObjects:
                                             (id)bottomOutColor2.CGColor,
                                             (id)[UIColor colorWithRed: 0.625 green: 0.718 blue: 0.86 alpha: 1].CGColor,
                                             (id)topOutColor2.CGColor, nil];
        CGFloat buttonOutGradient2Locations[] = {0, 0.69, 1};
        CGGradientRef buttonOutGradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonOutGradient2Colors, buttonOutGradient2Locations);
        NSArray* buttonGradient2Colors = [NSArray arrayWithObjects:
                                          (id)bottomColor2.CGColor,
                                          (id)topColor2.CGColor, nil];
        CGFloat buttonGradient2Locations[] = {0, 1};
        CGGradientRef buttonGradient2 = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonGradient2Colors, buttonGradient2Locations);
        
        //// Shadow Declarations
        UIColor* shadow = symbolShadow;
        CGSize shadowOffset = CGSizeMake(0.1, 210.1);
        CGFloat shadowBlurRadius = 15;
        UIColor* glow = symbolONColor;
        CGSize glowOffset = CGSizeMake(0.1, -0.1);
        CGFloat glowBlurRadius = 7.5;
        UIColor* smallShadow = smallShadowColor;
        CGSize smallShadowOffset = CGSizeMake(0.1, 3.1);
        CGFloat smallShadowBlurRadius = 5.5;
        
        //// Frames
        CGRect frame = CGRectMake(60, 56, 120, 130);
        
        //// Subframes
        CGRect symbol = CGRectMake(CGRectGetMinX(frame) + 39, CGRectGetMinY(frame) + 35, CGRectGetWidth(frame) - 77, CGRectGetHeight(frame) - 85);
        
        
        //// BackgroundGroup
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.38);
            CGContextBeginTransparencyLayer(context, NULL);
            
            
            //// background Drawing
            UIBezierPath* backgroundPath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 250, 240)];
            CGContextSaveGState(context);
            [backgroundPath addClip];
            CGContextDrawLinearGradient(context, backgroundGradient, CGPointMake(125, 0), CGPointMake(125, 240), 0);
            CGContextRestoreGState(context);
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        
        //// GroupShadow
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, 0.75);
            CGContextSetBlendMode(context, kCGBlendModeMultiply);
            CGContextBeginTransparencyLayer(context, NULL);
            
            
            //// LongShadow Drawing
            UIBezierPath* longShadowPath = [UIBezierPath bezierPath];
            [longShadowPath moveToPoint: CGPointMake(118.79, -35.94)];
            [longShadowPath addCurveToPoint: CGPointMake(154.83, -115.47) controlPoint1: CGPointMake(165.69, -35.51) controlPoint2: CGPointMake(168.82, -95.54)];
            [longShadowPath addCurveToPoint: CGPointMake(118.79, -135.24) controlPoint1: CGPointMake(151.21, -120.63) controlPoint2: CGPointMake(143.49, -135.41)];
            [longShadowPath addCurveToPoint: CGPointMake(83.82, -115.47) controlPoint1: CGPointMake(94.73, -135.08) controlPoint2: CGPointMake(86.78, -120.84)];
            [longShadowPath addCurveToPoint: CGPointMake(118.79, -35.94) controlPoint1: CGPointMake(71.99, -93.99) controlPoint2: CGPointMake(75.59, -36.33)];
            [longShadowPath closePath];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
            [baseColor2 setFill];
            [longShadowPath fill];
            CGContextRestoreGState(context);
            
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        
        //// outerRing Drawing
        CGRect outerRingRect = CGRectMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 13.5, CGRectGetWidth(frame) - 31, CGRectGetHeight(frame) - 41);
        UIBezierPath* outerRingPath = [UIBezierPath bezierPathWithOvalInRect: outerRingRect];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, smallShadowOffset, smallShadowBlurRadius, smallShadow.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        [outerRingPath addClip];
        CGContextDrawLinearGradient(context, buttonOutGradient2,
                                    CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMaxY(outerRingRect)),
                                    CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMinY(outerRingRect)),
                                    0);
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
        
        
        
        //// innerRing Drawing
        CGRect innerRingRect = CGRectMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 16.5, CGRectGetWidth(frame) - 37, CGRectGetHeight(frame) - 47);
        UIBezierPath* innerRingPath = [UIBezierPath bezierPathWithOvalInRect: innerRingRect];
        CGContextSaveGState(context);
        [innerRingPath addClip];
        CGContextDrawLinearGradient(context, buttonGradient2,
                                    CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMaxY(innerRingRect)),
                                    CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMinY(innerRingRect)),
                                    0);
        CGContextRestoreGState(context);
        
        
        //// Symbol
        {
            //// symbolON Drawing
            UIBezierPath* symbolONPath = [UIBezierPath bezierPath];
            [symbolONPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50194 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04446 * CGRectGetHeight(symbol))];
            [symbolONPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.49855 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04445 * CGRectGetHeight(symbol))];
            [symbolONPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50194 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04446 * CGRectGetHeight(symbol))];
            [symbolONPath closePath];
            [symbolONPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.86006 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 1.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.37097 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 1.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.67348 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.14645 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.86006 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.65829 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 1.04665 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.34171 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 1.04665 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.14645 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + -0.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.67348 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + -0.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.37097 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.25581 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18889 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.17353 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.16157 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.22375 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.16086 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.26156 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.29438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.28788 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.21692 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.28490 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.27238 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.26156 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.75007 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.12987 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.42021 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.12987 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.62423 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.75007 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.39325 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.87590 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.60675 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.87590 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.29438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.87013 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.62423 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.87013 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.42021 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.70569 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.26272 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.70967 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.21188 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.76722 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.15688 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.83173 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.15986 * CGRectGetHeight(symbol))];
            [symbolONPath closePath];
            [symbolONPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50000 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.56518 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.45505 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.54495 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.56518 * CGRectGetHeight(symbol))];
            [symbolONPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.07778 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50000 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.03482 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.54495 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol))];
            [symbolONPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.07778 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.45505 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.03482 * CGRectGetHeight(symbol))];
            [symbolONPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol))];
            [symbolONPath closePath];
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, glowOffset, glowBlurRadius, glow.CGColor);
            [testColor setFill];
            [symbolONPath fill];
            CGContextRestoreGState(context);
            
        }
        
        
        //// Cleanup
        CGGradientRelease(backgroundGradient);
        CGGradientRelease(buttonOutGradient2);
        CGGradientRelease(buttonGradient2);
        CGColorSpaceRelease(colorSpace);
    };
}

+ (FKRBlockDrawingRenderBlock)blueButtonRenderBlock
{
    return ^(CGContextRef context, CGSize size) {
        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* upColorOut = [UIColor colorWithRed: 0.748 green: 0.748 blue: 0.748 alpha: 1];
        UIColor* bottomColorDown = [UIColor colorWithRed: 0.16 green: 0.16 blue: 0.16 alpha: 1];
        UIColor* upColorInner = [UIColor colorWithRed: 0.129 green: 0.132 blue: 0.148 alpha: 1];
        UIColor* bottomColorInner = [UIColor colorWithRed: 0.975 green: 0.975 blue: 0.985 alpha: 1];
        UIColor* buttonColor = [UIColor colorWithRed: 0 green: 0.272 blue: 0.883 alpha: 1];
        CGFloat buttonColorRGBA[4];
        [buttonColor getRed: &buttonColorRGBA[0] green: &buttonColorRGBA[1] blue: &buttonColorRGBA[2] alpha: &buttonColorRGBA[3]];
        
        UIColor* buttonTopColor = [UIColor colorWithRed: (buttonColorRGBA[0] * 0.8) green: (buttonColorRGBA[1] * 0.8) blue: (buttonColorRGBA[2] * 0.8) alpha: (buttonColorRGBA[3] * 0.8 + 0.2)];
        UIColor* buttonBottomColor = [UIColor colorWithRed: (buttonColorRGBA[0] * 0 + 1) green: (buttonColorRGBA[1] * 0 + 1) blue: (buttonColorRGBA[2] * 0 + 1) alpha: (buttonColorRGBA[3] * 0 + 1)];
        UIColor* buttonFlareUpColor = [UIColor colorWithRed: (buttonColorRGBA[0] * 0.3 + 0.7) green: (buttonColorRGBA[1] * 0.3 + 0.7) blue: (buttonColorRGBA[2] * 0.3 + 0.7) alpha: (buttonColorRGBA[3] * 0.3 + 0.7)];
        UIColor* buttonFlareBottomColor = [UIColor colorWithRed: (buttonColorRGBA[0] * 0.8 + 0.2) green: (buttonColorRGBA[1] * 0.8 + 0.2) blue: (buttonColorRGBA[2] * 0.8 + 0.2) alpha: (buttonColorRGBA[3] * 0.8 + 0.2)];
        UIColor* flareWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.83];
        
        //// Gradient Declarations
        NSArray* ringGradientColors = [NSArray arrayWithObjects:
                                       (id)upColorOut.CGColor,
                                       (id)bottomColorDown.CGColor, nil];
        CGFloat ringGradientLocations[] = {0, 1};
        CGGradientRef ringGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)ringGradientColors, ringGradientLocations);
        NSArray* ringInnerGradientColors = [NSArray arrayWithObjects:
                                            (id)upColorInner.CGColor,
                                            (id)bottomColorInner.CGColor, nil];
        CGFloat ringInnerGradientLocations[] = {0, 1};
        CGGradientRef ringInnerGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)ringInnerGradientColors, ringInnerGradientLocations);
        NSArray* buttonGradientColors = [NSArray arrayWithObjects:
                                         (id)buttonBottomColor.CGColor,
                                         (id)buttonTopColor.CGColor, nil];
        CGFloat buttonGradientLocations[] = {0, 1};
        CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonGradientColors, buttonGradientLocations);
        NSArray* overlayGradientColors = [NSArray arrayWithObjects:
                                          (id)flareWhite.CGColor,
                                          (id)[UIColor clearColor].CGColor, nil];
        CGFloat overlayGradientLocations[] = {0, 1};
        CGGradientRef overlayGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)overlayGradientColors, overlayGradientLocations);
        NSArray* buttonFlareGradientColors = [NSArray arrayWithObjects:
                                              (id)buttonFlareUpColor.CGColor,
                                              (id)buttonFlareBottomColor.CGColor, nil];
        CGFloat buttonFlareGradientLocations[] = {0, 1};
        CGGradientRef buttonFlareGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonFlareGradientColors, buttonFlareGradientLocations);
        
        //// Shadow Declarations
        UIColor* buttonInnerShadow = [UIColor blackColor];
        CGSize buttonInnerShadowOffset = CGSizeMake(0.1, -0.1);
        CGFloat buttonInnerShadowBlurRadius = 5;
        UIColor* buttonOuterShadow = [UIColor blackColor];
        CGSize buttonOuterShadowOffset = CGSizeMake(0.1, 2.1);
        CGFloat buttonOuterShadowBlurRadius = 5;
        
        //// outerOval Drawing
        UIBezierPath* outerOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(87, 29, 63, 63)];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, buttonOuterShadowOffset, buttonOuterShadowBlurRadius, buttonOuterShadow.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        [outerOvalPath addClip];
        CGContextDrawLinearGradient(context, ringGradient, CGPointMake(118.5, 29), CGPointMake(118.5, 92), 0);
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
        
        
        
        //// overlayOval Drawing
        UIBezierPath* overlayOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(87, 29, 63, 63)];
        CGContextSaveGState(context);
        [overlayOvalPath addClip];
        CGContextDrawRadialGradient(context, overlayGradient,
                                    CGPointMake(118.5, 36.23), 17.75,
                                    CGPointMake(118.5, 60.5), 44.61,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        
        //// innerOval Drawing
        UIBezierPath* innerOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(94, 36, 49, 49)];
        CGContextSaveGState(context);
        [innerOvalPath addClip];
        CGContextDrawLinearGradient(context, ringInnerGradient, CGPointMake(118.5, 36), CGPointMake(118.5, 85), 0);
        CGContextRestoreGState(context);
        
        
        //// buttonOval Drawing
        UIBezierPath* buttonOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(96, 37, 46, 46)];
        CGContextSaveGState(context);
        [buttonOvalPath addClip];
        CGContextDrawRadialGradient(context, buttonGradient,
                                    CGPointMake(119, 87.23), 2.44,
                                    CGPointMake(119, 68.48), 23.14,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
        CGContextRestoreGState(context);
        
        ////// buttonOval Inner Shadow
        CGRect buttonOvalBorderRect = CGRectInset([buttonOvalPath bounds], -buttonInnerShadowBlurRadius, -buttonInnerShadowBlurRadius);
        buttonOvalBorderRect = CGRectOffset(buttonOvalBorderRect, -buttonInnerShadowOffset.width, -buttonInnerShadowOffset.height);
        buttonOvalBorderRect = CGRectInset(CGRectUnion(buttonOvalBorderRect, [buttonOvalPath bounds]), -1, -1);
        
        UIBezierPath* buttonOvalNegativePath = [UIBezierPath bezierPathWithRect: buttonOvalBorderRect];
        [buttonOvalNegativePath appendPath: buttonOvalPath];
        buttonOvalNegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = buttonInnerShadowOffset.width + round(buttonOvalBorderRect.size.width);
            CGFloat yOffset = buttonInnerShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        buttonInnerShadowBlurRadius,
                                        buttonInnerShadow.CGColor);
            
            [buttonOvalPath addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(buttonOvalBorderRect.size.width), 0);
            [buttonOvalNegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [buttonOvalNegativePath fill];
        }
        CGContextRestoreGState(context);
        
        
        
        //// flareOval Drawing
        UIBezierPath* flareOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(104, 38, 29, 15)];
        CGContextSaveGState(context);
        [flareOvalPath addClip];
        CGContextDrawLinearGradient(context, buttonFlareGradient, CGPointMake(118.5, 38), CGPointMake(118.5, 53), 0);
        CGContextRestoreGState(context);
        
        
        //// Cleanup
        CGGradientRelease(ringGradient);
        CGGradientRelease(ringInnerGradient);
        CGGradientRelease(buttonGradient);
        CGGradientRelease(overlayGradient);
        CGGradientRelease(buttonFlareGradient);
        CGColorSpaceRelease(colorSpace);
    };
}

@end