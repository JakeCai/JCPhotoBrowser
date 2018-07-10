//
//  JCProgressLayer.h
//  JCPhotoBrowser
//
//  Created by Jake Cai on 30/12/2016.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCProgressLayer : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;

- (void)startSpin;

- (void)stopSpin;

@property (nonatomic, assign) CGFloat progress;

@end
