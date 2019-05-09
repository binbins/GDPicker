//
//  CustomNavigationView.m
//  LefenStore1.0
//
//  Created by LGY on 2017/10/19.
//  Copyright © 2017年 lefen58.com. All rights reserved.
//

#import "GDNavView.h"

@implementation GDNavView

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
    
    self.backgroundColor = GDHEX(0xf6f6f6);
    [self.cusNavView addSubview:self.left0Btn];
    [self.cusNavView addSubview:self.titleLab];
    [self.cusNavView addSubview:self.rightTitleBtn];
    _rightTitleBtn.frame = CGRectMake(GDSCR_W-66-10, 7, 66, 30);
    
    [self addSubview:self.bgImg];
    [self addSubview:self.cusNavView];
    [self addSubview:self.btmLine];

}

#pragma mark -- handleAction

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
        
        NSString *iconPath = [[NSBundle bundleForClass:self.class] pathForResource:@"gdback@2x.png" ofType:nil inDirectory:@"GDPicker.bundle"];
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
        _rightTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightTitleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_rightTitleBtn setTitleColor:GDImportantColor forState:UIControlStateNormal];
        [_rightTitleBtn addTarget:self action:@selector(handleRightTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_rightTitleBtn sizeToFit];
    }
    return _rightTitleBtn;
}


@end
