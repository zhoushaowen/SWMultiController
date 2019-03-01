//
//  MyHeaderView.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/6/7.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "MyHeaderView.h"

@implementation MyHeaderView
{
    UIImageView *_imgV;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
        _imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg"]];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.layer.masksToBounds = YES;
        [self addSubview:_imgV];
    }
    return self;
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imgV.frame = self.bounds;
}

@end
