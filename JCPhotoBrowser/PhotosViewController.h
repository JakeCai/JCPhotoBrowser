//
//  PhotosViewController.h
//  JCPhotoBrowser
//
//  Created by Jake on 2018/7/10.
//  Copyright © 2018 Jake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JCPhotoBrowser.h"

@interface PhotosViewController : UIViewController

@property (nonatomic, assign) JCPhotoBrowserInteractiveDismissalStyle dismissalStyle;
@property (nonatomic, assign) JCPhotoBrowserImageLoadingStyle imageLoadingStyle;
@property (nonatomic, assign) JCPhotoBrowserPageIndicatorStyle pageIndicatorStyle;

@end
