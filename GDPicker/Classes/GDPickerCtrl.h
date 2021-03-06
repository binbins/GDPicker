//
//  GDPickerCtrl.h
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//


#import <UIKit/UIKit.h>
@import Photos;

typedef NS_ENUM(NSInteger, PickerType)
{
    PickerTypeSinglePhoto = 1,
    PickerTypeManyPhoto,
    PickerTypeVideo,
    PickerTypeBurst,
    PickerTypeLivephoto,
    PickerTypeGif,
};

@interface GDPickerCtrl : UIViewController
@property (nonatomic, assign) PickerType pickerType;

- (instancetype)initWithPickerType:(PickerType)typeType CompleteBlock:(void(^)(NSArray<PHAsset *> *resultArr))completeBlock;



/**
 模态弹出

 @param ctrl 当前控制器
 */
- (void)presentInCtrl:(UIViewController *)ctrl;


/**
 push弹出

 @param ctrl 当前控制器
 */
- (void)pushInCtrl:(UIViewController *)ctrl;








@end
