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
}

- (IBAction)multipleImgTouched:(id)sender {
}

- (IBAction)burstImgTouched:(id)sender {
}

- (IBAction)videoTouched:(id)sender {
}

- (IBAction)livephotoTouched:(id)sender {
}

- (IBAction)gitTouched:(id)sender {
}

#pragma mark - collectiondelegate

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger width = (K_W*0.8) - 10*2;
    NSInteger height = (K_W*0.8)/0.8;
    return  CGSizeMake(width, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ResultCell *cell = (ResultCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ResultCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
}




@end
