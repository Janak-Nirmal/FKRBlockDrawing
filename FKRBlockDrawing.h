//
//  FKRBlockDrawing.h
//  FKRBlockDrawing
//
//  Created by Fabian Kreiser on 12.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

/*
 Compatibility: FKRBlockDrawing requires iOS 4.0 or later and the QuartzCore framework.
 FKRBlockDrawing works with both automatic reference counting (ARC) and manual reference counting.
*/

// The typical type of blocks used for rendering
typedef void(^FKRBlockDrawingRenderBlock)(CGContextRef context, CGSize size);

/*
 FKRBlockDrawingView
*/

@interface FKRBlockDrawingView : UIView {
    
}


// Designated initializer. renderBlock must not be NULL!
- (id)initWithFrame:(CGRect)frame renderBlock:(FKRBlockDrawingRenderBlock)renderBlock;

// You can use this method to pass a new render block. renderBlock must not be NULL!
- (void)setNeedsDisplayWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock;

@end

/*
 UIImage+FKRBlockDrawing
*/

@interface UIImage (FKRBlockDrawing)

// Returns a new non-opaque UIImage rendered using the renderBlock with the specified size and the device's preferred scale. Thread-safe. renderBlock must not be NULL and size must be equal or smaller to (1024, 1024).
+ (instancetype)imageWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock size:(CGSize)size; // the same as invoking +imageWithRenderBlock:size:opaque:scale with opaque = NO and scale = 0

// Returns a new UIImage rendered using the renderBlock with the specified size, opacity and scale. Thread-safe. renderBlock must not be NULL and size must be equal or smaller to (1024, 1024).
+ (instancetype)imageWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock size:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale;

@end

/*
 FKRBlockDrawingLayer
*/

@interface FKRBlockDrawingLayer : CALayer {
    
}

// Returns a new layer that uses the renderBlock to draw its content. renderBlock must not be NULL!
+ (instancetype)layerWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock;

// The render block used for drawing the layer's content. Animatable. Must not be NULL!
@property(nonatomic, copy) FKRBlockDrawingRenderBlock renderBlock;

@end