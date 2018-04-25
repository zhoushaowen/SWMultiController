//
//  SWMultiController.h
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWMultiController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

/**
 初始化方法

 @param subControllers 自控制器
 @return SWMultiController
 */
- (instancetype)initWithSubControllers:(NSArray<UIViewController *> *)subControllers NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 刷新控制器当中的子控制器,刷新之后默认会选中index 0

 @param subViewControllers 自控制器
 */
- (void)reloadWithSubViewControllers:(NSArray<UIViewController *> *)subViewControllers;
/**
 即将显示某个控制器的回调
 */
@property (nonatomic,strong) void(^willDisplayControllerBlock)(UIViewController *visibleController,NSInteger index);

/**
 最底层的scrollView
 */
@property (nonatomic,readonly,strong) UIScrollView *scrollBgView;

/**
 手动选择某个索引

 @param index 索引
 */
- (void)selectedIndex:(NSInteger)index;

/**
 获取某个子控制器在当前多控制器当中的索引

 @param subController 子控制器
 @return 索引
 */
- (NSInteger)indexOfSubController:(UIViewController *)subController;

/**
 顶部标题视图的高度
 可以重写此方法,进行自定义
 */
- (CGFloat)topTitleViewHeight;

/**
 顶部标题视图的背景色
 可以重写此方法,进行自定义
 */
- (UIColor *)topTitleViewBackgroundColor;

/**
 标题之间的水平间距
 可以重写此方法,进行自定义
 */
- (CGFloat)horizontalSpaceOfTitleLabel;

/**
 选中标题的文字颜色
 可以重写此方法,进行自定义
 */
- (UIColor *)selectedColorOfTitleLabel;

/**
 普通状态下标题文字颜色
 可以重写此方法,进行自定义
 */
- (UIColor *)normalColorOfTitleLabel;

/**
 选中标题的字体
 可以重写此方法,进行自定义
 */
- (UIFont *)selectedFontOfTitleLabel;

/**
 普通状态下标题的文字颜色
 可以重写此方法,进行自定义
 */
- (UIFont *)normalFontOfTitleLabel;


@end
