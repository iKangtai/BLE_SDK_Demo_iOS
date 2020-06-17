//
//  YCPeripheralManager.h
//  YCPeripheral
//
//  Created by MacBook Pro 2016 on 2020/6/15.
//  Copyright © 2020 ikangtai. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// YCBLEState
typedef NS_ENUM(NSInteger, YCBLEState) {
    /// Valid
    YCBLEStateValid = 0,
    /// Unknown
    YCBLEStateUnknown,
    /// Unsupported
    YCBLEStateUnsupported,
    /// Unauthorized
    YCBLEStateUnauthorized,
    /// PoweredOff
    YCBLEStatePoweredOff,
    /// Resetting
    YCBLEStateResetting
};

/// Define BLE notify type
typedef NS_ENUM(NSInteger, YCNotifyType) {
    /// Set the thermometer to centigrade
    YCNotifyTypeSetTemperatureUnitC,
    /// Set the thermometer to fahrenheit
    YCNotifyTypeSetTemperatureUnitF,
    /// Set time
    YCNotifyTypeSetTime,
    /// Get the thermometer's power
    YCNotifyTypeGetPower,
    /// Get Firmware Version
    YCNotifyTypeGetFirmwareVersion,
    /// Return temperatures' number to thermometer
    YCNotifyTypeTemperatureACK,
    /// Transmit temperature
    YCNotifyTypeTransmitTemperature,
};

/// Temperature flag
typedef NS_ENUM(NSInteger, YCTemperatureFlag) {
    /// Online
    YCTemperatureFlagOnline,
    /// Offline
    YCTemperatureFlagOffline,
    /// Offline end
    YCTemperatureFlagOfflineEnd,
};

/// Thermometer type
typedef NS_ENUM(NSInteger, YCThermometerType) {
    /// Thermometer
    YCThermometerTypeThree,
    /// Forehead temperature gun
    YCThermometerTypeFour,
};

@class YCPeripheralManager;
@class YCPeripheral;
@class YCTemperature;
@protocol YCPeripheralManagerDelegate <NSObject>

@required

-(void)peripheralManager:(YCPeripheralManager *)manager
          didUpdateState:(YCBLEState)state;

-(void)peripheralManager:(YCPeripheralManager *)manager
      didFindPeripherals:(NSArray <YCPeripheral *>*)peripherals;

-(void)peripheralManager:(YCPeripheralManager *)manager
    didConnectPeripheral:(YCPeripheral *)peripheral;

-(void)peripheralManager:(YCPeripheralManager *)manager
 didUploadWithPeripheral:(YCPeripheral *)peripheral
            temperatures:(NSArray <YCTemperature *>*)temperatures;

-(void)peripheralManager:(YCPeripheralManager *)manager
didSetNotifyToPeripheral:(YCPeripheral *)peripheral
                    type:(YCNotifyType)type
                  result:(NSString *)result
                   error:(NSError * _Nullable)error;

@optional

-(void)peripheralManagerDidStartScan:(YCPeripheralManager *)manager;

-(void)peripheralManagerDidStopScan:(YCPeripheralManager *)manager;

-(void)peripheralManager:(YCPeripheralManager *)manager
didFailToConnectPeripheral:(YCPeripheral *)peripheral
                   error:(NSError *)error;

-(void)peripheralManager:(YCPeripheralManager *)manager
 didDisConnectPeripheral:(YCPeripheral *)peripheral
                   error:(NSError * _Nullable)error;

@end



@interface YCTemperature : NSObject

/// Temperature
@property (nonatomic, assign) double temperature;
/// The measure time
@property (nonatomic, copy) NSString *time;
/// Flag
@property (nonatomic, assign) YCTemperatureFlag flag;

@end



@interface YCPeripheral : NSObject

/// The current connected peripheral/divice
@property (nonatomic, strong, nullable) CBPeripheral *peripheral;
/// Firmware version
@property (nonatomic, copy) NSString *firmwareVersion;
/// The MAC address of current connected device
@property (nonatomic, copy) NSString *macAddress;
/// Peripheral Name
@property (nonatomic, copy) NSString *name;
/// Type
@property (nonatomic, assign) YCThermometerType type;
/// Connect state
@property (nonatomic, assign) BOOL connected;

@end



@interface YCPeripheralManager : NSObject

/// Delegate
@property (nonatomic, weak) id <YCPeripheralManagerDelegate> delegate;
/// Maximum number of connections allowed, max is 5, min is 1
@property (nonatomic, assign) NSInteger maxPeripherals;

/// The shared Thermometer object for the process.
+(instancetype)shared;

/**
Start scan.
    - parameters:
    - macList: The thermometer's mac address will be connected. If this is nil, the SDK will connect the first thermometer be found.
*/
-(void)startScan;


/**
Connect the currently connected device.
*/
-(void)connectPeripheral:(YCPeripheral *)peripheral;

/**
Disconnect the currently connected device.
*/
-(void)disconnectPeripheral:(YCPeripheral *)peripheral;

/**
Stop scan.
*/
-(void)stopScan;

/**
Send specific commands to the device.
    - parameters:
    - type: BLENotifyType
*/
-(void)setNotifyToPeripheral:(YCPeripheral *)peripheral type:(YCNotifyType)type value:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
