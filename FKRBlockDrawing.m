//
//  FKRBlockDrawing.m
//  FKRBlockDrawing
//
//  Created by Fabian Kreiser on 12.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "FKRBlockDrawing.h"

/*
 FKRBlockDrawingView
*/

@interface FKRBlockDrawingView () {
    
}

@property(nonatomic, copy) FKRBlockDrawingRenderBlock renderBlock;

@end

@implementation FKRBlockDrawingView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame renderBlock:^(CGContextRef context, CGSize size) {
        
    }];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder])) {
        self.contentMode = UIViewContentModeRedraw;
        
        _renderBlock = [^(CGContextRef context, CGSize size) {
            
        } copy];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame renderBlock:(FKRBlockDrawingRenderBlock)renderBlock
{
    NSParameterAssert(renderBlock != NULL);
    
    if ((self = [super initWithFrame:frame])) {
        self.contentMode = UIViewContentModeRedraw;
        
        _renderBlock = [renderBlock copy];
    }
    
    return self;
}

- (void)setNeedsDisplayWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock
{
    NSParameterAssert(renderBlock != NULL);
    
    self.renderBlock = renderBlock;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize size = self.bounds.size;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.renderBlock(context, size);
}

@end

/*
 UIImage+FKRBlockDrawing
*/

@implementation UIImage (FKRBlockDrawing)

+ (instancetype)imageWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock size:(CGSize)size
{
    return [self imageWithRenderBlock:renderBlock size:size opaque:NO scale:0];
}

+ (instancetype)imageWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock size:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale
{
    NSParameterAssert(renderBlock != NULL);
    NSParameterAssert(size.width <= 1024 && size.height <= 1024);
    NSParameterAssert(scale >= 0);
    
    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    UIGraphicsPushContext(context);
	renderBlock(context, size);
	UIGraphicsPopContext();
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return image;
}

@end

/*
 FKRBlockDrawingLayer
*/

@implementation FKRBlockDrawingLayer
@dynamic renderBlock;

+ (instancetype)layerWithRenderBlock:(FKRBlockDrawingRenderBlock)renderBlock
{
    NSParameterAssert(renderBlock != NULL);
    
    id layer = [self layer];
    [(FKRBlockDrawingLayer *)layer setRenderBlock:renderBlock];
    
    return layer;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"renderBlock"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

+ (id)defaultValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"renderBlock"]) {
        return [^(CGContextRef context, CGSize size) {
            
        } copy];
    } else {
        return [super defaultValueForKey:key];
    }
}

+ (id <CAAction>)defaultActionForKey:(NSString *)event
{
    if ([event isEqualToString:@"renderBlock"]) {
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        
        return transition;
    } else {
        return [super defaultActionForKey:event];
    }
}

- (id)init
{
    if ((self = [super init])) {
        self.needsDisplayOnBoundsChange = YES;
        self.renderBlock = ^(CGContextRef context, CGSize size) {
            
        };
    }
    
    return self;
}

- (id)initWithLayer:(id)layer
{
    if ((self = [super initWithLayer:layer])) {
        self.needsDisplayOnBoundsChange = YES;
        
        if ([layer isKindOfClass:[FKRBlockDrawingLayer class]]) {
            self.renderBlock = [(FKRBlockDrawingLayer *)layer renderBlock];
        } else {
            self.renderBlock = ^(CGContextRef context, CGSize size) {
                
            };
        }
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    self.renderBlock(context, self.bounds.size);
    UIGraphicsPopContext();
}

@end