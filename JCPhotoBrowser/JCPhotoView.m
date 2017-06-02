//
//  JCPhotoView.m
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import "JCPhotoView.h"
#import "JCPhotoItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JCProgressLayer.h"

const CGFloat kJCPhotoViewPadding = 10;
const CGFloat kJCPhotoViewMaxScale = 3;

@interface JCPhotoView ()<UIScrollViewDelegate>


@end

@implementation JCPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = kJCPhotoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor darkGrayColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        self.progressLayer = [[JCProgressLayer alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.progressLayer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.progressLayer.hidden = YES;
        [self.layer addSublayer:_progressLayer];
    }
    return self;
}

- (void)setItem:(JCPhotoItem *)item determinate:(BOOL)determinate {
    _item = item;
    [_imageView sd_cancelCurrentAnimationImagesLoad];
    if (item) {
        if (item.image) {
            _imageView.image = item.image;
            _item.finished = YES;
            [_progressLayer stopSpin];
            _progressLayer.hidden = YES;
            [self resizeImageView];
            return;
        }
        __weak typeof(self) wself = self;
        SDWebImageDownloaderProgressBlock progressBlock = nil;
        if (determinate) {
            progressBlock = ^(NSInteger receivedSize,
                              NSInteger expectedSize,
                              NSURL * _Nullable targetURL) {
                __strong typeof(wself) sself = wself;
                CGFloat progress = (CGFloat)receivedSize / expectedSize;
                sself.progressLayer.hidden = NO;
                sself.progressLayer.progress = MAX(progress, 0.01);
            };
        } else {
            [_progressLayer startSpin];
        }
        _progressLayer.hidden = NO;
        
        _imageView.image = item.thumbImage;
        [_imageView sd_setImageWithURL:item.imageUrl
                      placeholderImage:item.thumbImage
                               options:SDWebImageRetryFailed
                              progress:progressBlock
                             completed:^(UIImage * _Nullable image,
                                         NSError * _Nullable error,
                                         SDImageCacheType cacheType,
                                         NSURL * _Nullable imageURL) {
                                 __strong typeof(wself) sself = wself;
                                 if (!error) {
                                     [sself resizeImageView];
                                 }
                                 [sself.progressLayer stopSpin];
                                 sself.progressLayer.hidden = YES;
                                 sself.item.finished = YES;
                             }];
    } else {
        [_progressLayer stopSpin];
        _progressLayer.hidden = YES;
        _imageView.image = nil;
    }
    [self resizeImageView];
}

- (void)resizeImageView {
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        
        //若图片太高，显示最上面的内容
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // 若图片太大，需要保证能够全屏缩放
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * kJCPhotoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.contentSize = _imageView.frame.size;
}

- (void)cancelCurrentImageLoad {
    [_imageView sd_cancelCurrentAnimationImagesLoad];
    [_progressLayer stopSpin];
}

#pragma mark - ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
