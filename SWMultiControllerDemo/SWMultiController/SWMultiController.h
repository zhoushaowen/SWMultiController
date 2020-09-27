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

NS_ASSUME_NONNULL_BEGIN

@interface SWMultiController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

/**
 初始化方法
 
 @param subControllers 子控制器
 @return SWMultiController
 */
- (instancetype)initWithSubControllers:(NSArray<UIViewController *> *)subControllers NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 刷新控制器当中的子控制器,刷新之后默认会选中index 0
 
 @param subViewControllers 子控制器
 */
- (void)reloadWithSubViewControllers:(NSArray<UIViewController *> *)subViewControllers;

/**
 刷新控制器当中的子控制器,刷新之后默认会选中selectedIndex
 
 @param subViewControllers 子控制器
 @param selectedIndex 选择的索引
 */
- (void)reloadWithSubViewControllers:(NSArray<UIViewController *> *)subViewControllers selectedIndex:(NSUInteger)selectedIndex;
- (void)reloadSubViewControllerTitles:(NSArray<NSString *> *)titles;
- (void)reloadSubViewControllerTitle:(NSString *)title withIndex:(NSInteger)index;

/// 子控制器
@property (nonatomic,copy,readonly) NSArray<UIViewController *> *subViewControllers;
/**
 选中了某个控制器的回调
 */
@property (nonatomic,strong) void(^didSelectedControllerBlock)(UIViewController *selectedController,NSInteger index);
///点击label的回调
@property (nonatomic,strong) void(^didTapTitleLabelBlock)(UILabel *tapLabl,NSInteger index);

/**
 已经不选中某个控制器的回调
 */
@property (nonatomic,strong) void(^didUnSelectedControllerBlock)(UIViewController *unSelectedController,NSInteger index);

/**
 scrollBgView滑动时候调用
 */
@property (nonatomic,strong) void(^scrollBgViewDidScrollBlock)(UIScrollView *scrollBgView);

/**
 最底层的scrollView
 */
@property (nonatomic,readonly,strong) UIScrollView *scrollBgView;
@property (nonatomic,readonly,copy) NSArray<UILabel *> *labels;
@property (nonatomic,readonly) UIImageView *titleBottomView;
/**
 顶部滑动视图的背景视图
 */
@property (nonatomic,readonly,strong) UIView *topTitleView;

/**
 topTitleView之上的一个imageView
 */
@property (nonatomic,readonly,strong) UIImageView *topTitleImageView;
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
 当前控制器的索引
 
 @return 索引
 */
- (NSUInteger)selectedIndex;

/**
 获取某个子控制器在当前多控制器当中的索引
 
 @param subController 子控制器
 @return 索引
 */
- (NSInteger)indexOfSubController:(UIViewController *)subController;

#pragma mark - addHeaderView
/**
 顶部的headerView
 如果要添加了,必须要在子控制器中调用下面两个方法
 设置multiControllerHeaderView之后,scrollBgView和self.view的原点一样并且等高
 */
@property (nonatomic,strong,nullable) UIView *multiControllerHeaderView;
/**
 关联自动控制器和自控制器上的scrollView
 */
- (void)associateSubViewController:(UIViewController *)subViewController withScrollView:(UIScrollView *)scrollView;

#pragma mark - Override

/**
 当titleLabel的个数比较少的时候,无法全部横向铺满屏幕的时候,那么就均等间隔排列每个titleLabel;默认值是YES;
 (也就是说每个titleLabel两侧的间隔相等,titleLabel之间的间隔比titleLabel与边框的间隔大一倍。)
 此时将会忽略horizontalSpaceOfTitleLabel、topTitleViewLeftLabelInset、topTitleViewRightLabelInset的值;
 */
- (BOOL)shouldLayoutTitleLabelSpaceAround;
/**
 是否允许动态改变标题底部横线视图的宽度,默认是YES;
 如果imageForBottomView不为nil,默认是NO;
 如果不想随着scrollView的滑动动态改变,那么需要重写此方法返回NO,并且实现titleBottomViewWidth方法,返回一个固定的高度;
 */
- (BOOL)shouldDynamicChangeTitleBottomViewWidth;

/**
 标题底部横线视图的宽度,默认是0;
 如果imageForBottomView不为nil,默认是image的宽度;
 如果shouldDynamicChangeTitleBottomViewWidth方法返回值是YES,那么重写本方法没有任何作用;
 */
- (CGFloat)titleBottomViewWidth;
/**
 底部横线视图的高度,默认是4;
 如果imageForBottomView不为nil,默认是image的高度;
 可以重写此方法,进行自定义
 */
- (CGFloat)titleBottomViewHeight;

/**
 bottomView的background image,默认为nil;
 */
- (UIImage *)imageForBottomView;
/**
 顶部标题视图的高度,默认是60;
 可以重写此方法,进行自定义
 */
- (CGFloat)topTitleViewHeight;

/**
 最左边的label距离左边的间距,默认值是20
 */
- (CGFloat)topTitleViewLeftLabelInset;
/**
 最右边的label距离右边的间距,默认值是20
 */
- (CGFloat)topTitleViewRightLabelInset;

/**
 标题之间的水平间距,默认值25
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
- (CGFloat)verticalSpaceBetweenBottomAndTitleBottomView;

/**
 底部横线视图的圆角半径,默认是2;
 如果imageForBottomView不为nil,默认是0;
 可以重写此方法,进行自定义
 */
- (CGFloat)titleBottomViewCornerRadius;

/**
 底部横线视图的颜色,默认是green;
 如果imageForBottomView不为nil,默认是nil;
 可以重写此方法,进行自定义
 */
- (UIColor *)titleBottomViewColor;

/**
 底部横线视图的距离Baseline偏移量
 可以重写此方法,进行自定义
 */
- (CGFloat)titleLabelBaselineOffset;

/**
 label的固定高度,默认高度等于topTitleViewHeight
 */
- (CGFloat)titleLabelHeight;

/**
 label的原点y值,默认是0
 */
- (CGFloat)titleLabelOriginY;



@end

NS_ASSUME_NONNULL_END



