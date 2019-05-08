//
//  GDPickerCell.m
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//

#import "GDPickerCell.h"
#import "GDUtils.h"

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

- (void)setPickerType:(PickerType)pickType andPHAsset:(PHAsset *)asset {
    _pickType = pickType;
    _asset = asset;
    
    [self initCloudView];
    [self initCoverImg];
    
    if (_pickType == PickeTypeLivephoto) {
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
        _markOrder.text = [NSString stringWithFormat:@"%lu", selectedOrder];
    }else {
        _selectedView.hidden = _duihao.hidden = YES;
    }
}


#pragma mark - iCloud

- (IBAction)downloadiCloud:(id)sender {
    __weak typeof(self) weakSelf = self;
    
    if (_pickType==PickerTypeManyPhoto || _pickType==PickerTypeSinglePhoto || _pickType==PickerTypeBurst) {
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.networkAccessAllowed = YES;
        option.synchronous = NO;
        option.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.icloudTip.text = [NSString stringWithFormat:@"下载中:%d", (int)progress*100];
            });
        };
        
        [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            if (imageData) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.icloudView.hidden = YES;
                });
            }
        }];
    }
}

#pragma mark - 非公开

- (void)initCloudView {
//    __block BOOL isInLocalAblum = YES;
    
    //判断是否在iCloud中
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = NO;
    __weak typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestImageDataForAsset:_asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL isInLocalAblum = imageData ? YES : NO;
        weakSelf.icloudView.hidden = isInLocalAblum;
    }];
}

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
        weakSelf.burstCountLabel.text = [NSString stringWithFormat:@"%lu张", burstCount];
    });
}

@end
