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

#import <GDPicker/GDPicker.h>


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
    self.navigationController.navigationBar.hidden = YES;
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
    [self showPicker:PickerTypeLivephoto];
}

- (IBAction)gifTouched:(id)sender {
    [self showPicker:PickerTypeGif];
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

            [GDUtils imgsWithPhassetArr:resultArr completion:^(NSMutableArray *images) {
                [weakSelf reloadCollection:images];
                
                for (UIImage *each in images) {
                    NSLog(@"图片名字%@", each.gd_fileName);
                }
            }];
        }
    }];
    
//    [picker showIn:self];
    [picker pushInCtrl:self];
    
}

- (void)reloadCollection:(NSArray *)imgs {
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resultArray removeAllObjects];
        [self.resultArray addObjectsFromArray:imgs];
        [weakSelf.resultCollection reloadData];
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
