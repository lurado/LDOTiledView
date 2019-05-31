//
//  LDOTiledView.h
//  LDOTiledView
//
//  Created by Sebastian Ludwig on 29.01.18.
//  Copyright (c) 2017 Julian Raschke und Sebastian Ludwig GbR. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LDOTiledView;

@protocol LDOTiledViewDataSource
// Be careful: will be called on background threads!
- (nullable UIImage *)tiledView:(nonnull LDOTiledView *)tiledView tileForRow:(NSInteger)row column:(NSInteger)column zoomLevel:(NSInteger)zoomLevel;
@end

@interface LDOTiledView : UIView

// zoom levels are 1, 2, 3, 4, 5, ... -> UIScrollView.[max]zoomScale needs to be 1, 2, 4, 8, 16, ...
+ (CGFloat)zoomScaleForZoomLevel:(CGFloat)zoomLevel;
// zoomScale is 1, 2, 4, 8, ... -> zoom levels are 1, 2, 3, 4, ...
+ (CGFloat)zoomLevelForZoomScale:(CGFloat)zoomScale;

@property (nullable, nonatomic, weak) IBOutlet id<LDOTiledViewDataSource> dataSource;
@property (nonatomic) CGSize imageSize;   // in points
@property (nonatomic) CGSize tileSize;    // logical coordinate space (points), default 256x256
@property (nonatomic) size_t maximumZoomLevel;  // zoom levels are 1 based (1, 2, 3, ...) and each level doubles the size
@property (nonatomic) CGFloat maximumZoomScale; // zoom scale needs to double, to double the size (1, 2, 4, 8, ...)

@property (nonatomic) BOOL debugAnnotateTiles;

@end
