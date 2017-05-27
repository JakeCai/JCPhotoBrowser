//
//  JCPhotoItem.m
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import "JCPhotoItem.h"

@interface JCPhotoItem ()

@property (nonatomic, strong, readwrite) UIView *sourceView;

@property (nonatomic, strong, readwrite) UIImage *thumbImage;

@property (nonatomic, strong, readwrite) UIImage *image;

@property (nonatomic, strong, readwrite) NSURL *imageUrl;

@end

@implementation JCPhotoItem

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = url;
    }
    return self;
}

- (instancetype)initWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url {
    return [self initWithSourceView:view
                         thumbImage:view.image
                           imageUrl:url];
}

- (instancetype)initWithSourceView:(UIImageView *)view
                             image:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIView *)view
                         thumbImage:(UIImage *)image
                           imageUrl:(NSURL *)url {
    return [[JCPhotoItem alloc] initWithSourceView:view
                                    thumbImage:image
                                      imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                           imageUrl:(NSURL *)url {
    return [[JCPhotoItem alloc] initWithSourceView:view
                                      imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *)view
                              image:(UIImage *)image {
    return [[JCPhotoItem alloc] initWithSourceView:view
                                         image:image];
}

@end
