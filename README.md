# JCPhotoBrowser
An awesome way to browse your photos.

![JCPhotoBrowser ScreenShot](/demo.gif)

## Feature
* Objective-C version base on [SDWebImage](https://github.com/rs/SDWebImage)
* Swift version base on [Kingfisher](https://github.com/onevcat/Kingfisher)
* Support common photo display style.

## GetStart
### Usage
You need to intall [SDWebImage](https://github.com/rs/SDWebImage) or [Kingfisher](https://github.com/onevcat/Kingfisher) first, then copy files to your project.

	import "JCPhotoBrowser"
	NSArray *urls = @[@"http://wx2.sinaimg.cn/large/8daf9352gy1ffygabrjzmj20zk1767df.jpg",
                  @"http://wx3.sinaimg.cn/large/8daf9352gy1ffygacaol5j20k00jxn18.jpg"];        
	NSMutableArray *items = [NSMutableArray array];

    for (int i = 0; i < urls.count; i++) {
        JCPhotoItem *item = [JCPhotoItem itemWithSourceView:imageView
                                                   imageUrl:[NSURL URLWithString:urls[i]]];
        [items addObject:item];
    }
    JCPhotoBrowser *browser = [JCPhotoBrowser browserWithPhotoItems:items
                                                      selectedIndex:index];
    [browser showFromViewController:self];
    
    
If you want to use other display style.

	browser.dismissalStyle = JCPhotoBrowserInteractiveDismissalStyleScale;
	browser.loadingStyle = JCPhotoBrowserImageLoadingStyleIndeterminate;
	browser.pageindicatorStyle = JCPhotoBrowserPageIndicatorStyleText;