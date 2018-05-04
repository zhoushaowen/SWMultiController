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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<10; i++) {
        SubViewController *subVC = [SubViewController new];
        if(i%2 == 0){
            subVC.title = [NSString stringWithFormat:@"第%d个标题",i];
        }else{
            subVC.title = [NSString stringWithFormat:@"加大标题长度第%d个标题",i];
        }
        [mutableArr addObject:subVC];
    }
    SWMultiController *vc = [[SWMultiController alloc] initWithSubControllers:mutableArr];
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [vc selectedIndex:1];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
//        for (int i=0; i<5; i++) {
//            SubViewController *subVC = [SubViewController new];
//            subVC.title = [NSString stringWithFormat:@"测试标题%d",i];
//            [mutableArr addObject:subVC];
//        }
//        [vc reloadWithSubViewControllers:mutableArr];
//    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
