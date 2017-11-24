//
//  TipView.m
//  LightWallPaper
//
//  Created by 张帆 on 2017/5/25.
//  Copyright © 2017年 adesk. All rights reserved.
//
#define GDSCR_W [[UIScreen mainScreen] bounds].size.width

#import "TipView.h"

@interface TipView ()

@property (nonatomic, strong)UIImageView *tipIcon;
@property (nonatomic, strong)UILabel *tipInfo;
@property (nonatomic, strong)UIActivityIndicatorView *loaning;

@end

@implementation TipView // k_w * 150

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _tipIcon = [[UIImageView alloc]initWithFrame:CGRectMake(GDSCR_W/2-40, 150-40-20-80, 80, 80)];
        _tipIcon.contentMode = UIViewContentModeScaleAspectFill;
        _tipIcon.userInteractionEnabled = YES;
        
        _tipInfo = [[UILabel alloc]initWithFrame:CGRectMake(0, 150-50, GDSCR_W, 50)];
        _tipInfo.textAlignment = NSTextAlignmentCenter;
        _tipInfo.numberOfLines = 2;
        _tipInfo.lineBreakMode = NSLineBreakByCharWrapping;
        _tipInfo.textColor = [UIColor whiteColor];
        
        _loaning = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(GDSCR_W/2-20, 150/2-20, 40, 40)];
        _loaning.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        
        [self addGesture];
        [self addSubview:_tipIcon];
        [self addSubview:_tipInfo];
        [self addSubview:_loaning];
        self.hidden = YES;
    }
    
    return self;
}


- (void)addGesture {

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}


#pragma mark - state

- (void)stateNoResult {
    [_tipIcon setImage:[UIImage imageNamed:@"noresult"]];
    _tipInfo.text = @"还没有任何内容呢～";
    [self basicTipSetting];
    
}

- (void)stateNoFavor {
    [_tipIcon setImage:[UIImage imageNamed:@"nofavor"]];
    _tipInfo.text = @"还没有任何收藏呢~";
    [self basicTipSetting];
}

- (void)stateNoNet {
    [_tipIcon setImage:[UIImage imageNamed:@"nonet"]];
    _tipInfo.text = @"网络错误，请检查网络\n点击重试";
    [self basicTipSetting];
}

- (void)stateLoading {
    self.tipIcon.hidden = self.tipInfo.hidden = YES;
    self.hidden = self.loaning.hidden = NO;
    [self.loaning startAnimating];
}

- (void)stateHide {
    if (!self.loaning.hidden) {
        [self.loaning stopAnimating];
        self.loaning.hidden = YES;
    }
    self.hidden = YES;
}

#pragma mark - tap action

- (void)basicTipSetting {
    self.hidden = self.tipIcon.hidden = self.tipInfo.hidden = NO;
    
    if (!self.loaning.hidden) {
        [self.loaning stopAnimating];
        self.loaning.hidden = YES;
    }
}

- (void)tapAction {
    
    [_delegate touchTipView];
}

@end
