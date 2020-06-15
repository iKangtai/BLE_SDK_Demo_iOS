//
//  YCMainViewController.m
//  BLE_SDK_Demo_iOS
//
//  Created by MacBook Pro 2016 on 2020/6/12.
//  Copyright © 2020 ikangtai. All rights reserved.
//

#import "YCMainViewController.h"
#import "UIColor+YCExtension.h"
#import <YCPeripheral/YCPeripheral.h>
#import "YCConsts.h"
#import "YCPeripheralViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString *kMainReuseID = @"kYCMainTableViewCellReuseID";

@interface YCMainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray <YCPeripheral *>*peripherals;

@end

@implementation YCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Home";
    self.peripherals = @[];
    [self tableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidFindPeripherals:) name:kNotification_DidFindPeripherals object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidConnectPeripheral:) name:kNotification_DidConnectPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisconnectPeripheral:) name:kNotification_DidDisconnectPeripheral object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisconnectPeripheral:) name:kNotification_DidFailToPeripheral object:nil];
}

-(void)handleScanAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        [self.indicator startAnimating];
        [[YCPeripheralManager shared] startScan];
    } else {
        [self.indicator stopAnimating];
        [[YCPeripheralManager shared] stopScan];
    }
}

-(void)handleDidFindPeripherals:(NSNotification *)notify {
    NSArray <YCPeripheral *>*peripherals = notify.object;
    self.peripherals = peripherals;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

-(void)handleDidConnectPeripheral:(NSNotification *)notify {
    YCPeripheral *peri = notify.object;
    [self reloadPeripheral:peri];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        YCPeripheralViewController *vc = [[YCPeripheralViewController alloc] init];
        vc.peripheral = peri;
        [self.navigationController pushViewController:vc animated:true];
    });
}

-(void)handleDisconnectPeripheral:(NSNotification *)notify {
    YCPeripheral *peri = notify.object;
    [self reloadPeripheral:peri];
}

-(void)reloadPeripheral:(YCPeripheral *)peri {
    NSIndexPath *index = [self indexPathForPeripheral:peri];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (index != nil) {
            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

-(NSIndexPath *)indexPathForPeripheral:(YCPeripheral *)peri {
    for (int i = 0; i < self.peripherals.count; i++) {
        YCPeripheral *peripheral = self.peripherals[i];
        if ([peri.peripheral.identifier.UUIDString isEqualToString:peripheral.peripheral.identifier.UUIDString]) {
            return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return nil;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMainReuseID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kMainReuseID];
    }
    YCPeripheral *peri = self.peripherals[indexPath.row];
    cell.textLabel.text = peri.macAddress;
    cell.detailTextLabel.text = peri.connected ? @"Connected" : @"";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    YCPeripheral *peri = self.peripherals[indexPath.row];
    if (!peri.connected) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[YCPeripheralManager shared] connectPeripheral:peri];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Peripherals (Tap to connect)";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark - Lazy Load

-(UIActivityIndicatorView *)indicator {
    if (_indicator == nil) {
        if (@available(iOS 13.0, *)) {
            _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        [self.scanBtn addSubview:_indicator];
        _indicator.translatesAutoresizingMaskIntoConstraints = false;
        [_indicator.leadingAnchor constraintEqualToAnchor:self.scanBtn.leadingAnchor constant:20].active = true;
        [_indicator.centerYAnchor constraintEqualToAnchor:self.scanBtn.centerYAnchor].active = true;
    }
    return _indicator;
}

-(UIButton *)scanBtn {
    if (_scanBtn == nil) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setTitle:@"Start Scan" forState:UIControlStateNormal];
        [_scanBtn setTitle:@"    Stop Scan" forState:UIControlStateSelected];
        [_scanBtn setTitleColor:[UIColor colorWithHex:0x4C5479] forState:UIControlStateNormal];
        [_scanBtn setTitleColor:[UIColor colorWithHex:0xE92252] forState:UIControlStateSelected];
        _scanBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _scanBtn.layer.masksToBounds = true;
        _scanBtn.layer.cornerRadius = 6.0;
        _scanBtn.layer.borderColor = [UIColor colorWithHex:0x7B92AA].CGColor;
        _scanBtn.layer.borderWidth = 1.0;
        [_scanBtn addTarget:self action:@selector(handleScanAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_scanBtn];
        _scanBtn.translatesAutoresizingMaskIntoConstraints = false;
        [_scanBtn.widthAnchor constraintEqualToConstant:160].active = true;
        [_scanBtn.heightAnchor constraintEqualToConstant:40].active = true;
        [_scanBtn.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
        [_scanBtn.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:20].active = true;
    }
    return _scanBtn;
}

-(UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        _tableView.translatesAutoresizingMaskIntoConstraints = false;
        [_tableView.topAnchor constraintEqualToAnchor:self.scanBtn.bottomAnchor constant:20].active = true;
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = true;
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0].active = true;
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0].active = true;
    }
    return _tableView;
}

@end
