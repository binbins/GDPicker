//
//  TipView.h
//  LightWallPaper
//
//  Created by 张帆 on 2017/5/25.
//  Copyright © 2017年 adesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TipViewDelegate <NSObject>

- (void)touchTipView;

@end


@interface TipView : UIView
@property (nonatomic, weak) id<TipViewDelegate> delegate;

- (void)stateNoResult;

- (void)stateNoFavor;

- (void)stateNoNet;

- (void)stateLoading;

- (void)stateHide;

@end
