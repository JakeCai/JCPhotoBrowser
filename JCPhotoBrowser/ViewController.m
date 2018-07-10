//
//  ViewController.m
//  JCPhotoBrowser
//
//  Created by Jake on 2018/7/10.
//  Copyright © 2018 Jake. All rights reserved.
//

#import "ViewController.h"
#import "PhotosViewController.h"
#import <SDWebImage/SDImageCache.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *interactiveDismissalControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *indicatorControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *loadingControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        PhotosViewController *vc = [[PhotosViewController alloc] init];
        vc.dismissalStyle = self.interactiveDismissalControl.selectedSegmentIndex;
        vc.pageIndicatorStyle = self.indicatorControl.selectedSegmentIndex;
        vc.imageLoadingStyle = self.loadingControl.selectedSegmentIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
