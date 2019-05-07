//
//  GDUtils.h
//  GDPicker
//
//  Created by 张帆 on 2017/11/27.
//

#import <Foundation/Foundation.h>
@import Photos;

@interface GDUtils : NSObject


/**
 phasset的size按比例缩小后的值
 @param maxWidth width的最大值
 @param asset phasset对象
 @return 按比例缩小后的值
 */
+ (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset;


/** 从phasset数组-->img数组
 * phasset : PHAsset数组
 *
 */
+ (void)imgsWithPhassetArr:(NSArray *)phassetArr completion:(void (^)(NSMutableArray *images))completionBlock;


/** 从phasset返回所有连拍图片
 * phasset : 从相册取到的连拍代表
 *  : 所有的连拍图片
 */
+ (void)burstimgsWithPhasset:(PHAsset *)phasset completion:(void (^)(NSMutableArray *images))completionBlock;

@end
