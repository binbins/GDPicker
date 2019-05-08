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
#import "GDUtils.h"

typedef void (^DoneBlock)(NSArray *arr);

@interface GDPickerCtrl () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, TipViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UICollectionView *pickerCollection;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cancelBtn;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *pickName;
@property (nonatomic, strong) TipView *tipsView;
@property (nonatomic, strong) DoneBlock doneBlock;
@property (nonatomic, strong) NSMutableArray *pickerModels, *selectedIndexs;

@property (nonatomic, assign) BOOL isVideoPicker, isLivePhotoPicker, isBurstPicker, isPhotosPicker, isGifPicker;

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

#pragma mark - 公开
- (instancetype)initWithPickerType:(PickerType)typeType CompleteBlock:(void(^)(NSArray<PHAsset *> *resultArr))completeBlock {
    
    NSString *nibName = NSStringFromClass([GDPickerCtrl class]);
    NSBundle *pickerBundle = [NSBundle bundleForClass:[GDPickerCtrl class]];
    if (self = [super initWithNibName:nibName bundle:pickerBundle]) {
        self.pickerType = typeType;
    }
    if (completeBlock) {
        self.doneBlock = ^(NSArray *arr) {
            completeBlock(arr);
        };
    }
    
    return self;
}

- (void)showIn:(UIViewController *)ctrl {
    
    [ctrl presentViewController:self animated:YES completion:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSpecificTypePicker];
    [self initPickerCollection];
//    [self initPickerData];
    [self initNewPickerData];
    [self initTipView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_isNotFirstAppear) {   //有点拗口
        _isNotFirstAppear = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pickerCollection reloadData];
            if (self.pickerModels.count > 0) {
                [self.tipsView stateHide];
                NSIndexPath *endIndex = [NSIndexPath indexPathForItem:self.pickerModels.count-1 inSection:0];
                [weakSelf.pickerCollection scrollToItemAtIndexPath:endIndex atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            }else {
                [weakSelf.tipsView stateNoResult];
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
    }else if (_pickerType == PickerTypeLivephoto){
        _pickName.text = @"选择Livephoto";
        _isLivePhotoPicker = YES;
    }
    else if (_pickerType == PickerTypeGif){
        _pickName.text = @"选择GIF";
        _isGifPicker = YES;
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

- (void)initNewPickerData {
    __weak typeof(self) weakSelf = self;
    
    [self.pickerModels removeAllObjects];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        //        NSLog(@"相簿名:%@", assetCollection.localizedTitle);
        NSString *aName = collection.localizedTitle;
        if ([aName isEqualToString:@"All Photos"] && weakSelf.isPhotosPicker) {
            
            [weakSelf enumerateAssestCollection:collection];
        }
        else if ([aName isEqualToString:@"Videos"] && weakSelf.isVideoPicker) {
            
            [weakSelf enumerateAssestCollection:collection];
        }
        else if ([aName isEqualToString:@"Bursts"] && weakSelf.isBurstPicker) {
            
            [weakSelf enumerateAssestCollection:collection];
        }
        else if ([aName isEqualToString:@"Live Photos"] && weakSelf.isLivePhotoPicker) {
            
            [weakSelf enumerateAssestCollection:collection];
        }
        else if ([aName isEqualToString:@"Animated"] && weakSelf.isGifPicker) {
            
            [weakSelf enumerateAssestCollection:collection];
        }
        
    }];
    
}

- (void)enumerateAssestCollection:(PHAssetCollection *)pCollection {
    PHFetchOptions *fetchOption = [[PHFetchOptions alloc] init];
    fetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:pCollection options:fetchOption];
    
    for (PHAssetCollection *a in assets) {
        [self.pickerModels addObject:a];
    }
    
    //题目
    _pickName.text = [_pickName.text stringByAppendingFormat:@"(%ld张)", (long)self.pickerModels.count];
}

/*
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original{
    
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

*/

#pragma mark - out let

- (IBAction)nextBtnClicked:(id)sender {

    NSMutableArray *selectedAssets = [NSMutableArray array];
    for (NSIndexPath *index in self.selectedIndexs) {
        PHAsset *asset = self.pickerModels[index.row];
        [selectedAssets addObject:asset];
    }
    self.doneBlock(selectedAssets);
    [self dismiss];
}

- (IBAction)backBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collectiondelegate

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(5, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

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
        NSLog(@"...数组越界");
        return nil;
    }
    
    GDPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GDPickerCell class]) forIndexPath:indexPath];
    PHAsset *asset = self.pickerModels[indexPath.row];
    [cell setPickerType:_pickerType andPHAsset:asset];
    
    //多选的下标
    NSUInteger markOrder = [self imgIndexAtSelectedArray:indexPath];
    cell.selectedOrder = markOrder;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = self.pickerModels[indexPath.row];
    
    if (_pickerType == PickerTypeManyPhoto) {
        [self manyPhotosTouched:indexPath];
    }else {
        NSArray *result = [NSArray arrayWithObjects:asset, nil];
        self.doneBlock(result);
        [self dismiss];
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
        if (self.selectedIndexs.count >= MAX_SELECTED_IMG_NUM) {
            NSString *tip = [NSString stringWithFormat:@"当前设置最多可以选择%ld张", (long)MAX_SELECTED_IMG_NUM];
            NSLog(@"%@", tip);
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
