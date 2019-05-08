//
//  CustomNavigationView.h
//  LefenStore1.0
//
//  Created by LGY on 2017/10/19.
//  Copyright © 2017年 lefen58.com. All rights reserved.
//

//颜色
#define GDHEXA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(float)alphaValue]
#define GDHEX(rgbValue) GDHEXA(rgbValue, 1.0)

#define GDImportantColor GDHEX(0x333333)
#define GDLineColor GDHEX(0xe7e7e7)

//固定尺寸
#define GDSCR_W [[UIScreen mainScreen] bounds].size.width
#define GDSCR_H [[UIScreen mainScreen] bounds].size.height
#define GDiPhoneX (GDSCR_H > 800)
#define GDStatusBarHeight (GDiPhoneX ? 44.f : 20.0f)
#define GDNavigationBarHeight (GDiPhoneX ? 88.f : 64.f)
#define GDTabBarHeight (GDiPhoneX ? (83.f) : 49.f)
#define GDHomeIndicatorHeight (GDiPhoneX ? 34.f : 0.f)

#import <UIKit/UIKit.h>


@interface CustomNavigationView : UIView

@property (strong, nonatomic) UIImageView *bgImg;
@property (strong, nonatomic) UIView *cusNavView;
@property (strong, nonatomic) UIView *btmLine;

@property (strong, nonatomic) UIButton *left0Btn;
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UIButton *rightTitleBtn;

@property (copy, nonatomic) void (^handleBackBlock)(void);
@property (copy, nonatomic) void (^handleRightTitleBlock)(void);

- (void)cus_setNavBackgroundColor:(UIColor *)color;

- (void)cus_setNavBackgroundImage:(UIImage *)image;

- (void)cus_setNavTintColor:(UIColor *)color;

- (void)cus_setNavTitleColor:(UIColor *)color;


@end
