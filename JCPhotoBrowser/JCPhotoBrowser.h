//
//  JCPhotoBrowser.h
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCPhotoItem.h"

typedef NS_ENUM(NSUInteger, JCPhotoBrowserInteractiveDismissalStyle) {
    JCPhotoBrowserInteractiveDismissalStyleSlide,
    JCPhotoBrowserInteractiveDismissalStyleScale,
    JCPhotoBrowserInteractiveDismissalStyleNone
};

typedef NS_ENUM(NSUInteger, JCPhotoBrowserPageIndicatorStyle) {
    JCPhotoBrowserPageIndicatorStyleDot,
    JCPhotoBrowserPageIndicatorStyleText
};

typedef NS_ENUM(NSUInteger, JCPhotoBrowserImageLoadingStyle) {
    JCPhotoBrowserImageLoadingStyleDeterminate,
    JCPhotoBrowserImageLoadingStyleIndeterminate
};

@interface JCPhotoBrowser : UIViewController

@property (nonatomic, assign) JCPhotoBrowserInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign) JCPhotoBrowserPageIndicatorStyle pageindicatorStyle;
@property (nonatomic, assign) JCPhotoBrowserImageLoadingStyle loadingStyle;

+ (instancetype)browserWithPhotoItems:(NSArray<JCPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;
- (instancetype)initWithPhotoItems:(NSArray<JCPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex;
- (void)showFromViewController:(UIViewController *)vc;

@end
