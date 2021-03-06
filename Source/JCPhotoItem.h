//
//  JCPhotoItem.h
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCPhotoItem : NSObject

@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;

- (instancetype)initWithSourceView:(UIView *)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView *)view
                          imageUrl:(NSURL *)url;
- (instancetype)initWithSourceView:(UIImageView *)view
                             image:(UIImage *)image;

+ (instancetype)itemWithSourceView:(UIView *)view
                         thumbImage:(UIImage *)image
                           imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                           imageUrl:(NSURL *)url;
+ (instancetype)itemWithSourceView:(UIImageView *)view
                              image:(UIImage *)image;

@end
