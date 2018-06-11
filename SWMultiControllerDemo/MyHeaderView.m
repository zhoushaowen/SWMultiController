//
//  MyHeaderView.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/6/7.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "MyHeaderView.h"

@implementation MyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}

@end
