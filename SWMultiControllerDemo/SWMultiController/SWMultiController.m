//
//  SWMultiController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWMultiController.h"
#import <objc/runtime.h>

@interface SWMultiControllerObserver : NSObject

@property (nonatomic,weak) SWMultiController *multiController;

@end

@interface SWMultiController ()

@property (nonatomic) UIView *topTitleView;
@property (nonatomic) UIScrollView *scrollBgView;
@property (nonatomic) UIScrollView *topTitleScrollView;
@property (nonatomic) UIView *titleBottomView;
@property (nonatomic,copy) NSArray<UIViewController *> *subViewControllers;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL shouldIgnoreContentOffset;
@property (nonatomic) BOOL shouldIgnoreSubVCContentOffset;
@property (nonatomic) BOOL sw_isViewDidAppeared;
@property (nonatomic) SWMultiControllerObserver *observer;
@property (nonatomic) CGFloat tmpTitleBottomViewWidth;

- (UIScrollView *)sw_getAssociatedScrollViewWithSubViewController:(UIViewController *)subViewController;

@end

@implementation UIViewController (SWMultiController)

- (SWMultiController *)multiController {
    if(self.parentViewController == nil || ![self.parentViewController isKindOfClass:[SWMultiController class]]) return nil;
    return (SWMultiController *)self.parentViewController;
}


@end

@implementation SWMultiControllerObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    //    NSLog(@"%@------%@-------%@-----%@",object,keyPath,change,context);
    if([keyPath isEqualToString:@"frame"]){
        UIViewController *subVC = (__bridge UIViewController *)(context);
        [self updateAssociatedScrollViewContentOffsetWithSubViewController:subVC];
    }else if ([keyPath isEqualToString:@"selectedIndex"]){
        NSInteger oldIndex = [change[NSKeyValueChangeOldKey] integerValue];
        NSInteger currentIndex = [change[NSKeyValueChangeNewKey] integerValue];
        //    NSLog(@"oldIndex:%ld-----currentIndex:%ld",(long)oldIndex,(long)currentIndex);
        SWMultiController *multiController = (SWMultiController *)object;
        if(oldIndex != - 1){
            UIViewController *oldVC = multiController.subViewControllers[oldIndex];
            if(!oldVC) return;
            if(multiController.sw_isViewDidAppeared){
                [oldVC beginAppearanceTransition:NO animated:YES];
                [oldVC endAppearanceTransition];
            }
            if(multiController.didUnSelectedControllerBlock){
                multiController.didUnSelectedControllerBlock(oldVC, oldIndex);
            }
        }
        if(currentIndex != -1){
            UIViewController *currentVC = multiController.subViewControllers[currentIndex];
            if(!currentVC) return;
            if(multiController.sw_isViewDidAppeared){
                [currentVC beginAppearanceTransition:YES animated:YES];
                [currentVC endAppearanceTransition];
            }
            if(multiController.didSelectedControllerBlock){
                multiController.didSelectedControllerBlock(currentVC, currentIndex);
            }
        }
    }
}

- (void)updateAssociatedScrollViewContentOffsetWithSubViewController:(UIViewController *)subVC {
    NSInteger index = [self.multiController indexOfSubController:subVC];
    if(index == self.multiController.selectedIndex) return;
    UIScrollView *scrollView = [self.multiController sw_getAssociatedScrollViewWithSubViewController:subVC];
    if(scrollView.contentOffset.y < - CGRectGetMaxY(self.multiController.topTitleView.frame)){
        CGPoint offset = scrollView.contentOffset;
        offset.y = - CGRectGetMaxY(self.multiController.topTitleView.frame);
        scrollView.contentOffset = offset;
    }
}

@end

@implementation SWMultiController

- (instancetype)initWithSubControllers:(NSArray<UIViewController *> *)subControllers {
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.selectedIndex = - 1;
        self.subViewControllers = subControllers;
        [self addObserver];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithSubControllers:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        self.selectedIndex = - 1;
        [self addObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollBgView = ({
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [self topTitleViewHeight], self.view.bounds.size.width, self.view.bounds.size.height - [self topTitleViewHeight])];
        if (@available(iOS 11.0, *)) {
            scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.pagingEnabled = YES;
        scroll.delegate = self;
        if(self.navigationController.interactivePopGestureRecognizer){
            [scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        }
        [self.view addSubview:scroll];
        scroll;
    });
    
    self.topTitleView = ({
        UIView *view = [UIView new];
        if(self.multiControllerHeaderView){
            view.frame = CGRectMake(0, self.multiControllerHeaderView.bounds.size.height, self.view.bounds.size.width, [self topTitleViewHeight]);
        }else{
            view.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self topTitleViewHeight]);
        }
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        view.backgroundColor = [UIColor blackColor];
        [self.view addSubview:view];
        view;
    });
    self.topTitleScrollView = ({
        UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.topTitleView.bounds];
        if (@available(iOS 11.0, *)) {
            scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        scroll.showsVerticalScrollIndicator = NO;
        scroll.showsHorizontalScrollIndicator = NO;
        [self.topTitleView addSubview:scroll];
        scroll;
    });
    self.titleBottomView = ({
        UIView *view = [UIView new];
        [self.topTitleScrollView addSubview:view];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [self titleBottomViewColor];
        view.layer.cornerRadius = [self titleBottomViewCornerRadius];
        view.clipsToBounds = YES;
        view.hidden = _hiddenTitleBottomView;
        view;
    });
    [self addTopTitleLabels];
    [self selectedIndex:0];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateHeaderViewFrame];
    if(self.multiControllerHeaderView){
        self.scrollBgView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }else{
        self.scrollBgView.frame = CGRectMake(0, [self topTitleViewHeight], self.view.bounds.size.width, self.view.bounds.size.height - [self topTitleViewHeight]);
    }
    [self.subViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.parentViewController){
            obj.view.frame = CGRectMake(idx*self.scrollBgView.bounds.size.width, 0, self.scrollBgView.bounds.size.width, self.scrollBgView.bounds.size.height);
        }
    }];
    if(self.multiControllerHeaderView){
        self.topTitleView.frame = CGRectMake(0, self.multiControllerHeaderView.bounds.size.height, self.view.bounds.size.width, [self topTitleViewHeight]);
    }else{
        self.topTitleView.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self topTitleViewHeight]);
    }
    self.topTitleScrollView.frame = self.topTitleView.bounds;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    NSLog(@"%s",__func__);
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj beginAppearanceTransition:YES animated:animated];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    NSLog(@"%s",__func__);
    self.sw_isViewDidAppeared = YES;
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj endAppearanceTransition];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    NSLog(@"%s",__func__);
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj beginAppearanceTransition:NO animated:animated];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    NSLog(@"%s",__func__);
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj endAppearanceTransition];
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //        NSLog(@"屏幕即将旋转------------");
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //        NSLog(@"屏幕已经旋转+++++++++++++");
        if(!self.isViewLoaded) return;
        [self.scrollBgView setContentSize:CGSizeMake(self.view.bounds.size.width*self.subViewControllers.count, 0)];
        self.shouldIgnoreContentOffset = YES;
        [self.scrollBgView setContentOffset:CGPointMake(self.view.bounds.size.width*self.selectedIndex, 0) animated:NO];
        [self.topTitleScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)obj;
                label.textColor = [self normalColorOfTitleLabel];
                label.font = [self normalFontOfTitleLabel];
            }
        }];
        UILabel *label = [self.topTitleView viewWithTag:self.selectedIndex + 100];
        label.textColor = [self selectedColorOfTitleLabel];
        label.font = [self selectedFontOfTitleLabel];
        [self updateTopTitleScrollViewContentSize];
        [self setLabelToCenter:label animated:NO];
        CGRect bounds = self.titleBottomView.bounds;
        CGPoint center = self.titleBottomView.center;
        bounds = CGRectMake(0, 0, label.bounds.size.width, [self titleBottomViewHeight]);
        center.x = CGRectGetMidX(label.frame);
        self.titleBottomView.bounds = bounds;
        self.titleBottomView.center = center;
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    //    NSLog(@"%@",NSStringFromCGSize(size));
}

- (void)addTopTitleLabels {
    if(!self.isViewLoaded) return;
    if(self.subViewControllers.count < 1) return;
    //    __block CGFloat totalWidth = [self horizontalSpaceOfTitleLabel];
    __block CGFloat totalWidth = [self topTitleViewLeftLabelInset];
    [self.subViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textAlignment = [self titleLabelTextAlignment];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.delegate = self;
        [label addGestureRecognizer:tapGesture];
        label.tag = idx + 100;
        label.textColor = [self normalColorOfTitleLabel];
        label.font = [self normalFontOfTitleLabel];
        [self.topTitleScrollView addSubview:label];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:obj.title];
        [attributedStr addAttribute:NSBaselineOffsetAttributeName value:@([self titleLabelBaselineOffset]) range:NSMakeRange(0, attributedStr.length)];
        if(idx == 0){
            [attributedStr addAttribute:NSFontAttributeName value:[self selectedFontOfTitleLabel] range:NSMakeRange(0, attributedStr.length)];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[self selectedColorOfTitleLabel] range:NSMakeRange(0, attributedStr.length)];
        }else{
            [attributedStr addAttribute:NSFontAttributeName value:[self normalFontOfTitleLabel] range:NSMakeRange(0, attributedStr.length)];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[self normalColorOfTitleLabel] range:NSMakeRange(0, attributedStr.length)];
        }
        label.attributedText = attributedStr;
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])];
        label.frame = CGRectMake(totalWidth, 0, size.width, [self topTitleViewHeight]);
        if(idx == self.subViewControllers.count - 1){
            totalWidth += size.width + [self topTitleViewRightLabelInset];
        }else{
            totalWidth += size.width + [self horizontalSpaceOfTitleLabel];
        }
    }];
    self.topTitleScrollView.contentSize = CGSizeMake(totalWidth, 0);
    CGRect rect = [self.topTitleScrollView viewWithTag:100].frame;
    self.titleBottomView.bounds = CGRectMake(0, 0, [self shouldDynamicChangeTitleBottomViewWidth] ?  rect.size.width : self.tmpTitleBottomViewWidth, [self titleBottomViewHeight]);
    self.titleBottomView.center = CGPointMake(CGRectGetMidX(rect), [self topTitleViewHeight] - [self verticalSpaceBetweenBottom] - [self titleBottomViewHeight]/2.0);
    self.scrollBgView.contentSize = CGSizeMake(self.view.bounds.size.width*self.subViewControllers.count, 0);
}

- (void)addSubViewContollerViewIfNeeded:(NSInteger)index {
    UIViewController *subVC = self.subViewControllers[index];
    if(subVC == nil) return;
    if(subVC.parentViewController == nil){
        [self addChildViewController:subVC];
        subVC.view.frame = CGRectMake(self.scrollBgView.bounds.size.width*index, 0, self.scrollBgView.bounds.size.width, self.scrollBgView.bounds.size.height);
        [self.scrollBgView addSubview:subVC.view];
        [subVC didMoveToParentViewController:self];
    }else{
        subVC.view.frame = CGRectMake(self.scrollBgView.bounds.size.width*index, 0, self.scrollBgView.bounds.size.width, self.scrollBgView.bounds.size.height);
    }
}

#pragma mark - Override
- (BOOL)shouldDynamicChangeTitleBottomViewWidth {
    return YES;
}

- (CGFloat)titleBottomViewWidth {
    return 0;
}

- (CGFloat)topTitleViewHeight {
    return 60;
}

- (UIColor *)titleBottomViewColor {
    return [UIColor greenColor];
}

- (CGFloat)titleBottomViewHeight {
    return 4;
}

- (CGFloat)titleBottomViewCornerRadius {
    return 4/2.0f;
}

- (CGFloat)verticalSpaceBetweenBottom {
    return 8;
}

- (CGFloat)horizontalSpaceOfTitleLabel {
    return 20;
}

- (UIColor *)selectedColorOfTitleLabel {
    return [UIColor redColor];
}

- (UIColor *)normalColorOfTitleLabel {
    return [UIColor lightGrayColor];
}

- (UIFont *)selectedFontOfTitleLabel {
    return [UIFont systemFontOfSize:20];
}

- (UIFont *)normalFontOfTitleLabel {
    return [UIFont systemFontOfSize:15];
}

- (NSTextAlignment)titleLabelTextAlignment {
    return NSTextAlignmentCenter;
}

- (CGFloat)titleLabelBaselineOffset {
    return 0;
}

- (CGFloat)topTitleViewLeftLabelInset {
    return 20;
}

- (CGFloat)topTitleViewRightLabelInset {
    return 20;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(![touch.view isKindOfClass:[UILabel class]]) return NO;
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_scrollBgViewDidScrollBlock){
        _scrollBgViewDidScrollBlock(scrollView);
    }
    if(_shouldIgnoreContentOffset){
        _shouldIgnoreContentOffset = NO;
        return;
    }
    CGPoint contentOffset = scrollView.contentOffset;
    if(contentOffset.x < 0) {
        contentOffset.x = 0;
    }
    if(contentOffset.x > scrollView.bounds.size.width * (self.subViewControllers.count - 1)){
        contentOffset.x = scrollView.bounds.size.width * (self.subViewControllers.count - 1);
    }
    NSInteger currentIndex = contentOffset.x/scrollView.bounds.size.width;
    UILabel *currentLabel = [self.topTitleScrollView viewWithTag:currentIndex + 100];
    UILabel *nextLabel = [self.topTitleScrollView viewWithTag:currentIndex + 100 + 1];
    CGFloat percent = (contentOffset.x - scrollView.bounds.size.width*currentIndex)/scrollView.bounds.size.width;
    currentLabel.font = [self getFontWithBeginFont:[self selectedFontOfTitleLabel] endFont:[self normalFontOfTitleLabel] percent:percent];
    nextLabel.font = [self getFontWithBeginFont:[self normalFontOfTitleLabel] endFont:[self selectedFontOfTitleLabel] percent:percent];
    currentLabel.textColor = [self getColorWithBeginColor:[self selectedColorOfTitleLabel] endColor:[self normalColorOfTitleLabel] percent:percent];
    nextLabel.textColor = [self getColorWithBeginColor:[self normalColorOfTitleLabel] endColor:[self selectedColorOfTitleLabel] percent:percent];
    [self updateTopTitleScrollViewContentSize];
    [self changeTitleBottomViewWithCurrentIndex:currentIndex percent:percent currentLabel:currentLabel nextLabel:nextLabel];
    if(contentOffset.x > (self.subViewControllers.count - 2) * scrollView.bounds.size.width ){//当前快滑动到最后一个index的时候,先更新topTitleScrollView的contentSize
        //        CGFloat totalWidth = [self horizontalSpaceOfTitleLabel];
        CGFloat totalWidth = [self topTitleViewLeftLabelInset];
        for (int i=0; i<self.subViewControllers.count; i++) {
            UILabel *label = [self.topTitleScrollView viewWithTag:i+100];
            CGFloat width = 0;
            UILabel *tmpLabel = [UILabel new];
            tmpLabel.numberOfLines = 0;
            tmpLabel.textAlignment = [self titleLabelTextAlignment];
            tmpLabel.text = label.text;
            tmpLabel.attributedText = label.attributedText;
            if(i < self.subViewControllers.count - 1){
                tmpLabel.font = [self normalFontOfTitleLabel];
            }else{
                tmpLabel.font = [self selectedFontOfTitleLabel];
            }
            width = [tmpLabel sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])].width;
            if(i == self.subViewControllers.count - 1){
                totalWidth += width + [self topTitleViewRightLabelInset];
            }else{
                totalWidth += width + [self horizontalSpaceOfTitleLabel];
            }
        }
        if(totalWidth < self.topTitleScrollView.bounds.size.width){
            totalWidth = self.topTitleScrollView.bounds.size.width;
        }
        self.topTitleScrollView.contentSize = CGSizeMake(totalWidth, 0);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //    NSLog(@"%@",NSStringFromCGPoint(*targetContentOffset));
    NSInteger index = (*targetContentOffset).x/scrollView.bounds.size.width;
    //    NSLog(@"%ld",(long)index);
    if(index < 0 || index > self.subViewControllers.count - 1) return;
    UILabel *label = [self.topTitleScrollView viewWithTag:index + 100];
    [self setLabelToCenter:label animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    //    NSLog(@"%ld",(long)index);
    if(index < 0 || index > self.subViewControllers.count - 1) return;
    if(!decelerate){
        [self addSubViewContollerViewIfNeeded:index];
        self.selectedIndex = index;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self addSubViewContollerViewIfNeeded:index];
    self.selectedIndex = index;
}

#pragma mark - Private
- (UIFont *)getFontWithBeginFont:(UIFont *)beginFont endFont:(UIFont *)endFont percent:(CGFloat)percent {
    CGFloat fontOffset = [endFont pointSize] - [beginFont pointSize];
    return [UIFont systemFontOfSize:beginFont.pointSize + percent * fontOffset];
}

- (UIColor *)getColorWithBeginColor:(UIColor *)beginColor endColor:(UIColor *)endColor percent:(CGFloat)percent {
    NSArray *beginColors = [self getRGBWithColor:beginColor];
    NSArray *endColors = [self getRGBWithColor:endColor];
    NSArray *offsetColors = [self getColorOffsetWithBeginColor:beginColors endColor:endColors];
    CGFloat r = [beginColors[0] doubleValue] + percent * [offsetColors[0] doubleValue];
    CGFloat g = [beginColors[1] doubleValue] + percent * [offsetColors[1] doubleValue];
    CGFloat b = [beginColors[2] doubleValue] + percent * [offsetColors[2] doubleValue];
    CGFloat a = [beginColors[3] doubleValue] + percent * [offsetColors[3] doubleValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (NSArray<NSNumber *> *)getRGBWithColor:(UIColor *)color {
    CGFloat r = 0,g = 0,b = 0,a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return @[@(r),@(g),@(b),@(a)];
}

- (NSArray *)getColorOffsetWithBeginColor:(NSArray *)beginColor endColor:(NSArray *)endColor {
    return @[@([endColor[0] doubleValue] - [beginColor[0] doubleValue]),
             @([endColor[1] doubleValue] - [beginColor[1] doubleValue]),
             @([endColor[2] doubleValue] - [beginColor[2] doubleValue]),
             @([endColor[3] doubleValue] - [beginColor[3] doubleValue])
             ];
}

- (void)changeTitleBottomViewWithCurrentIndex:(NSInteger)currentIndex percent:(CGFloat)percent currentLabel:(UILabel *)currentLabel nextLabel:(UILabel *)nextLabel {
    if(_hiddenTitleBottomView) return;
    CGFloat nextLabelWidth = [nextLabel sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])].width;
    CGFloat currentLabelWidth = [currentLabel sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])].width;
    CGFloat widthOffset = nextLabelWidth - currentLabelWidth;
    CGFloat nextLabelCenterX = 0;
    for(int i=0;i<currentIndex + 2;i++){
        UILabel *label = [self.topTitleScrollView viewWithTag:i + 100];
        CGFloat width = 0;
        if(i == (currentIndex + 1)){//如果是最后一个label,只需计算出label长度的一半
            width = [label sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])].width/2.0f;
            nextLabelCenterX += width + [self topTitleViewRightLabelInset];
        }else{
            width = [label sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])].width;
            nextLabelCenterX += width + [self horizontalSpaceOfTitleLabel];
        }
        //        nextLabelCenterX += width + [self horizontalSpaceOfTitleLabel];
    }
    CGFloat centerXOffset = nextLabelCenterX - CGRectGetMidX(currentLabel.frame);
    CGRect bounds = self.titleBottomView.bounds;
    CGPoint center = self.titleBottomView.center;
    center.x = CGRectGetMidX(currentLabel.frame) + percent * centerXOffset;
    if([self shouldDynamicChangeTitleBottomViewWidth]){
        bounds.size.width = currentLabelWidth + percent * widthOffset;
        self.titleBottomView.bounds = bounds;
    }else{
        bounds.size.width = [self tmpTitleBottomViewWidth];
    }
    self.titleBottomView.center = center;
}

- (void)updateTopTitleScrollViewContentSize {
    //    CGFloat totalWidth = [self horizontalSpaceOfTitleLabel];
    CGFloat totalWidth = [self topTitleViewLeftLabelInset];
    for(int i=0;i<self.subViewControllers.count;i++){
        UILabel *label = [self.topTitleScrollView viewWithTag:i + 100];
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])];
        label.frame = CGRectMake(totalWidth, 0, size.width, [self topTitleViewHeight]);
        if(i == self.subViewControllers.count - 1){
            totalWidth += size.width + [self topTitleViewRightLabelInset];
        }else{
            totalWidth += size.width + [self horizontalSpaceOfTitleLabel];
        }
    }
    if(totalWidth < self.topTitleScrollView.bounds.size.width){
        totalWidth = self.topTitleScrollView.bounds.size.width;
    }
    self.topTitleScrollView.contentSize = CGSizeMake(totalWidth, 0);
}

- (void)setLabelToCenter:(UILabel *)label animated:(BOOL)animated {
    //求出label距离scrollView中心点的距离
    CGFloat offsetX = label.center.x - self.topTitleScrollView.bounds.size.width/2.0f;
    if(offsetX < 0){
        offsetX = 0;
    }
    //求出scrollView最大可滑动的距离
    CGFloat maxOffset = self.topTitleScrollView.contentSize.width - self.topTitleScrollView.bounds.size.width;
    if(maxOffset < 0){
        maxOffset = 0;
    }
    if(offsetX > maxOffset){
        offsetX = maxOffset;
    }
    [self.topTitleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag - 100;
    [self selectedIndex:index];
}

- (void)addObserver {
    [self addObserver:self.observer forKeyPath:@"selectedIndex" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (SWMultiControllerObserver *)observer {
    if(!_observer){
        _observer = [SWMultiControllerObserver new];
        _observer.multiController = self;
    }
    return _observer;
}

- (CGFloat)tmpTitleBottomViewWidth {
    CGFloat width = [self titleBottomViewWidth];
    if(![self shouldDynamicChangeTitleBottomViewWidth]){
        NSAssert(width > 0, @"titleBottomViewWidth必须返回一个大于0大数值");
    }
    return width;
}

- (void)updateSubViewControllerScrollViewContentOffset:(UIScrollView *)scrollView {
    if(self.multiControllerHeaderView){
        self.shouldIgnoreSubVCContentOffset = YES;
        scrollView.contentInset = UIEdgeInsetsMake(self.multiControllerHeaderView.bounds.size.height + [self topTitleViewHeight], 0, 0, 0);
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
        CGPoint offset = scrollView.contentOffset;
        offset.y = - CGRectGetMaxY(self.topTitleView.frame);
        scrollView.contentOffset = offset;
        self.shouldIgnoreSubVCContentOffset = NO;
    }else{
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }
}

- (UIScrollView *)sw_getAssociatedScrollViewWithSubViewController:(UIViewController *)subViewController {
    return objc_getAssociatedObject(subViewController, @selector(sw_getAssociatedScrollViewWithSubViewController:));
}

#pragma mark - Public
- (void)selectedIndex:(NSInteger)index {
    if(index == self.selectedIndex) return;
    if(!self.isViewLoaded){
        NSLog(@"SWMultiController还没loadView,selectedIndex被忽略");
        return;
    }
    _shouldIgnoreContentOffset = YES;
    [self.scrollBgView setContentOffset:CGPointMake(self.scrollBgView.bounds.size.width * index, 0) animated:NO];
    UILabel *currentLabel = [self.topTitleScrollView viewWithTag:self.selectedIndex + 100];
    UILabel *nextLabel = [self.topTitleScrollView viewWithTag:index + 100];
    currentLabel.font = [self getFontWithBeginFont:[self selectedFontOfTitleLabel] endFont:[self normalFontOfTitleLabel] percent:1.0f];
    nextLabel.font = [self getFontWithBeginFont:[self normalFontOfTitleLabel] endFont:[self selectedFontOfTitleLabel] percent:1.0f];
    currentLabel.textColor = [self getColorWithBeginColor:[self selectedColorOfTitleLabel] endColor:[self normalColorOfTitleLabel] percent:1.0f];
    nextLabel.textColor = [self getColorWithBeginColor:[self normalColorOfTitleLabel] endColor:[self selectedColorOfTitleLabel] percent:1.0f];
    [self changeTitleBottomViewWithCurrentIndex:self.selectedIndex percent:1.0 currentLabel:currentLabel nextLabel:nextLabel];
    [self updateTopTitleScrollViewContentSize];
    CGRect bounds = self.titleBottomView.bounds;
    CGPoint center = self.titleBottomView.center;
    center.x = CGRectGetMidX(nextLabel.frame);
    if([self shouldDynamicChangeTitleBottomViewWidth]){
        bounds.size.width = nextLabel.bounds.size.width;
    }else{
        bounds.size.width = [self tmpTitleBottomViewWidth];
    }
    self.titleBottomView.bounds = bounds;
    self.titleBottomView.center = center;
    [self addSubViewContollerViewIfNeeded:index];
    [self setLabelToCenter:nextLabel animated:YES];
    self.selectedIndex = index;
}

- (NSInteger)indexOfSubController:(UIViewController *)subController {
    return [self.subViewControllers indexOfObject:subController];
}

- (void)reloadWithSubViewControllers:(NSArray<UIViewController *> *)subViewControllers {
    self.selectedIndex = -1;
    [self.subViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.parentViewController){
            [obj.view removeFromSuperview];
        }
        [obj willMoveToParentViewController:nil];
        [obj removeFromParentViewController];
    }];
    self.subViewControllers = subViewControllers;
    if(self.isViewLoaded){
        self.titleBottomView.frame = CGRectZero;
        self.scrollBgView.contentSize = CGSizeZero;
        _shouldIgnoreContentOffset = YES;
        [self.scrollBgView setContentOffset:CGPointZero];
        [self.topTitleScrollView setContentOffset:CGPointZero];
        [self.topTitleScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[UILabel class]]){
                [obj removeFromSuperview];
            }
        }];
    }
    [self addTopTitleLabels];
    [self selectedIndex:0];
}

- (void)setHiddenTitleBottomView:(BOOL)hiddenTitleBottomView {
    _hiddenTitleBottomView = hiddenTitleBottomView;
    self.titleBottomView.hidden = _hiddenTitleBottomView;
}

- (void)subViewController:(UIViewController *)subViewController scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.shouldIgnoreSubVCContentOffset) return;
    if(scrollView == nil) return;
    if(self.multiControllerHeaderView == nil) return;
    UIScrollView *associatedScroll = [self sw_getAssociatedScrollViewWithSubViewController:subViewController];
    if(associatedScroll == nil) return;
    if(scrollView.contentOffset.y < - (self.multiControllerHeaderView.bounds.size.height + [self topTitleViewHeight])){
        CGRect multiControllerHeaderViewFrame = self.multiControllerHeaderView.frame;
        multiControllerHeaderViewFrame.origin.y = 0;
        self.multiControllerHeaderView.frame = multiControllerHeaderViewFrame;
        CGRect topTitleViewFrame = self.topTitleView.frame;
        topTitleViewFrame.origin.y = self.multiControllerHeaderView.bounds.size.height;
        self.topTitleView.frame = topTitleViewFrame;
        return;
    }
    CGRect multiControllerHeaderViewFrame = self.multiControllerHeaderView.frame;
    multiControllerHeaderViewFrame.origin.y = - (scrollView.contentOffset.y + multiControllerHeaderViewFrame.size.height + [self topTitleViewHeight]);
    self.multiControllerHeaderView.frame = multiControllerHeaderViewFrame;
    if(scrollView.contentOffset.y <= - [self topTitleViewHeight] - self.topTitleViewFloatOffsetY){
        CGRect topTitleViewFrame = self.topTitleView.frame;
        topTitleViewFrame.origin.y = - (scrollView.contentOffset.y + [self topTitleViewHeight]);
        self.topTitleView.frame = topTitleViewFrame;
    }else{
        CGRect topTitleViewFrame = self.topTitleView.frame;
        topTitleViewFrame.origin.y = self.topTitleViewFloatOffsetY;
        self.topTitleView.frame = topTitleViewFrame;
    }
}

- (void)associateSubViewController:(UIViewController *)subViewController withScrollView:(UIScrollView *)scrollView {
    if(self.multiControllerHeaderView == nil) return;
    NSAssert([self sw_getAssociatedScrollViewWithSubViewController:subViewController] == nil, @"同一个subViewController不要关联多次");
    objc_setAssociatedObject(subViewController, @selector(sw_getAssociatedScrollViewWithSubViewController:), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.topTitleView addObserver:self.observer forKeyPath:@"frame" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void * _Nullable)(subViewController)];
    objc_setAssociatedObject(self.topTitleView, @selector(topTitleView), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    //bug fix
    //在subViewController刚刚viewDidLoad的时候,改变UIScrollView的contentOffset,会被重置,所以延时执行解决这个问题
    scrollView.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        scrollView.hidden = NO;
        [self updateSubViewControllerScrollViewContentOffset:scrollView];
    });
}

- (void)updateHeaderViewFrame {
    CGRect headerViewFrame = _multiControllerHeaderView.frame;
    headerViewFrame.origin = CGPointZero;
    headerViewFrame.size.width = self.view.bounds.size.width;
    if(headerViewFrame.size.height <= 0){
        headerViewFrame.size.height = 200;
    }
    _multiControllerHeaderView.frame = headerViewFrame;
    [self.subViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIScrollView *scrollView = [self sw_getAssociatedScrollViewWithSubViewController:obj];
        if(scrollView){
            [self updateSubViewControllerScrollViewContentOffset:scrollView];
        }
    }];
}

- (void)setMultiControllerHeaderView:(UIView *)multiControllerHeaderView {
    if(_multiControllerHeaderView){
        [_multiControllerHeaderView removeFromSuperview];
    }
    _multiControllerHeaderView = multiControllerHeaderView;
    if(_multiControllerHeaderView.superview == nil){
        [self.view insertSubview:_multiControllerHeaderView aboveSubview:self.scrollBgView];
    }
    [self updateHeaderViewFrame];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [_multiControllerHeaderView addGestureRecognizer:panGesture];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    CGPoint velocity = [gesture velocityInView:gesture.view];
    UIViewController *vc = self.subViewControllers[self.selectedIndex];
    UIScrollView *scrollView = [self sw_getAssociatedScrollViewWithSubViewController:vc];
    if(scrollView == nil) return;
    CGPoint contentOffset = scrollView.contentOffset;
    contentOffset.y -= translation.y;
    if(contentOffset.y < -scrollView.contentInset.top){
        contentOffset.y = - scrollView.contentInset.top;
    }
    [scrollView setContentOffset:contentOffset animated:NO];
    if(gesture.state == UIGestureRecognizerStateChanged){
        [gesture setTranslation:CGPointZero inView:gesture.view];
    }else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        NSLog(@"%f",velocity.y);
        if(velocity.y < -1000){
            [scrollView setContentOffset:CGPointMake(0, -[self topTitleViewHeight] - [self topTitleViewFloatOffsetY]) animated:YES];
        }else if (velocity.y > 1000){
            [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:YES];
        }
    }
}

#pragma mark - dealloc
- (void)dealloc {
    NSLog(@"%s",__func__);
    [self removeObserver:self.observer forKeyPath:@"selectedIndex"];
    @try {
        if([objc_getAssociatedObject(self.topTitleView, @selector(topTitleView)) boolValue]){
            //移除所有包含context的通知
            [self.topTitleView removeObserver:self.observer forKeyPath:@"frame"];
        }
    } @catch (NSException *exception) {
        NSLog(@"removeObserverException:%@",exception);
    } @finally {
        
    }
}


@end

