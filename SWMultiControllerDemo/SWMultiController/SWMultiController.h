//
//  SWMultiController.h
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWMultiController;

@interface UIViewController (SWMultiController)

@property (nullable,nonatomic,readonly,weak) __kindof SWMultiController *multiController;

@end

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
 选中了某个控制器的回调
 */
@property (nonatomic,strong) void(^didSelectedControllerBlock)(UIViewController *selectedController,NSInteger index);

/**
 已经不选中某个控制器的回调
 */
@property (nonatomic,strong) void(^didUnSelectedControllerBlock)(UIViewController *unSelectedController,NSInteger index);

/**
 最底层的scrollView
 */
@property (nonatomic,readonly,strong) UIScrollView *scrollBgView;
/**
 顶部滑动视图的背景视图
 */
@property (nonatomic,readonly,strong) UIView *topTitleView;

/**
 是否隐藏标题下方的横线,默认NO
 */
@property (nonatomic) BOOL hiddenTitleBottomView;

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

/**
 标题的对其方式,默认是NSTextAlignmentCenter
 可以重写此方法,进行自定义
 */
- (NSTextAlignment)titleLabelTextAlignment;

/**
 底部横线视图的距离底部的距离
 可以重写此方法,进行自定义
 */
- (CGFloat)verticalSpaceBetweenBottom;

/**
 底部横线视图的圆角半径
 可以重写此方法,进行自定义
 */
- (CGFloat)titleBottomViewCornerRadius;

/**
 底部横线视图的高度
 可以重写此方法,进行自定义
 */
- (CGFloat)titleBottomViewHeight;

/**
 底部横线视图的颜色
 可以重写此方法,进行自定义
 */
- (UIColor *)titleBottomViewColor;

/**
 底部横线视图的距离Baseline偏移量
 可以重写此方法,进行自定义
 */
- (CGFloat)titleLabelBaselineOffset;




@end
