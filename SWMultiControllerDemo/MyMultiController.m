//
//  MyMultiController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/25.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "MyMultiController.h"
#import "SubViewController.h"

@interface MyMultiController ()

@end

@implementation MyMultiController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topTitleView.backgroundColor = [UIColor whiteColor];
    NSMutableArray *mutableArr = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<10; i++) {
        SubViewController *subVC = [SubViewController new];
        if(i%2 == 0){
            subVC.title = [NSString stringWithFormat:@"短标题\n我是index%d",i];
        }else{
            subVC.title = [NSString stringWithFormat:@"测试长标题\n我是index:%d",i];
        }
        [mutableArr addObject:subVC];
    }
    [self reloadWithSubViewControllers:mutableArr];
//    self.hiddenTitleBottomView = YES;
}

- (UIFont *)normalFontOfTitleLabel {
    return [UIFont systemFontOfSize:14];
}

- (UIFont *)selectedFontOfTitleLabel {
    return [UIFont systemFontOfSize:16];
}

- (UIColor *)normalColorOfTitleLabel {
    return [UIColor blackColor];
}

- (UIColor *)selectedColorOfTitleLabel {
    return [UIColor redColor];
}

- (CGFloat)horizontalSpaceOfTitleLabel {
    return 8;
}

- (CGFloat)verticalSpaceBetweenBottom {
    return 3;
}

- (UIColor *)titleBottomViewColor {
    return [UIColor redColor];
}

- (CGFloat)topTitleViewHeight {
    return 80;
}

- (CGFloat)titleBottomViewHeight {
    return 2;
}

- (CGFloat)titleBottomViewCornerRadius {
    return 1.0f;
}

- (CGFloat)titleLabelBaselineOffset {
    return -5.0;
}

@end
