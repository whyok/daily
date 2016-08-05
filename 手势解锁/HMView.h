//
//  HMView.h
//  手势解锁
//
//  Created by heima on 16/7/14.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HMView;

// 1.协议
// 2.协议- 代理方法
// 3.id属性
// 4.执行
// 5.使用\

@protocol HMViewDelegate <NSObject>

@optional
- (BOOL)hmview:(HMView*)hmview withPwd:(NSString*)pwd;

@end

@interface HMView : UIView

@property (nonatomic, weak) id<HMViewDelegate> delegate;

@property (nonatomic, copy) BOOL (^pwdBlock)(NSString* );

@end
