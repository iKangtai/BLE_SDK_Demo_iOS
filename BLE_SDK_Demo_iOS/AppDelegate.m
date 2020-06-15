//
//  AppDelegate.m
//  BLE_SDK_Demo_iOS
//
//  Created by MacBook Pro 2016 on 2020/6/12.
//  Copyright © 2020 ikangtai. All rights reserved.
//

#import "AppDelegate.h"
#import "YCMainViewController.h"
#import <YCPeripheral/YCPeripheral.h>
#import "YCConsts.h"

#ifdef DEBUG
#import <FLEX/FLEXManager.h>
#endif

@interface AppDelegate ()<YCPeripheralManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [YCPeripheralManager shared].delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[YCMainViewController alloc] init]];
    [self.window makeKeyAndVisible];
        
    if (self.window != nil) {
        UISwipeGestureRecognizer* ges = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGestureAction:)];
        ges.direction = UISwipeGestureRecognizerDirectionDown;
        ges.numberOfTouchesRequired = 3;
        [self.window addGestureRecognizer:ges];
    }
    
    if (@available(iOS 13.0, *)) {
        [self.window setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    }
    
    return YES;
}

#pragma mark - Help Methods

- (void)swipeGestureAction:(UISwipeGestureRecognizer *)gestureRecognizer {
#if DEBUG
    // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
    [[FLEXManager sharedManager] showExplorer];
#endif
}

#pragma mark - YCPeripheralManagerDelegate

-(void)peripheralManager:(YCPeripheralManager *)manager didUpdateState:(YCBLEState)state {
    
}

-(void)peripheralManagerDidStartScan:(YCPeripheralManager *)manager {
    
}

-(void)peripheralManagerDidStopScan:(YCPeripheralManager *)manager {
    
}

-(void)peripheralManager:(YCPeripheralManager *)manager didDisConnectPeripheral:(YCPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Error: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidDisconnectPeripheral object:peripheral];
}

-(void)peripheralManager:(YCPeripheralManager *)manager didFailToConnectPeripheral:(YCPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Error: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidFailToPeripheral object:peripheral];
}

- (void)peripheralManager:(nonnull YCPeripheralManager *)manager didConnectPeripheral:(nonnull YCPeripheral *)peripheral {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidConnectPeripheral object:peripheral];
}

- (void)peripheralManager:(nonnull YCPeripheralManager *)manager didFindPeripherals:(nonnull NSArray<YCPeripheral *> *)peripherals {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidFindPeripherals object:peripherals];
}

- (void)peripheralManager:(nonnull YCPeripheralManager *)manager didSetNotifyToPeripheral:(nonnull YCPeripheral *)peripheral type:(YCNotifyType)type result:(nonnull NSString *)result error:(NSError * _Nullable)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidSetNotifyToPeripheral object:@[peripheral, @(type), result]];
}

- (void)peripheralManager:(nonnull YCPeripheralManager *)manager didUploadWithPeripheral:(nonnull YCPeripheral *)peripheral temperatures:(nonnull NSArray<YCTemperature *> *)temperatures {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidGetTemperatures object:@[peripheral, temperatures]];
}

@end
