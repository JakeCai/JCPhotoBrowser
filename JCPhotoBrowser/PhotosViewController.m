//
//  PhotosViewController.m
//  JCPhotoBrowser
//
//  Created by Jake on 2018/7/10.
//  Copyright © 2018 Jake. All rights reserved.
//

#import "PhotosViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JCPhotoBrowser.h"

@interface PhotosViewController ()

@property (nonatomic, strong) NSMutableArray *imageUrlArray;

@end

@implementation PhotosViewController

- (NSMutableArray *)imageUrlArray{
    if (!_imageUrlArray) {
        _imageUrlArray = [NSMutableArray new];
    }
    return _imageUrlArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat naviH = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) > 0 ? CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) + 44 : 20 + 44;
    
    NSArray *urlStrArray = @[@"https://wx2.sinaimg.cn/thumbnail/8daf9352gy1ffygabrjzmj20zk1767df.jpg",
                             @"https://wx3.sinaimg.cn/thumbnail/8daf9352gy1ffygacaol5j20k00jxn18.jpg",
                             @"https://wx1.sinaimg.cn/thumbnail/8daf9352gy1ffygacx4czj20k00jj0ye.jpg",
                             @"https://wx3.sinaimg.cn/thumbnail/8daf9352gy1ffygajl8qmj20k00jrdna.jpg",
                             @"https://wx4.sinaimg.cn/thumbnail/8daf9352gy1ffygab2d8cj20jx0ilwhm.jpg",];
    [urlStrArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat wh = (([UIScreen mainScreen].bounds.size.width - 40) / 3);
        CGFloat x = idx % 3 * (wh + 10);
        CGFloat y = idx / 3 * (wh + 10) + naviH;
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(x + 10, y, wh, wh)];
        NSURL *url = [NSURL URLWithString:obj];
        [view sd_setImageWithURL:url];
        NSString *original = [obj stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
        [self.imageUrlArray addObject:original];
        [self.view addSubview:view];
        view.tag = idx;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [view addGestureRecognizer:tap];
        view.userInteractionEnabled = YES;
    }];
}

- (void)tap:(UITapGestureRecognizer *)sender{
    UIImageView *imageV = (UIImageView *)sender.view;
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < self.imageUrlArray.count; i++) {
        NSString *originPic = self.imageUrlArray[i];
        UIImageView *imageView = self.view.subviews[i];
        JCPhotoItem *item = [JCPhotoItem itemWithSourceView:imageView
                                                   imageUrl:[NSURL URLWithString:originPic]];
        [items addObject:item];
    }
    JCPhotoBrowser *browser = [JCPhotoBrowser browserWithPhotoItems:items
                                                      selectedIndex:imageV.tag];
    browser.dismissalStyle = self.dismissalStyle;
    browser.loadingStyle = self.imageLoadingStyle;
    browser.pageindicatorStyle = self.pageIndicatorStyle;
    [browser showFromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
