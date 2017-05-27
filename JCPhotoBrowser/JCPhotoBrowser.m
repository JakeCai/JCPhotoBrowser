//
//  JCPhotoBrowser.m
//  JCPhotoBrowser
//
//  Created by Jake Cai on 12/25/16.
//  Copyright © 2016 Jake Cai. All rights reserved.
//

#import "JCPhotoView.h"
#import "UIImageView+WebCache.h"
//#import "UIImage+YYWebImage.h"
#import "JCPhotoBrowser.h"

static const NSTimeInterval kAnimationDuration = 0.3;
@interface JCPhotoBrowser () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate> {
    CGPoint _startLocation;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *photoItems;

@property (nonatomic, strong) NSMutableSet *reusableItemViews;

@property (nonatomic, strong) NSMutableArray *visibleItemViews;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UILabel *pageLabel;

@property (nonatomic, assign) BOOL presented;

@end

@implementation JCPhotoBrowser


+ (instancetype)browserWithPhotoItems:(NSArray<JCPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    JCPhotoBrowser *browser = [[JCPhotoBrowser alloc] initWithPhotoItems:photoItems selectedIndex:selectedIndex];
    return browser;
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithMediaItems: instead.");
    return nil;
}

- (instancetype)initWithPhotoItems:(NSArray<JCPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    self = [super init];
    if (self) {
        _photoItems = [NSMutableArray arrayWithArray:photoItems];
        _currentPage = selectedIndex;
        
        self.dismissalStyle = JCPhotoBrowserInteractiveDismissalStyleSlide;
        self.pageindicatorStyle = JCPhotoBrowserPageIndicatorStyleDot;
        self.loadingStyle = 0;
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _reusableItemViews = [NSMutableSet set];
        _visibleItemViews = [NSMutableArray array];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.alpha = 0;
    [self.view addSubview:_backgroundView];
    
    CGRect rect = self.view.bounds;
    rect.origin.x -= kJCPhotoViewPadding;
    rect.size.width += 2 * kJCPhotoViewPadding;
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (_pageindicatorStyle == JCPhotoBrowserPageIndicatorStyleDot) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
        _pageControl.numberOfPages = _photoItems.count;
        _pageControl.currentPage = _currentPage;
        [self.view addSubview:_pageControl];
    } else {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self configPageLabelWithPage:_currentPage];
        [self.view addSubview:_pageLabel];
    }
    
    CGSize contentSize = CGSizeMake(rect.size.width * _photoItems.count, rect.size.height);
    _scrollView.contentSize = contentSize;
    
    [self addGestureRecognizer];
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width*_currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:NO];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:item.imageUrl];
    
    if ([manager.imageCache imageFromMemoryCacheForKey:key]) {
        [self configPhotoView:photoView withItem:item];
    } else {
        photoView.imageView.image = item.thumbImage;
        [photoView resizeImageView];
    }
    
    CGRect endRect = photoView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    photoView.imageView.frame = sourceRect;

    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.frame = endRect;
        self.view.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [self configPhotoView:photoView withItem:item];
        _presented = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

- (void)dealloc {
    
}


- (void)showFromViewController:(UIViewController *)vc {
    [vc presentViewController:self animated:NO completion:nil];
}

#pragma mark - Private

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (JCPhotoView *)photoViewForPage:(NSUInteger)page {
    for (JCPhotoView *photoView in _visibleItemViews) {
        if (photoView.tag == page) {
            return photoView;
        }
    }
    return nil;
}

- (JCPhotoView *)dequeueReusableItemView {
    JCPhotoView *photoView = [_reusableItemViews anyObject];
    if (photoView == nil) {
        photoView = [[JCPhotoView alloc] initWithFrame:_scrollView.bounds];
    } else {
        [_reusableItemViews removeObject:photoView];
    }
    photoView.tag = -1;
    return photoView;
}

- (void)updateReusableItemViews {
    NSMutableArray *itemsForRemove = [NSMutableArray array];
    for (JCPhotoView *photoView in _visibleItemViews) {
        if (photoView.frame.origin.x + photoView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width ||
            photoView.frame.origin.x > _scrollView.contentOffset.x + 2 * _scrollView.frame.size.width) {
            [photoView removeFromSuperview];
            [self configPhotoView:photoView withItem:nil];
            [itemsForRemove addObject:photoView];
            [_reusableItemViews addObject:photoView];
        }
    }
    [_visibleItemViews removeObjectsInArray:itemsForRemove];
}

- (void)configItemViews {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= _photoItems.count) {
            continue;
        }
        JCPhotoView *photoView = [self photoViewForPage:i];
        if (photoView == nil) {
            photoView = [self dequeueReusableItemView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoView.frame = rect;
            photoView.tag = i;
            [_scrollView addSubview:photoView];
            [_visibleItemViews addObject:photoView];
        }
        if (photoView.item == nil && _presented) {
            JCPhotoItem *item = [_photoItems objectAtIndex:i];
            [self configPhotoView:photoView withItem:item];
        }
    }
    
    if (page != _currentPage && _presented) {
        _currentPage = page;
        if (_pageindicatorStyle == JCPhotoBrowserPageIndicatorStyleDot) {
            _pageControl.currentPage = page;
        } else {
            [self configPageLabelWithPage:_currentPage];
        }
    }
}

- (void)dismissAnimated:(BOOL)animated {
    for (JCPhotoView *photoView in _visibleItemViews) {
        [photoView cancelCurrentImageLoad];
    }
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            item.sourceView.alpha = 1;
        }];
    } else {
        item.sourceView.alpha = 1;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Gesture Perform

- (void)performScaleWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x/s, point.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            photoView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 100 || fabs(velocity.y) > 500) {
                [self showDismissalAnimation];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performSlideWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)configPhotoView:(JCPhotoView *)photoView withItem:(JCPhotoItem *)item {
    [photoView setItem:item determinate:(_loadingStyle == JCPhotoBrowserImageLoadingStyleDeterminate)];
}

- (void)configPageLabelWithPage:(NSUInteger)page {
    _pageLabel.text = [NSString stringWithFormat:@"%ld / %ld", page+1, _photoItems.count];
}

- (void)handlePanBegin {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    [UIApplication sharedApplication].statusBarHidden = NO;
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
}

#pragma mark - Gesture Recognizer

- (void)addGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didSingleTap:(UITapGestureRecognizer *)tap {
    [self showDismissalAnimation];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (!item.finished) {
        return;
    }
    if (photoView.zoomScale > 1) {
        [photoView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:[[SDWebImageManager sharedManager] cacheKeyForURL:photoView.item.imageUrl]];
    NSData *imageData = [NSData dataWithContentsOfFile:path];
    
    if (imageData.length <= 0) {
        return;
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[imageData] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didPan:(UIPanGestureRecognizer *)pan {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    if (photoView.zoomScale > 1.1) {
        return;
    }
    
    switch (_dismissalStyle) {
        case JCPhotoBrowserInteractiveDismissalStyleScale:
            [self performScaleWithPan:pan];
            break;
        case JCPhotoBrowserInteractiveDismissalStyleSlide:
            [self performSlideWithPan:pan];
            break;
        default:
            break;
    }
}

#pragma mark - Animation

- (void)showCancellationAnimation {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    item.sourceView.alpha = 1;
    if (!item.finished) {
        photoView.progressLayer.hidden = NO;
    }

    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self configPhotoView:photoView withItem:item];
    }];
}

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL startFromLeft = _startLocation.x < self.view.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -self.view.frame.size.height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = self.view.frame.size.height;
    }
    
    CGFloat angle0 = 0;
    if (_startLocation.x < self.view.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / self.view.frame.size.height);
    } else {
        angle0 = (M_PI / 2) * (point.y / self.view.frame.size.height);
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = kAnimationDuration;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [photoView.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    photoView.imageView.transform = transform;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:nil];
}

- (void)showDismissalAnimation {
    JCPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    [photoView cancelCurrentImageLoad];
    [UIApplication sharedApplication].statusBarHidden = NO;
    photoView.progressLayer.hidden = YES;
    item.sourceView.alpha = 0;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.frame = sourceRect;
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:NO];
    }];
}

- (void)showSlideCompletionAnimationFromPoint:(CGPoint)point {
    JCPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:YES];
    }];
}

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
        [self dismissAnimated:YES];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateReusableItemViews];
    [self configItemViews];
}

@end
