//
//  GDUtils.m
//  GDPicker
//
//  Created by 张帆 on 2017/11/27.
//

#import "GDUtils.h"

@implementation GDUtils

+ (CGSize)sizeMaxWidth:(float)maxWidth withAsset:(PHAsset *)asset {
    
    NSInteger scale = 1;
    for (int i=1; i<CGFLOAT_MAX; i++) {
        float nowWidth = asset.pixelWidth / i;
        if (nowWidth < maxWidth) {
            scale = i;
            break;
        }
    }
    CGSize size = CGSizeMake(asset.pixelWidth/scale, asset.pixelHeight/scale);
    //    NSLog(@"size%@， 缩小倍数%ld", NSStringFromCGSize(size), (long)scale);
    return size;
}

+ (void)imgsWithPhassetArr:(NSArray *)phassetArr completion:(void (^)(NSMutableArray *images))completionBlock {
    
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;

    NSMutableArray *resultImgs = [NSMutableArray array];
    NSUInteger imgCount = phassetArr.count;
    for (int i = 0; i<imgCount; i++) {
        PHAsset *each = [phassetArr objectAtIndex:i];
        NSLock *threadLock = [[NSLock alloc] init];
        CGSize targetSize = [GDUtils sizeMaxWidth:250.f withAsset:each];
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [threadLock lock];
            if (result) {
                [resultImgs addObject:result];
            }
            if (resultImgs.count == imgCount){
                completionBlock(resultImgs);
            }
            [threadLock unlock];
        }];
    }
    
    if (imgCount == 0) {
        completionBlock(nil);
    }
}

+ (void)burstimgsWithPhasset:(PHAsset *)phasset completion:(void (^)(NSMutableArray *images))completionBlock {
    NSMutableArray *resultImgs = [NSMutableArray array];
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.includeAllBurstAssets = YES;
    fetchOptions.sortDescriptors =  @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithBurstIdentifier:phasset.burstIdentifier options:fetchOptions];
    NSUInteger burstCount = fetchResult.count;
    burstCount = burstCount>30? 30 :burstCount;
    
    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
    requestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    NSLock *threadLock = [[NSLock alloc] init];
    for (int i = 0; i<burstCount; i++) {
        PHAsset *each = [fetchResult objectAtIndex:i];
        CGSize targetSize = [GDUtils sizeMaxWidth:300.0f withAsset:each];//尺寸大容易崩溃
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [threadLock lock];
            if (result) {
                [resultImgs addObject:result];
            }
            if (resultImgs.count == burstCount){
                completionBlock(resultImgs);
            }
            //            NSLog(@"phasset 转 图片---%@", index);
            [threadLock unlock];
        }];
    }
    if (burstCount == 0) {
        completionBlock(nil);
    }
}


@end
