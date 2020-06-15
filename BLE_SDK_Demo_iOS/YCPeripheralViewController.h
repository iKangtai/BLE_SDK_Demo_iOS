//
//  YCPeripheralViewController.h
//  BLE_SDK_Demo_iOS
//
//  Created by MacBook Pro 2016 on 2020/6/12.
//  Copyright © 2020 ikangtai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YCPeripheral;
@class YCTemperature;
@interface YCPeripheralViewController : UIViewController

@property (nonatomic, strong) YCPeripheral *peripheral;

@end

NS_ASSUME_NONNULL_END
