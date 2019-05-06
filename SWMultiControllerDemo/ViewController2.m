//
//  ViewController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "ViewController2.h"
#import "SubViewController.h"
#import "SWMultiController.h"
#import "CollectionViewController.h"
#import "MyHeaderView.h"

@interface ViewController2 ()
{
    SWMultiController *_multiController;
}

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<4; i++) {
        SubViewController *subVC = [SubViewController new];
        subVC.title = [NSString stringWithFormat:@"第%d个",i];
        [mutableArr addObject:subVC];
    }
    SWMultiController *vc = [[SWMultiController alloc] initWithSubControllers:mutableArr];
    [self addChildViewController:vc];
    _multiController = vc;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        _multiController.view.frame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top);
    } else {
        _multiController.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    }
}




@end
