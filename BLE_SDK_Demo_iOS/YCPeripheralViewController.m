//
//  YCPeripheralViewController.m
//  BLE_SDK_Demo_iOS
//
//  Created by MacBook Pro 2016 on 2020/6/12.
//  Copyright © 2020 ikangtai. All rights reserved.
//

#import "YCPeripheralViewController.h"
#import <YCPeripheral/YCPeripheral.h>
#import "YCConsts.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define kYCBLECollectReuseCellID @"kYCBLECollectReuseCellID"

@interface YCBLECollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLbl;

@end

@implementation YCBLECollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.7];
    [self titleLbl];
}

#pragma mark - Lazy Load

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.numberOfLines = 0;
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.userInteractionEnabled = true;
        _titleLbl.adjustsFontSizeToFitWidth = true;
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLbl];
        _titleLbl.translatesAutoresizingMaskIntoConstraints = false;
        [_titleLbl.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = true;
        [_titleLbl.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = true;
        [_titleLbl.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = true;
        [_titleLbl.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = true;
    }
    return _titleLbl;
}

@end

@interface YCPeripheralViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray <YCTemperature *>*temperatures;

@property (strong, nonatomic) UITextView *tempView;

@property (nonatomic, strong, readonly) NSArray <NSString *>*btnTitles;
@property (nonatomic, strong) UICollectionViewFlowLayout *customLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (strong, nonatomic) UILabel *lable1;

@end

@implementation YCPeripheralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setupUI];
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidGetTemperatures:) name:kNotification_DidGetTemperatures object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisconnectPeripheral:) name:kNotification_DidDisconnectPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSetNotifyToPeripheral:) name:kNotification_DidSetNotifyToPeripheral object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)setupUI {
    [self lable1];
    [self tempView];
    [self collectionView];
}

-(NSArray<NSString *> *)btnTitles {
    return @[
        @"Set Centigrade",
        @"Set Fahrenheit",
        @"Set Time",
        @"Get Power",
//        @"Get Firmware Version",
//        @"Disconnect",
    ];
}

-(void)handleButtonActions:(NSString *)curTitle {
    NSLog(@"%@", curTitle);
    [self.view endEditing:true];
    YCPeripheralManager *manager = [YCPeripheralManager shared];
    if ([curTitle isEqualToString:@"Set Time"]) {
        [manager setNotifyToPeripheral:self.peripheral type:YCNotifyTypeSetTime value:0];
    } else if ([curTitle isEqualToString:@"Set Centigrade"]) {
        [manager setNotifyToPeripheral:self.peripheral type:YCNotifyTypeSetTemperatureUnitC value:0];
    } else if ([curTitle isEqualToString:@"Set Fahrenheit"]) {
        [manager setNotifyToPeripheral:self.peripheral type:YCNotifyTypeSetTemperatureUnitF value:0];
    } else if ([curTitle isEqualToString:@"Get Firmware Version"]) {
        [manager setNotifyToPeripheral:self.peripheral type:YCNotifyTypeGetFirmwareVersion value:0];
    } else if ([curTitle isEqualToString:@"Get Power"]) {
        [manager setNotifyToPeripheral:self.peripheral type:YCNotifyTypeGetPower value:0];
    } else if ([curTitle isEqualToString:@"Disconnect"]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[YCPeripheralManager shared] disconnectPeripheral:self.peripheral];
    }
}

-(void)handleDidGetTemperatures:(NSNotification *)notify {
    NSArray *objs = notify.object;
    YCPeripheral *peri = objs.firstObject;
    if ([peri.peripheral.identifier.UUIDString isEqualToString:self.peripheral.peripheral.identifier.UUIDString]) {
        NSArray <YCTemperature *> *temperatures = objs.lastObject;
        self.temperatures = temperatures;
    }
}

-(void)handleDisconnectPeripheral:(NSNotification *)notify {
    YCPeripheral *peri = notify.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([peri.peripheral.identifier.UUIDString isEqualToString:self.peripheral.peripheral.identifier.UUIDString]) {
            [self.navigationController popViewControllerAnimated:true];
        }
    });
}

-(void)handleDidSetNotifyToPeripheral:(NSNotification *)notify {
    NSArray *objs = notify.object;
    YCPeripheral *peri = objs.firstObject;
    if (![peri.peripheral.identifier.UUIDString isEqualToString:self.peripheral.peripheral.identifier.UUIDString]) {
        return;
    }
    NSNumber *typeNum = objs[1];
    YCNotifyType type = typeNum.intValue;
    NSString *result = objs.lastObject;
    
    NSMutableString *tempStr = [NSMutableString stringWithString:self.tempView.text];
    [tempStr appendFormat:@"%@: %@\n", [self stringWithNotifyType:type], result];
    self.tempView.text = tempStr.copy;
}

-(NSString *)stringWithNotifyType:(YCNotifyType)type {
    switch (type) {
        case YCNotifyTypeGetPower:
            return @"Get power.";
        case YCNotifyTypeSetTemperatureUnitC:
            return @"Set Temperature °C";
        case YCNotifyTypeSetTemperatureUnitF:
            return @"Set Temperature °F";
        case YCNotifyTypeSetTime:
            return @"Set time.";
        case YCNotifyTypeGetFirmwareVersion:
            return @"Get firmware version";
        default:
            return [NSString stringWithFormat:@"Unknow type: %@", @(type)];
    }
}

-(NSString *)stringWithTemperatureFlag:(YCTemperatureFlag)flag {
    switch (flag) {
        case YCTemperatureFlagOnline:
            return @"Online";
            break;
        case YCTemperatureFlagOffline:
            return @"Offline begin";
            break;
        case YCTemperatureFlagOfflineEnd:
            return @"Offline end";
            break;
        default:
            break;
    }
}

-(void)setPeripheral:(YCPeripheral *)peripheral {
    _peripheral = peripheral;
    
    self.title = peripheral.macAddress;
}

-(void)setTemperatures:(NSArray<YCTemperature *> *)temperatures {
    _temperatures = temperatures;
    
    NSMutableString *tempStr = [NSMutableString stringWithString:self.tempView.text];
    for (YCTemperature *tempI in temperatures) {
        NSString *flag = [self stringWithTemperatureFlag:tempI.flag];
        [tempStr appendFormat:@"%.2f %@ %@\n", tempI.temperature, tempI.time, flag];
    }
    self.tempView.text = tempStr.copy;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YCBLECollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYCBLECollectReuseCellID forIndexPath:indexPath];
    cell.titleLbl.text = self.btnTitles[indexPath.item];
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.btnTitles.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *curTitle = self.btnTitles[indexPath.item];
    [self handleButtonActions:curTitle];
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width * 0.5 - 6;
    return CGSizeMake(width, 36);
}

#pragma mark - Lazy load

-(UITextView *)tempView {
    if (_tempView == nil) {
        _tempView = [[UITextView alloc] init];
        _tempView.layer.borderColor = [[UIColor blackColor] CGColor];
        _tempView.layer.borderWidth = 1.0f;
        _tempView.layer.cornerRadius = 4.0f;
        [self.view addSubview:_tempView];
        _tempView.translatesAutoresizingMaskIntoConstraints = false;
        [_tempView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:40].active = true;
        [_tempView.leadingAnchor constraintEqualToAnchor:self.lable1.trailingAnchor constant:8].active = true;
        [_tempView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-8].active = true;
        [_tempView.heightAnchor constraintEqualToConstant:120].active = true;
    }
    return _tempView;
}

-(UILabel *)lable1 {
    if (_lable1 == nil) {
        _lable1 = [[UILabel alloc] init];
        _lable1.text = @"Datas:";
        _lable1.textColor = [UIColor blackColor];
        _lable1.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:_lable1];
        _lable1.translatesAutoresizingMaskIntoConstraints = false;
        [_lable1.topAnchor constraintEqualToAnchor:self.tempView.topAnchor constant:20].active = true;
        [_lable1.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10].active = true;
        [_lable1.widthAnchor constraintEqualToConstant:55].active = true;
    }
    return _lable1;
}

-(UICollectionViewFlowLayout *)customLayout {
    if (_customLayout == nil) {
        _customLayout = [[UICollectionViewFlowLayout alloc] init];
        _customLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0);
        _customLayout.minimumInteritemSpacing = 2;
        _customLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _customLayout;
}

-(UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.customLayout];
        _collectionView.showsVerticalScrollIndicator = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.allowsMultipleSelection = false;
        _collectionView.allowsSelection = true;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[YCBLECollectionViewCell class] forCellWithReuseIdentifier:kYCBLECollectReuseCellID];
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
        _collectionView.translatesAutoresizingMaskIntoConstraints = false;
        [_collectionView.topAnchor constraintEqualToAnchor:self.tempView.bottomAnchor constant:10].active = true;
        [_collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = true;
        [_collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10].active = true;
        [_collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10].active = true;
    }
    return _collectionView;
}

@end
