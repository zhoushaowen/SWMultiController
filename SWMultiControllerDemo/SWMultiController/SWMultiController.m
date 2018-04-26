//
//  SWMultiController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SWMultiController.h"

@interface SWMultiController ()

@property (nonatomic,strong) UIView *topTitleView;
@property (nonatomic,strong) UIScrollView *scrollBgView;
@property (nonatomic,strong) UIScrollView *topTitleScrollView;
@property (nonatomic) UIView *titleBottomView;
@property (nonatomic,copy) NSArray<UIViewController *> *subViewControllers;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL shouldIgnoreContentOffset;
@property (nonatomic,weak) id orientationObserver;
@property (nonatomic) UIDeviceOrientation currentOrientation;

@end

@implementation SWMultiController

- (instancetype)initWithSubControllers:(NSArray<UIViewController *> *)subControllers {
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        self.selectedIndex = - 1;
        self.subViewControllers = subControllers;
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
        scroll.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        if(self.navigationController.interactivePopGestureRecognizer){
            [scroll.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
        }
        [self.view addSubview:scroll];
        scroll;
    });
    self.topTitleView = ({
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, 0, self.view.bounds.size.width, [self topTitleViewHeight]);
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
        scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
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
//    [self addObserver];
}

- (void)addObserver {
    self.currentOrientation = [UIDevice currentDevice].orientation;
    __weak typeof(self) weakSelf = self;
    _orientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if(strongSelf.currentOrientation == UIDeviceOrientationUnknown) return;
        if(strongSelf.currentOrientation == [UIDevice currentDevice].orientation) return;
        strongSelf.currentOrientation = [UIDevice currentDevice].orientation;
        if(!strongSelf.isViewLoaded) return;
        [strongSelf.scrollBgView setContentSize:CGSizeMake(strongSelf.view.bounds.size.width*strongSelf.subViewControllers.count, 0)];
        strongSelf.shouldIgnoreContentOffset = YES;
        [strongSelf.scrollBgView setContentOffset:CGPointMake(strongSelf.scrollBgView.bounds.size.width*strongSelf.selectedIndex, 0) animated:NO];
        [strongSelf.subViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(obj.parentViewController){
                obj.view.frame = CGRectMake(strongSelf.scrollBgView.bounds.size.width * idx, 0, strongSelf.scrollBgView.bounds.size.width, strongSelf.scrollBgView.bounds.size.height);
            }
        }];
        UILabel *label = (UILabel *)[strongSelf.topTitleView viewWithTag:strongSelf.selectedIndex + 100];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf setLabelToCenter:label];
        });
//        NSLog(@"%@",NSStringFromCGRect(strongSelf.scrollBgView.bounds));
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"%@",NSStringFromCGSize(size));
//    if(self.currentOrientation == [UIDevice currentDevice].orientation) return;
//    self.currentOrientation = [UIDevice currentDevice].orientation;
    if(!self.isViewLoaded) return;
    [self.scrollBgView setContentSize:CGSizeMake(size.width*self.subViewControllers.count, 0)];
    self.shouldIgnoreContentOffset = YES;
    [self.scrollBgView setContentOffset:CGPointMake(size.width*self.selectedIndex, 0) animated:NO];
    [self.subViewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.parentViewController){
            obj.view.frame = CGRectMake(size.width * idx, 0, size.width, size.height - [self topTitleViewHeight]);
        }
    }];
    UILabel *label = (UILabel *)[self.topTitleView viewWithTag:self.selectedIndex + 100];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setLabelToCenter:label];
    });

}

- (void)addTopTitleLabels {
    if(!self.isViewLoaded) return;
    if(self.subViewControllers.count < 1) return;
    __block CGFloat totalWidth = [self horizontalSpaceOfTitleLabel];
    [self.subViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
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
        totalWidth += size.width + [self horizontalSpaceOfTitleLabel];
    }];
    self.topTitleScrollView.contentSize = CGSizeMake(totalWidth, 0);
    CGRect rect = [self.topTitleScrollView viewWithTag:100].frame;
    self.titleBottomView.bounds = CGRectMake(0, 0, rect.size.width, [self titleBottomViewHeight]);
    self.titleBottomView.center = CGPointMake(CGRectGetMidX(rect), [self topTitleViewHeight] - [self verticalSpaceBetweenBottom]);
    self.scrollBgView.contentSize = CGSizeMake(self.view.bounds.size.width*self.subViewControllers.count, 0);
}

- (void)addSubViewContollerViewIfNeeded:(NSInteger)index {
    UIViewController *subVC = self.subViewControllers[index];
    if(subVC == nil) return;
    if(subVC.parentViewController == nil){
        [self addChildViewController:subVC];
        [subVC didMoveToParentViewController:self];
        [self.scrollBgView addSubview:subVC.view];
        subVC.view.frame = CGRectMake(self.scrollBgView.bounds.size.width*index, 0, self.scrollBgView.bounds.size.width, self.scrollBgView.bounds.size.height);
    }else{
        subVC.view.frame = CGRectMake(self.scrollBgView.bounds.size.width*index, 0, self.scrollBgView.bounds.size.width, self.scrollBgView.bounds.size.height);
    }
}

#pragma mark - Override
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

- (CGFloat)titleLabelBaselineOffset {
    return 0;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(![touch.view isKindOfClass:[UILabel class]]) return NO;
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_shouldIgnoreContentOffset){
        _shouldIgnoreContentOffset = NO;
        return;
    }
    if(scrollView.contentOffset.x < 0) return;
    NSInteger currentIndex = scrollView.contentOffset.x/scrollView.bounds.size.width;
    self.selectedIndex = currentIndex;
    UILabel *currentLabel = [self.topTitleScrollView viewWithTag:currentIndex + 100];
    UILabel *nextLabel = [self.topTitleScrollView viewWithTag:currentIndex + 100 + 1];
    if(!nextLabel) return;
    CGFloat percent = (scrollView.contentOffset.x - scrollView.bounds.size.width*currentIndex)/scrollView.bounds.size.width;
    currentLabel.font = [self getFontWithBeginFont:[self selectedFontOfTitleLabel] endFont:[self normalFontOfTitleLabel] percent:percent];
    nextLabel.font = [self getFontWithBeginFont:[self normalFontOfTitleLabel] endFont:[self selectedFontOfTitleLabel] percent:percent];
    currentLabel.textColor = [self getColorWithBeginColor:[self selectedColorOfTitleLabel] endColor:[self normalColorOfTitleLabel] percent:percent];
    nextLabel.textColor = [self getColorWithBeginColor:[self normalColorOfTitleLabel] endColor:[self selectedColorOfTitleLabel] percent:percent];
    [self changeTitleBottomViewWithCurrentIndex:currentIndex percent:percent currentLabel:currentLabel nextLabel:nextLabel];
    [self updateTopTitleScrollViewContentSize];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self addSubViewContollerViewIfNeeded:index];
    UILabel *label = [self.topTitleScrollView viewWithTag:index + 100];
    [self setLabelToCenter:label];
    if(_willDisplayControllerBlock){
        _willDisplayControllerBlock(self.subViewControllers[index],index);
    }
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
    CGFloat nextLabelWidth = [nextLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, [self topTitleViewHeight]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self selectedFontOfTitleLabel]} context:nil].size.width;
    CGFloat currentLabelWidth = [currentLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, [self topTitleViewHeight]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self selectedFontOfTitleLabel]} context:nil].size.width;
    CGFloat widthOffset = nextLabelWidth - currentLabelWidth;
    CGFloat nextLabelCenterX = 0;
    for(int i=0;i<currentIndex + 2;i++){
        UILabel *label = [self.topTitleScrollView viewWithTag:i + 100];
        CGFloat width = 0;
        if(i == (currentIndex + 1)){//如果是最后一个label,只需计算出label长度的一半
            width = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, [self topTitleViewHeight]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self selectedFontOfTitleLabel]} context:nil].size.width/2.0f;
        }else{
            width = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, [self topTitleViewHeight]) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self normalFontOfTitleLabel]} context:nil].size.width;
        }
        nextLabelCenterX += width + [self horizontalSpaceOfTitleLabel];
    }
    CGFloat centerXOffset = nextLabelCenterX - CGRectGetMidX(currentLabel.frame);
    CGRect bounds = self.titleBottomView.bounds;
    CGPoint center = self.titleBottomView.center;
    bounds.size.width = currentLabelWidth + percent * widthOffset;
    center.x = CGRectGetMidX(currentLabel.frame) + percent * centerXOffset;
    self.titleBottomView.bounds = bounds;
    self.titleBottomView.center = center;
}

- (void)updateTopTitleScrollViewContentSize {
    CGFloat totalWidth = [self horizontalSpaceOfTitleLabel];
    for(int i=0;i<self.subViewControllers.count;i++){
        UILabel *label = [self.topTitleScrollView viewWithTag:i + 100];
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, [self topTitleViewHeight])];
        label.frame = CGRectMake(totalWidth, 0, size.width, [self topTitleViewHeight]);
        totalWidth += size.width + [self horizontalSpaceOfTitleLabel];
    }
    self.topTitleScrollView.contentSize = CGSizeMake(totalWidth, 0);
}

- (void)setLabelToCenter:(UILabel *)label {
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
    [self.topTitleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    NSInteger index = gesture.view.tag - 100;
    [self selectedIndex:index];
}

#pragma mark - Public
- (void)selectedIndex:(NSInteger)index {
    if(index == self.selectedIndex) return;
    if(!self.isViewLoaded) return;
    _shouldIgnoreContentOffset = YES;
    [self.scrollBgView setContentOffset:CGPointMake(self.scrollBgView.bounds.size.width * index, 0) animated:NO];
    UILabel *currentLabel = (UILabel *)[self.topTitleScrollView viewWithTag:self.selectedIndex + 100];
    UILabel *nextLabel = (UILabel *)[self.topTitleScrollView viewWithTag:index + 100];
    currentLabel.font = [self getFontWithBeginFont:[self selectedFontOfTitleLabel] endFont:[self normalFontOfTitleLabel] percent:1.0f];
    nextLabel.font = [self getFontWithBeginFont:[self normalFontOfTitleLabel] endFont:[self selectedFontOfTitleLabel] percent:1.0f];
    currentLabel.textColor = [self getColorWithBeginColor:[self selectedColorOfTitleLabel] endColor:[self normalColorOfTitleLabel] percent:1.0f];
    nextLabel.textColor = [self getColorWithBeginColor:[self normalColorOfTitleLabel] endColor:[self selectedColorOfTitleLabel] percent:1.0f];
    [self changeTitleBottomViewWithCurrentIndex:self.selectedIndex percent:1.0 currentLabel:currentLabel nextLabel:nextLabel];
    [self updateTopTitleScrollViewContentSize];
    CGRect bounds = self.titleBottomView.bounds;
    CGPoint center = self.titleBottomView.center;
    bounds.size.width = nextLabel.bounds.size.width;
    center.x = CGRectGetMidX(nextLabel.frame);
    self.titleBottomView.bounds = bounds;
    self.titleBottomView.center = center;
    self.selectedIndex = index;
    [self addSubViewContollerViewIfNeeded:index];
    [self setLabelToCenter:nextLabel];
    if(_willDisplayControllerBlock){
        _willDisplayControllerBlock(self.subViewControllers[index], index);
    }
}

- (NSInteger)indexOfSubController:(UIViewController *)subController {
    return [self.subViewControllers indexOfObject:subController];
}

- (void)reloadWithSubViewControllers:(NSArray<UIViewController *> *)subViewControllers {
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
    self.selectedIndex = -1;
    [self addTopTitleLabels];
    [self selectedIndex:0];
}

- (void)setHiddenTitleBottomView:(BOOL)hiddenTitleBottomView {
    _hiddenTitleBottomView = hiddenTitleBottomView;
    self.titleBottomView.hidden = _hiddenTitleBottomView;
}

- (void)dealloc {
    if(self.isViewLoaded && _orientationObserver){
        [[NSNotificationCenter defaultCenter] removeObserver:_orientationObserver];
    }
    NSLog(@"%s",__func__);
}


@end
