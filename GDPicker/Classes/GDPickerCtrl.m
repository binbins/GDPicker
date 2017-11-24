//
//  GDPickerCtrl.m
//  GDPicker
//
//  Created by 张帆 on 2017/11/12.
//
#define MAX_SELECTED_IMG_NUM 10
#define GDSCR_W [[UIScreen mainScreen] bounds].size.width
#define GDSCR_H [[UIScreen mainScreen] bounds].size.height

#import "GDPickerCtrl.h"
#import "GDPickerCell.h"
#import "TipView.h"
@import Photos;

@interface GDPickerCtrl () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, TipViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *pickerCollection;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cancelBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pickName;
@property (nonatomic, strong) TipView *tipsView;
@property (nonatomic, strong) NSMutableArray *pickerModels, *selectedIndexs;

@property (nonatomic, assign) BOOL isVideoPicker, isLivePhotoPicker, isBurstPicker, isPhotosPicker;

@end

@implementation GDPickerCtrl
{
    BOOL _isSingleSelected;
    BOOL _isNotFirstAppear;
}

#pragma mark - get

- (NSMutableArray *)pickerModels {
    
    if (!_pickerModels) {
        _pickerModels = [NSMutableArray array];
    }
    return _pickerModels;
}

- (NSMutableArray *)selectedIndexs {
    if (!_selectedIndexs) {
        _selectedIndexs = [NSMutableArray array];
    }
    return _selectedIndexs;
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSpecificTypePicker];
    [self initPickerCollection];
    [self initPickerData];
    [self initTipView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_isNotFirstAppear) {   //有点拗口
        _isNotFirstAppear = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_pickerCollection reloadData];
            if (self.pickerModels.count > 0) {
                [self.tipsView stateHide];
                NSIndexPath *endIndex = [NSIndexPath indexPathForItem:self.pickerModels.count-1 inSection:0];
                [_pickerCollection scrollToItemAtIndexPath:endIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }else {
                [self.tipsView stateNoResult];
            }
        });
    }
}

- (void)initSpecificTypePicker {
    _isSingleSelected = !(_pickerType==PickerTypeManyPhoto);
    
    _nextBtn.hidden = _isSingleSelected;    //单选picker没有下一步btn
    
    if (_pickerType == PickerTypeManyPhoto) {
        _pickName.text = @"选择多张照片";
        _isPhotosPicker = YES;
        _nextBtn.enabled = NO;
        _nextBtn.alpha = 0.4;
    }else if (_pickerType == PickerTypeSinglePhoto){
        _pickName.text = @"选择照片";
        _isPhotosPicker = YES;
    }else if (_pickerType == PickerTypeBurst){
        _pickName.text = @"选择连拍";
        _isBurstPicker = YES;
    }else if (_pickerType == PickerTypeVideo){
        _pickName.text = @"选择视频";
        _isVideoPicker = YES;
    }else if (_pickerType == PickeTypeLivephoto){
        _pickName.text = @"选择Livephoto";
        _isLivePhotoPicker = YES;
    }
}

- (void)initPickerCollection {
    _pickerCollection.delegate = self;
    _pickerCollection.dataSource = self;
    
    NSString *cellName = NSStringFromClass([GDPickerCell class]);
    UINib *nib = [UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:[GDPickerCell class]]];
    [_pickerCollection registerNib:nib forCellWithReuseIdentifier:cellName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"选择器内存警告");
}

- (void)dealloc {
    NSLog(@"picker销毁");
}

#pragma mark - data

- (void)initPickerData {
    
    self.pickerModels = nil;  //刷新前清空一下
    
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
}

- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{
    //        NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOption];
    for (PHAsset *asset in assets) {
        BOOL isLivePhoto, isVideo, isBurst, isPhoto;
        BOOL isNotLivePhoto;
        
        if (@available(iOS 9.1, *)){
            isLivePhoto = (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive);    //livephot 属于 照片细分type
            isNotLivePhoto = (asset.mediaSubtypes != PHAssetMediaSubtypePhotoLive);
        }else {
            isLivePhoto = NO;
            isNotLivePhoto = YES;
        }
        isBurst = asset.representsBurst;
        isVideo = (asset.mediaType == PHAssetMediaTypeVideo);
        isPhoto = (asset.mediaType == PHAssetMediaTypeImage) && isNotLivePhoto;
        
        //按条件添加
        if (isLivePhoto && _isLivePhotoPicker) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isVideo && _isVideoPicker) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isBurst && _isBurstPicker) {
            [self.pickerModels addObject:asset];
            continue;
        }
        if (isPhoto && _isPhotosPicker) {
            [self.pickerModels addObject:asset];
            continue;
        }
    }
}

#pragma mark - out let

- (IBAction)nextBtnClicked:(id)sender {
//    [HudManager showLoading];
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (NSIndexPath *index in self.selectedIndexs) {
        PHAsset *asset = self.pickerModels[index.row];
        [selectedAssets addObject:asset];
    }
    
//    [SystemUtils imgsWithPhassetArr:selectedAssets completion:^(NSMutableArray *images) {
//        [HudManager hideLoading];
//        if (images.count>0) {
//            [weakSelf pushEditCtrlWith:images type:GifFromImgs];
//        }
//    }];
}

- (IBAction)backBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collectiondelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger space = 5;
    NSInteger rows = 4;
    NSInteger itemWidth = (GDSCR_W - space*(rows-1)) / rows;
    return CGSizeMake(itemWidth, itemWidth);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pickerModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pickerModels.count) {
        NSLog(@"数组越界");
        return nil;
    }
    
    GDPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GDPickerCell class]) forIndexPath:indexPath];
    PHAsset *asset = self.pickerModels[indexPath.row];
    [cell setPickerType:_pickerType andPHAsset:asset];
    NSUInteger markOrder = [self imgIndexAtSelectedArray:indexPath];
    cell.selectedOrder = markOrder;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *asset = self.pickerModels[indexPath.row];
    
    if (_pickerType == PickeTypeLivephoto) {
        [self livephotoTouched:asset];
        
    }else if (_pickerType == PickerTypeVideo){
        [self videoTouched:asset];
        
    }else if (_pickerType == PickerTypeBurst) {
        [self burstTouched:asset];
        
    }else if (_pickerType == PickerTypeManyPhoto) {
        
        [self manyPhotosTouched:indexPath];
    }else if (_pickerType == PickerTypeSinglePhoto) {
        NSLog(@"只选择一张图片");
    }
}

#pragma mark - 多选选中事件

- (void)manyPhotosTouched:(NSIndexPath *)index {
    
    NSUInteger arrIndex = [self imgIndexAtSelectedArray:index];
    BOOL haveAsset = arrIndex>0;
    
    GDPickerCell *cell = (GDPickerCell *)[_pickerCollection cellForItemAtIndexPath:index];
    if (haveAsset) {
        [self.selectedIndexs removeObject:index];   //去掉
        cell.selectedOrder = 0;
    }else {
        if (self.selectedIndexs.count > MAX_SELECTED_IMG_NUM) {
//            [HudManager showWord:[NSString stringWithFormat:@"最多可以选择%ld张", (long)MAX_SELECTED_IMG_NUM]];
            return;
        }
        [self.selectedIndexs addObject:index];  //加上
        cell.selectedOrder = self.selectedIndexs.count;;
    }
    
    [self refreshSpecificCell];
    
    _nextBtn.enabled = _selectedIndexs.count>0; //下一步按钮的enable
    _nextBtn.alpha = _selectedIndexs.count>0? 1.0f : 0.4f;
}

- (NSUInteger)imgIndexAtSelectedArray:(NSIndexPath *)path {
    NSUInteger result = 0;
    
    for (int i=0; i<self.selectedIndexs.count; i++) {
        NSIndexPath *each = self.selectedIndexs[i];
        if (each.section==path.section && each.item==path.item) {
            result = i+1;
            break;
        }
    }
    return result;
}

- (void)refreshSpecificCell {
    NSArray *visibleCells = _pickerCollection.visibleCells;
    
    for (GDPickerCell *cell in visibleCells) {
        NSIndexPath *cellPath = [_pickerCollection indexPathForCell:cell];
        cell.selectedOrder = [self imgIndexAtSelectedArray:cellPath];
    }
}

#pragma mark - 其他选中事件
- (void)burstTouched:(PHAsset *)asset {
//    [HudManager showLoading];
    __weak typeof(self) weakSelf = self;
    
//    [SystemUtils burstimgsWithPhasset:asset completion:^(NSMutableArray *images) {
//        [HudManager hideLoading];
//        [weakSelf pushEditCtrlWith:images type:GifFromBurst];
//    }];
}

- (void)livephotoTouched:(PHAsset *)asset {
    if (@available(iOS 9.1, *)) {
//        [HudManager showLoading];
        __weak typeof(self) weakSelf = self;
        
        PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        [[PHImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (livePhoto && [info.allKeys containsObject:PHImageResultIsDegradedKey]) {    //这个方法会调用超过一次，我们取其中一次就好了
                
                
                
            }else if(!livePhoto) {
//                [HudManager hideLoading];
//                [HudManager showWord:@"phasset --> phlivephoto faild"];
            }
        }]; //phasset -->avasset block
    }
}

- (void)videoTouched:(PHAsset *)asset {
//    [HudManager showLoading];
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
    }];
}

#pragma mark - other
- (void)initTipView {
    _tipsView = [[TipView alloc] initWithFrame:CGRectMake(0, (GDSCR_H-64-49)/2-75, GDSCR_W, 150)];
    _tipsView.delegate = self;
    [self.pickerCollection addSubview:_tipsView];
}

- (void)touchTipView {
    NSLog(@"touch tip view");
}

@end
