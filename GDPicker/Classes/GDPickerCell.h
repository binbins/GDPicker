//
//  GDPickerCell.h
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//

#import <UIKit/UIKit.h>
#import "GDPickerCtrl.h"
@import Photos;

@interface GDPickerCell : UICollectionViewCell
@property (nonatomic, assign) PickerType pickType;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) NSUInteger selectedOrder;

- (void)setPickerType:(PickerType)pickType andPHAsset:(PHAsset *)asset;

@end
