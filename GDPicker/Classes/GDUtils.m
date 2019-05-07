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
    requestOptions.networkAccessAllowed = YES;

    NSMutableArray *resultImgs = [NSMutableArray array];
    NSUInteger imgCount = phassetArr.count;
    
    dispatch_group_t group = dispatch_group_create();   //所以异步操作完成后，执行动作
    NSConditionLock *cLock = [[NSConditionLock alloc] initWithCondition:0]; //按顺序处理回调结果
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i<imgCount; i++) {
        PHAsset *each = [phassetArr objectAtIndex:i];
        CGSize targetSize = [GDUtils sizeMaxWidth:250.f withAsset:each];
//        NSLog(@"开始转化:%d", i);
        dispatch_group_enter(group);
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            NSLog(@"得到结果:%d", i);
            
            dispatch_async(queue, ^{
                [cLock lockWhenCondition:i];
                if (result) {
                    [resultImgs addObject:result];
//                    NSLog(@"使用结果:%d", i);
                }
                [cLock unlockWithCondition:i+1];
                dispatch_group_leave(group);
            });
            
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionBlock(resultImgs);
    });
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
    requestOptions.networkAccessAllowed = YES;
    
    dispatch_group_t group = dispatch_group_create();
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<burstCount; i++) {
        PHAsset *each = [fetchResult objectAtIndex:i];
        CGSize targetSize = [GDUtils sizeMaxWidth:300.0f withAsset:each];//尺寸大容易崩溃
        dispatch_group_enter(group);
        
        [[PHImageManager defaultManager] requestImageForAsset:each targetSize:targetSize contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(queue, ^{
//                NSLog(@"得到结果:%d", i);
                
                [lock lockWhenCondition:i];
                if (result) {
                    [resultImgs addObject:result];
//                    NSLog(@"使用结果:%d", i);
                }
                dispatch_group_leave(group);
                [lock unlockWithCondition:i+1];
            });
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completionBlock(resultImgs);
    });
}


@end
