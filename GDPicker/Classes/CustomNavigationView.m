//
//  CustomNavigationView.m
//  LefenStore1.0
//
//  Created by LGY on 2017/10/19.
//  Copyright © 2017年 lefen58.com. All rights reserved.
//

#import "CustomNavigationView.h"

@implementation CustomNavigationView

#pragma mark -- init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    self.backgroundColor = [UIColor whiteColor];
    [self.cusNavView addSubview:self.left0Btn];
    [self.cusNavView addSubview:self.titleLab];
    [self.cusNavView addSubview:self.rightTitleBtn];
    [self addSubview:self.bgImg];
    [self addSubview:self.cusNavView];
    [self addSubview:self.btmLine];

}

#pragma mark -- handleAction

- (void)cus_setNavBackgroundColor:(UIColor *)color {
    self.backgroundColor = color;
}

- (void)cus_setNavBackgroundImage:(UIImage *)image {
    if (image) {
        self.bgImg.image = image;
    }
}

- (void)cus_setNavTintColor:(UIColor *)color
{
    if (color) {
        self.left0Btn.tintColor = color;
        self.rightTitleBtn.tintColor = color;
    }
}

- (void)cus_setNavTitleColor:(UIColor *)color
{
    if (color) {
        self.titleLab.textColor = color;
    }
}

- (void)handleBack:(id)sender
{
    if (self.handleBackBlock) {
        self.handleBackBlock();
    }
}


- (void)handleRightTitleBtn:(id)sender
{
    if (self.handleRightTitleBlock) {
        self.handleRightTitleBlock();
    }
}

#pragma mark -- lazyLoad

- (UIView *)cusNavView
{
    if (!_cusNavView) {
        _cusNavView = [[UIView alloc] initWithFrame:CGRectMake(0, GDStatusBarHeight, GDSCR_W, 44)];
    }
    return _cusNavView;
}

-(UIView *)btmLine
{
    if (!_btmLine) {
        _btmLine = [[UIView alloc] initWithFrame:CGRectMake(0, GDStatusBarHeight + 43.5, GDSCR_W, 0.5)];
        _btmLine.backgroundColor = GDLineColor;
        _btmLine.hidden = NO;
    }
    return _btmLine;
}

- (UIButton *)left0Btn
{
    if (!_left0Btn) {
        _left0Btn = [UIButton buttonWithType:UIButtonTypeSystem];
        _left0Btn.frame = CGRectMake(0, 0, 44, 44);
        _left0Btn.contentMode = UIViewContentModeScaleAspectFit;
        _left0Btn.titleLabel.font = [UIFont systemFontOfSize:14];
        _left0Btn.titleLabel.textColor = GDImportantColor;
        _left0Btn.tintColor = GDImportantColor;
        
        NSBundle *podBundlu = [NSBundle bundleForClass:[self class]];
        NSString *iconPath = [podBundlu pathForResource:@"gdback@2x.png" ofType:nil inDirectory:@"GDPicker.bundle"];
        UIImage *icon = [UIImage imageWithContentsOfFile:iconPath];
        [_left0Btn setImage:icon forState:UIControlStateNormal];
        [_left0Btn addTarget:self action:@selector(handleBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _left0Btn;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(88, 0, GDSCR_W - 176, 44)];
        _titleLab.textColor = GDImportantColor;
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIButton *)rightTitleBtn
{
    if (!_rightTitleBtn) {
        _rightTitleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightTitleBtn.frame = CGRectMake(GDSCR_W-66-10, 7, 66, 30);
        _rightTitleBtn.contentMode = UIViewContentModeScaleAspectFit;
        _rightTitleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightTitleBtn.titleLabel.textColor = GDImportantColor;
        _rightTitleBtn.tintColor = GDImportantColor;
        [_rightTitleBtn addTarget:self action:@selector(handleRightTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_rightTitleBtn sizeToFit];
    }
    return _rightTitleBtn;
}


@end
