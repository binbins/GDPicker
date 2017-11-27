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

@end

@implementation GDPickerCell

- (void)setPickerType:(PickerType)pickType andPHAsset:(PHAsset *)asset {
    _pickType = pickType;
    _asset = asset;
    
    [self initCoverImg:asset];
    
    if (pickType == PickeTypeLivephoto) {
        _liveMark.hidden = NO;
        
    }else if (pickType == PickerTypeVideo){
        _videoTimeLabel.hidden = _shadowView.hidden = NO;
        [self initTimeLabel:asset];
        
    }else if (pickType == PickerTypeBurst) {
        _burstCountLabel.hidden = _shadowView.hidden = NO;
        [self initBurstCountLabel:asset];
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

#pragma mark - 非公开
- (void)initCoverImg:(PHAsset *)asset {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    
    CGSize size = [GDUtils sizeMaxWidth:150.f withAsset:asset];
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_coverImg setImage:result];
        });
    }];
}

- (void)initTimeLabel:(PHAsset *)asset {
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        float videoLength = (float)asset.duration.value / asset.duration.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            _videoTimeLabel.text = [NSString stringWithFormat:@"%lds", (long)videoLength];
        });
    }];
}

- (void)initBurstCountLabel:(PHAsset *)asset {
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.includeAllBurstAssets = YES;
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithBurstIdentifier:asset.burstIdentifier options:fetchOptions];
    NSUInteger burstCount = fetchResult.count;
    _burstCountLabel.text = [NSString stringWithFormat:@"%lu张", burstCount];
}
@end
