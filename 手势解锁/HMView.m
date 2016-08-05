//
//  HMView.m
//  手势解锁
//
//  Created by heima on 16/7/14.
//  Copyright © 2016年 itcast. All rights reserved.
//

#import "HMView.h"

@interface HMView ()

@property (nonatomic, strong) NSMutableArray* lineBtns; // 需要连线的btn

@property (nonatomic, assign) CGPoint currentPoint; // 手指当前的位置

@end

@implementation HMView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupUI];
}

// 初始化UI
- (void)setupUI
{
    // 初始化数据
    _lineBtns = [NSMutableArray array];

    for (int i = 0; i < 9; i++) {
        UIButton* btn = [[UIButton alloc] init];
        // 设置tag(方便判断密码,相当于让每一个按钮都有唯一的表示)
        btn.tag = i;
        // 设置按钮背景图片
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_error"] forState:UIControlStateSelected];
        // 关闭用户交互,通过view的触摸事件去做
        [btn setUserInteractionEnabled:NO];
        [self addSubview:btn];
    }
}

// 画线
- (void)drawRect:(CGRect)rect
{

    // 创建路径
    UIBezierPath* path = [UIBezierPath bezierPath];

    for (int i = 0; i < self.lineBtns.count; ++i) {

        if (i == 0) {
            // 起点就是第一个按钮的中心点
            [path moveToPoint:[[self.lineBtns firstObject] center]];
        }

        [path addLineToPoint:[self.lineBtns[i] center]];
    }

    // 如果没有起点 不要进行 addLineToPoint 会报警告

    // 判断 需要连线的数组当中 是否已经有了 可以画线的点 如果没有 就不要 addline
    if (self.lineBtns.count) {
        // 最后再画一个手指的位置
        [path addLineToPoint:_currentPoint];
    }

    // 设置样式
    [path setLineWidth:10];
    [path setLineCapStyle:kCGLineCapRound];
    [path setLineJoinStyle:kCGLineJoinRound];
    [[UIColor whiteColor] set];

    // 渲染
    [path stroke];
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    // 获取触摸对象
    UITouch* t = touches.anyObject;

    // 获取手指触摸的位置
    CGPoint p = [t locationInView:t.view];

    for (int i = 0; i < self.subviews.count; i++) {
        // 获取到每一个按钮
        UIButton* btn = self.subviews[i];

        // 判断  手指得位置 是不是在某个按钮之内
        if (CGRectContainsPoint(btn.frame, p)) {
            // 如果手指得位置 在某个按钮的frame之内 那么让这个高亮(蓝色图片)
            btn.highlighted = YES;

            //            // 这个btn的中心点
            //            NSValue* centerPoint = [NSValue valueWithCGPoint:btn.center];
            // 判断这个点如果已经在数组中,那么不添加需要画线的点

            if (![self.lineBtns containsObject:btn]) {
                // 把这个按钮的中心点 添加到数组中
                [self.lineBtns addObject:btn];
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{

    // 获取触摸对象
    UITouch* t = touches.anyObject;

    // 获取手指触摸的位置
    CGPoint p = [t locationInView:t.view];

    // 记录手指最新的位置
    _currentPoint = p;

    for (int i = 0; i < self.subviews.count; i++) {
        // 获取到每一个按钮
        UIButton* btn = self.subviews[i];

        // 判断  手指得位置 是不是在某个按钮之内
        if (CGRectContainsPoint(btn.frame, p)) {
            // 如果手指得位置 在某个按钮的frame之内 那么让这个高亮(蓝色图片)
            btn.highlighted = YES;

            //            // 这个btn的中心点
            //            NSValue* centerPoint = [NSValue valueWithCGPoint:btn.center];
            // 判断这个点如果已经在数组中,那么不添加需要画线的点

            if (![self.lineBtns containsObject:btn]) {
                // 把这个按钮的中心点 添加到数组中
                [self.lineBtns addObject:btn];
            }
        }
    }

    // 刷新
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{

    NSString* pwd = @"";

    // 输出密码
    for (int i = 0; i < self.lineBtns.count; i++) {
        UIButton* btn = self.lineBtns[i];

        // 拼接密码
        pwd = [pwd stringByAppendingFormat:@"%zd", btn.tag];
    }

    // 把密码传到控制器中
    // 执行代理
    if ([self.delegate respondsToSelector:@selector(hmview:withPwd:)]) {
        if ([self.delegate hmview:self withPwd:pwd]) {
            // 都恢复到初始状态
            [self clear];

            // 不设置错误状态
            return;
        }
    }

    // 执行
    if (self.pwdBlock) {

        if (self.pwdBlock(pwd)) {
            // 都恢复到初始状态
            [self clear];

            // 不设置错误状态
            return;
        }
    }

    NSLog(@"%@", pwd);
    //
    //    if ([@"012" isEqualToString:pwd]) {
    //
    //
    //    }

    // 取消最后连线到手指的位置
    // 方法: 把最后的位置 改变成 数组中最后一个按钮的重点 (取巧)
    _currentPoint = [[self.lineBtns lastObject] center];
    // 刷新
    [self setNeedsDisplay];

    // 关闭用户交互(解决错误以后还能连线的问题)
    self.userInteractionEnabled = NO;

    // 所有需要连线的btn改变状态
    for (int i = 0; i < self.lineBtns.count; ++i) {
        UIButton* btn = self.lineBtns[i];

        // 记得都设置
        // 恢复高亮状态的同时设置选中
        btn.highlighted = NO;
        btn.selected = YES;
    }

    // 延时取消掉所有的状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self clear];

        // 所有状态都恢复之后, 再去开启用户交互(可以编辑)
        self.userInteractionEnabled = YES;
    });
}

// 恢复到最原始的状态
- (void)clear
{
    // 所有的按钮到最原始的状态
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton* btn = self.subviews[i];

        btn.highlighted = NO;
        btn.selected = NO;
    }

    // 所有的连线都恢复到初始状态
    // 把需要连线的数组都清空 再刷新
    [self.lineBtns removeAllObjects];
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // 设置子控件的frame

    CGFloat w = 74;
    CGFloat h = w;
    int colCount = 3;
    CGFloat margin = (self.frame.size.width - 3 * w) / 4;

    for (int i = 0; i < self.subviews.count; i++) {
        UIButton* btn = self.subviews[i];
        CGFloat x = (i % colCount) * (margin + w) + margin;
        CGFloat y = (i / colCount) * (margin + w) + margin;
        [btn setFrame:CGRectMake(x, y, w, h)];
    }
}

@end
