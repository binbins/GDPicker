//
//  GDPickerCtrl.h
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PickerType)
{
    PickerTypeSinglePhoto = 1,
    PickerTypeManyPhoto,
    PickerTypeVideo,
    PickerTypeBurst,
    PickeTypeLivephoto
};

@interface GDPickerCtrl : UIViewController
@property (nonatomic, assign)PickerType pickerType;

@end
