//
//  ViewController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"
#import "SWMultiController.h"
#import "CollectionViewController.h"
#import "MyHeaderView.h"

@interface ViewController ()
{
    SWMultiController *_multiController;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<10; i++) {
        if(i%2 == 0){
            SubViewController *subVC = [SubViewController new];
            subVC.title = [NSString stringWithFormat:@"第%d个标题",i];
            [mutableArr addObject:subVC];
        }else{
            CollectionViewController *subVC = [[CollectionViewController alloc] init];
//            SubViewController *subVC = [SubViewController new];
            subVC.title = [NSString stringWithFormat:@"加大标题长度第%d个标题",i];
            [mutableArr addObject:subVC];
        }
    }
    SWMultiController *vc = [[SWMultiController alloc] initWithSubControllers:mutableArr];
//    [vc selectedIndex:1];
    [self addChildViewController:vc];
    _multiController = vc;
    MyHeaderView *headerView = [MyHeaderView new];
    headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);
    headerView.backgroundColor = [UIColor redColor];
    vc.multiControllerHeaderView = headerView;
//    vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 500);
//    });
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _multiController.view.frame = self.view.bounds;
//    if (@available(iOS 11.0, *)) {
//        _multiController.view.frame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top);
//    } else {
//        _multiController.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
//    }
}




@end
