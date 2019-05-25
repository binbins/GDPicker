//
//  GDPickerCell.m
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//

#import "GDPickerCell.h"
#import "GDUtils.h"
#import "PHAsset+gd_bool.h"

@interface GDPickerCell ()
@property (weak, nonatomic) IBOutlet UIImageView *liveMark;
@property (weak, nonatomic) IBOutlet UILabel *burstCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImg;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *selectedView;
@property (weak, nonatomic) IBOutlet UILabel *markOrder;
@property (weak, nonatomic) IBOutlet UIImageView *duihao;

@property (weak, nonatomic) IBOutlet UIView *icloudView;
@property (weak, nonatomic) IBOutlet UILabel *icloudTip;


@end

@implementation GDPickerCell


- (UIImage *)imageForName:(NSString *)imgName {
    // xib中的图片要添加所属bundle eg: GDPicker.bundle/done.png
    
//    UIScreen.mainScreen.scale
    NSString *iconPath = [[NSBundle bundleForClass:self.class] pathForResource:imgName ofType:nil inDirectory:@"GDPicker.bundle"];
    UIImage *result = [UIImage imageWithContentsOfFile:iconPath];
    return result;
}

- (void)setPickerType:(PickerType)pickType andPHAsset:(PHAsset *)asset {
    _pickType = pickType;
    _asset = asset;
    
    [self initCloudView];
    [self initCoverImg];
    
    if (_pickType == PickerTypeLivephoto) {
        _liveMark.hidden = NO;
        
    }else if (_pickType == PickerTypeVideo){
        _videoTimeLabel.hidden = _shadowView.hidden = NO;
        [self initTimeLabel];
        
    }else if (_pickType == PickerTypeBurst) {
        _burstCountLabel.hidden = _shadowView.hidden = NO;
        [self initBurstCountLabel];
    }
}

- (void)setSelectedOrder:(NSUInteger)selectedOrder {
    _selectedOrder = selectedOrder;
    
    if (selectedOrder>0) {
        _selectedView.hidden = _duihao.hidden = NO;
        _markOrder.text = [NSString stringWithFormat:@"%lu",(unsigned long) selectedOrder];
    }else {
        _selectedView.hidden = _duihao.hidden = YES;
    }
}


#pragma mark - iCloud

- (void)initCloudView {
    
    self.icloudTip.hidden = YES;
    //判断是否在iCloud中
    __weak typeof(self) weakSelf = self;
    
    if (_pickType==PickerTypeManyPhoto || _pickType==PickerTypeSinglePhoto || _pickType==PickerTypeBurst || _pickType==PickerTypeGif) {
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = NO;   //是no
        option.synchronous = NO;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isInLocalAblum = imageData ? YES : NO;
                weakSelf.icloudView.hidden = isInLocalAblum;
                if (!imageData && weakSelf.asset.gd_onLoading) {
                    weakSelf.icloudTip.hidden = NO;
                }
            });
        }];
    }
    else if (_pickType == PickerTypeVideo) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.networkAccessAllowed = NO;   //是no
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isInLocalAblum = asset ? YES : NO;
                weakSelf.icloudView.hidden = isInLocalAblum;
                
                if (!asset && weakSelf.asset.gd_onLoading) {
                    weakSelf.icloudTip.hidden = NO;
                }
            });
        }];
    }
    else if (_pickType == PickerTypeLivephoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
            option.networkAccessAllowed = NO;   //是no
            
            [[PHImageManager defaultManager] requestLivePhotoForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option
                                                        resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isInLocalAblum = livePhoto ? YES : NO;
                    weakSelf.icloudView.hidden = isInLocalAblum;
                    
                    if (!livePhoto && weakSelf.asset.gd_onLoading) {
                        weakSelf.icloudTip.hidden = NO;
                    }
                });
            }];
        } else {
            // Fallback on earlier versions
            //不管9.1以下的了
        }
    }
    
    
}

- (IBAction)downloadiCloud:(id)sender {
    __weak typeof(self) weakSelf = self;
    if (_asset.gd_onLoading) {
        return;
    }
    _asset.gd_onLoading = YES;
    
    if (_pickType==PickerTypeManyPhoto || _pickType==PickerTypeSinglePhoto || _pickType==PickerTypeBurst || _pickType==PickerTypeGif) {
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        option.synchronous = NO;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.icloudTip.hidden = NO;
            });
        };
        
        [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            if (imageData) {
                weakSelf.asset.gd_onLoading = NO;
                [weakSelf refreshCellWhenCloudDone];
            }
        }];
    }   //image
    
    else if (_pickType == PickerTypeVideo) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
        option.version = PHVideoRequestOptionsVersionOriginal;
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        option.networkAccessAllowed = YES;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.icloudTip.hidden = NO;
            });
        };
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:option resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (asset) {
                weakSelf.asset.gd_onLoading = NO;
                [weakSelf refreshCellWhenCloudDone];
            }
        }];
    }   //video
    
    else if (_pickType == PickerTypeLivephoto) {
        if (@available(iOS 9.1, *)) {
            PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
            option.networkAccessAllowed = YES;
            option.version = PHImageRequestOptionsVersionOriginal;
            option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.icloudTip.hidden = NO;
                });
            };
            
            [[PHImageManager defaultManager] requestLivePhotoForAsset:_asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
                if (livePhoto) {
                    weakSelf.asset.gd_onLoading = NO;
                    [weakSelf refreshCellWhenCloudDone];
                }
            }];
            
        } else {
            // Fallback on earlier versions
            //不管9.1以下的了
        }
        
    }   //livephoto
    
}

- (void)refreshCellWhenCloudDone {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setPickerType:weakSelf.pickType andPHAsset:weakSelf.asset];
    });
}

#pragma mark - 非公开

- (void)initCoverImg {
   __weak typeof(self) weakSelf = self;
    
    //获取缩略图
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
//    BOOL isInCloud = asset.sourceType == PHAssetSourceTypeCloudShared;
    
    CGSize size = [GDUtils sizeMaxWidth:150.f withAsset:_asset];
    [[PHImageManager defaultManager] requestImageForAsset:_asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.coverImg setImage:result];
        });
    }];
}

- (void)initTimeLabel {
    
    __weak typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        float videoLength = (float)asset.duration.value / asset.duration.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.videoTimeLabel.text = [NSString stringWithFormat:@"%lds", (long)videoLength];
        });
    }];
}

- (void)initBurstCountLabel {
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.includeAllBurstAssets = YES;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithBurstIdentifier:_asset.burstIdentifier options:fetchOptions];
    NSUInteger burstCount = fetchResult.count;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.burstCountLabel.text = [NSString stringWithFormat:@"%lu张", (unsigned long)burstCount];
    });
}

@end
