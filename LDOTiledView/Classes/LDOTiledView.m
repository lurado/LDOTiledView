//
//  LDOTiledView.m
//  LDOTiledView
//
//  Created by Sebastian Ludwig on 29.01.18.
//  Copyright (c) 2017 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

#import "LDOTiledView.h"
#import "LDOTiledLayer.h"

@interface LDOTiledView ()

@property (nonatomic, readonly) LDOTiledLayer *tiledLayer;

@end

@implementation LDOTiledView

+ (CGFloat)zoomScaleForZoomLevel:(CGFloat)zoomLevel
{
    // zoom levels are 1, 2, 3, 4, 5, ... -> UIScrollView.[max]zoomScale needs to be 1, 2, 4, 8, 16, ...
    return pow(2, zoomLevel - 1);
}

+ (CGFloat)zoomLevelForZoomScale:(CGFloat)zoomScale
{
    // zoomScale is 1, 2, 4, 8, ... -> zoom levels are 1, 2, 3, 4, ...
    return log2(zoomScale) + 1;
}

+ (Class)layerClass
{
    return [LDOTiledLayer class];
}

- (instancetype)init
{
    if (self = [super init]) {
        // use the setter to also adjust the layer scale
        self.tileSize = CGSizeMake(256, 256);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // use the setter to also adjust the layer scale
        self.tileSize = CGSizeMake(256, 256);
    }
    return self;
}

- (LDOTiledLayer *)tiledLayer
{
    return (LDOTiledLayer *)self.layer;
}

- (CGSize)intrinsicContentSize
{
    return self.imageSize;
}

- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)setTileSize:(CGSize)tileSize
{
    _tileSize = tileSize;
    
    // CATiledLayer.tileSize is in pixels/physical coordinate space -> it needs to be scaled
    CGFloat scale = self.tiledLayer.contentsScale;
    self.tiledLayer.tileSize = CGSizeMake(tileSize.width * scale, tileSize.height * scale);
}

- (size_t)maximumZoomLevel
{
    return self.tiledLayer.levelsOfDetail;
}

- (void)setMaximumZoomLevel:(size_t)maximumZoomLevel
{
    size_t levels = MAX(1, maximumZoomLevel);
    self.tiledLayer.levelsOfDetail = levels;
    self.tiledLayer.levelsOfDetailBias = levels - 1;
}

- (CGFloat)maximumZoomScale
{
    return [[self class] zoomScaleForZoomLevel:self.maximumZoomLevel];
}

- (void)setMaximumZoomScale:(CGFloat)maximumZoomScale
{
    self.maximumZoomLevel = [[self class] zoomLevelForZoomScale:maximumZoomScale];
}

- (void)setDebugAnnotateTiles:(BOOL)debugAnnotateTiles
{
    _debugAnnotateTiles = debugAnnotateTiles;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // on non-retina devices contentScale is 1 if not zoomed, 2 if zoomed one level, 4 if zoomed two levels, ...
    // on retina devices it's 2 if not zoomed, 4 if zoomed one level, 8 if zoomed two levels, ...
    CGFloat contentScale = CGContextGetCTM(context).a;
    NSInteger normalizedContentScale = contentScale / [UIScreen mainScreen].scale;
    
    // rect in logical coordinates (points)
    CGRect normalizedRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(normalizedContentScale, normalizedContentScale));
    
    NSInteger col = round(normalizedRect.origin.x / self.tileSize.width);
    NSInteger row = round(normalizedRect.origin.y / self.tileSize.height);
    
    CGFloat zoomLevel = [[self class] zoomLevelForZoomScale:normalizedContentScale];
    
    UIImage *tileImage = [self.dataSource tiledView:self tileForRow:row column:col zoomLevel:zoomLevel];
    [tileImage drawInRect:rect];
    
    if (self.debugAnnotateTiles) {
        [self annotateRect:rect col:col row:row zoomLevel:zoomLevel scale:normalizedContentScale context:context];
    }
}

- (void)annotateRect:(CGRect)rect col:(NSInteger)col row:(NSInteger)row zoomLevel:(NSInteger)zoomLevel scale:(NSInteger)scale context:(CGContextRef)context
{
    CGFloat lineWidth = 2.0 / scale;
    CGFloat halfLineWidth = lineWidth / 2;
    CGFloat fontSize = 12.0 / scale;
    
    NSString *pointString = [NSString stringWithFormat:@"%@x(%@, %@) @%@x", @(zoomLevel), @(col), @(row), @([UIScreen mainScreen].scale)];
    CGPoint textOrigin = CGPointMake(CGRectGetMinX(rect) + lineWidth, CGRectGetMinY(rect) + lineWidth);
    [pointString drawAtPoint:textOrigin withAttributes:@{
                                                         NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
                                                         NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                                         }];
    
    
    [[UIColor redColor] set];
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokeRect(context, CGRectInset(rect, halfLineWidth, halfLineWidth));
}

@end
