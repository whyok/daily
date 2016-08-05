//
//  ViewController.m
//  手势解锁
//
//  Created by heima on 16/7/14.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "HMView.h"
#import "ViewController.h"

@interface ViewController () <HMViewDelegate>
@property (weak, nonatomic) IBOutlet HMView* passwordView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // 设置背景图片的方式 平铺
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Home_refresh_bg"]];
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"me"]];

    // 拉伸
    //    self.view.layer.contents = (__bridge id)[UIImage imageNamed:@"me"].CGImage;

    // 密码应该在这里

    //    self.passwordView.delegate = self;

    __weak ViewController* weakSelf = self;
    self.passwordView.pwdBlock = ^(NSString* pwd) {
        if ([pwd isEqualToString:@"2587"]) {
            // 正确
            NSLog(@"正确 ");

            UIViewController* vc = [[UIViewController alloc] init];
            // 跳转样式
            vc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
            vc.view.backgroundColor = [UIColor redColor];

            // 不依赖与导航控制器的跳转(两个普通控制器的跳转)
            [weakSelf presentViewController:vc animated:YES completion:^{
                NSLog(@"跳转完成");
            }];

            return YES;
        }
        else {
            // 错误
            NSLog(@"错误 ");
            return NO;
        }

    };
}

- (BOOL)hmview:(HMView*)hmview withPwd:(NSString*)pwd
{
    if ([pwd isEqualToString:@"2587"]) {
        // 正确
        NSLog(@"正确 ");

        UIViewController* vc = [[UIViewController alloc] init];
        // 跳转样式
        vc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        vc.view.backgroundColor = [UIColor redColor];

        // 不依赖与导航控制器的跳转(两个普通控制器的跳转)
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"跳转完成");
        }];

        return YES;
    }
    else {
        // 错误
        NSLog(@"错误 ");
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
