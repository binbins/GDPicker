//
//  GDViewController.m
//  GDPicker
//
//  Created by binbins on 11/12/2017.
//  Copyright (c) 2017 binbins. All rights reserved.
//
// [UIScreen mainScreen].bounds.size.width
#define K_W [UIScreen mainScreen].bounds.size.width
#define K_H [UIScreen mainScreen].bounds.size.height

#import "GDViewController.h"
#import "ResultCell.h"
@import GDPicker;

@interface GDViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *resultCollection;
@property (nonatomic, strong) NSMutableArray *resultArray;

@end

@implementation GDViewController

#pragma mark - get
- (NSMutableArray *)resultArray {
    if(!_resultArray){
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

#pragma mark - view
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _resultCollection.delegate = self;
    _resultCollection.dataSource = self;
}


#pragma mark - out let

- (IBAction)singImgTouched:(id)sender {
    [self showPicker:PickerTypeSinglePhoto];
}

- (IBAction)multipleImgTouched:(id)sender {
    [self showPicker:PickerTypeManyPhoto];
}

- (IBAction)burstImgTouched:(id)sender {
    [self showPicker:PickerTypeBurst];
}

- (IBAction)videoTouched:(id)sender {
    [self showPicker:PickerTypeVideo];
}

- (IBAction)livephotoTouched:(id)sender {
    [self showPicker:PickeTypeLivephoto];
}

- (IBAction)gifTouched:(id)sender {
}

#pragma mark - show & process

- (void)showPicker:(PickerType)pickerType {
    
    GDPickerCtrl *picker = [[GDPickerCtrl alloc] initWithPickerType:pickerType CompleteBlock:^(NSArray *resultArr) {
        __weak typeof(self) weakSelf = self;
        
        if (pickerType == PickerTypeBurst) {
            PHAsset *burst = [resultArr firstObject];
            [GDUtils burstimgsWithPhasset:burst completion:^(NSMutableArray *images) {
                [weakSelf reloadCollection:images];
            }];
        }else {
            NSLog(@"转化为图片中...");
            
            [GDUtils imgsWithPhassetArr:resultArr completion:^(NSMutableArray *images) {
                NSLog(@"转化图片结束");
                [weakSelf reloadCollection:images];
            }];
        }
    }];
    
    [picker showIn:self];
}

- (void)reloadCollection:(NSArray *)imgs {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resultArray removeAllObjects];
        [self.resultArray addObjectsFromArray:imgs];
        [_resultCollection reloadData];
    });
}

#pragma mark - collectiondelegate

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger width = (K_W*0.8) - 10*2;
    NSInteger height = (K_W*0.8)/0.8;
    return  CGSizeMake(width, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger count = self.resultArray.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ResultCell *cell = (ResultCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ResultCell class]) forIndexPath:indexPath];
    
    UIImage *img = self.resultArray[indexPath.row];
    [cell.cover setImage:img];
    return cell;
}





@end
