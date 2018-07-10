//
//  JCPhotoView.h
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCProgressLayer.h"

extern const CGFloat kJCPhotoViewPadding;

@class JCPhotoItem;

@interface JCPhotoView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) JCProgressLayer *progressLayer;
@property (nonatomic, strong) JCPhotoItem *item;

- (void)setItem:(JCPhotoItem *)item determinate:(BOOL)determinate;

- (void)resizeImageView;

- (void)cancelCurrentImageLoad;

@end
