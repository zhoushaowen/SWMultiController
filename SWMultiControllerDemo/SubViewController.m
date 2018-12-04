//
//  SubViewController.m
//  SWMultiControllerDemo
//
//  Created by zhoushaowen on 2018/4/23.
//  Copyright © 2018年 zhoushaowen. All rights reserved.
//

#import "SubViewController.h"
#import "SWMultiController.h"
#import <MJRefresh.h>

@interface SubViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
}
@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0f green:arc4random_uniform(256)/255.0f blue:arc4random_uniform(256)/255.0f alpha:1.0];
    [self.multiController associateSubViewController:self withScrollView:_tableView];
    [self.view addSubview:_tableView];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
//    [_tableView.mj_header beginRefreshing];
}

- (void)refresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView.mj_header endRefreshing];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"%s---index:%ld",__func__,[self.multiController indexOfSubController:self]);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    NSLog(@"%s---index:%ld",__func__,[self.multiController indexOfSubController:self]);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"%s---index:%ld",__func__,[self.multiController indexOfSubController:self]);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    NSLog(@"%s---index:%ld",__func__,[self.multiController indexOfSubController:self]);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == _tableView){
        [self.multiController subViewController:self scrollViewDidScroll:scrollView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.multiController indexOfSubController:self] == 0)
    return 30;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    if(indexPath.row % 2 == 0){
        cell.textLabel.text = @"Present";
    }else{
        cell.textLabel.text = @"Dismiss";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row % 2 == 0){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"multi"];
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        if(self.presentingViewController){
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
