//
//  MZDPermissionInspector.m
//  iLoving
//
//  Created by lfeng on 16/5/9.
//  Copyright © 2016年 MZD. All rights reserved.
//

#import "MZDPermissionInspector.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation MZDPermissionInspector

+ (void)checkPhotoPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    if (NSClassFromString(@"PHAsset")) {
        PHAuthorizationStatus phStatus = [PHPhotoLibrary authorizationStatus];
        if (phStatus == PHAuthorizationStatusDenied) {
            [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypePhoto cancelBlock:cancelBlock completeBlock:completeBlock];
        }
        else if (phStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (permissionBlock) {
                    permissionBlock(status == PHAuthorizationStatusAuthorized);
                }
            }];
        }
        else if (permissionBlock) {
            permissionBlock(YES);
        }
    }
    else {
        ALAuthorizationStatus assetsStatus = [ALAssetsLibrary authorizationStatus];
        if (assetsStatus == ALAuthorizationStatusDenied) {
            [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypePhoto cancelBlock:cancelBlock completeBlock:completeBlock];
            return;
        }
        else if (permissionBlock) {
            permissionBlock(YES);
        }
    }
}

+ (void)checkCameraPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeCamera cancelBlock:cancelBlock completeBlock:completeBlock];
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (permissionBlock) {
            permissionBlock(YES);
        }
    } else {
//        [HUD showErrorWithMessage:@"相机不可用"];
        return;
    }
}

+ (void)checkLocationPermissionWithPermssionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeLocation cancelBlock:cancelBlock completeBlock:completeBlock];
        } else {
            if (permissionBlock) {
                permissionBlock(YES);
            }
        }
    } else {
        [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeSystemLocation cancelBlock:cancelBlock completeBlock:completeBlock];
    }
}

+ (void)checkMacrophonePermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                if (permissionBlock) permissionBlock(YES);
            }
            else {
                if (permissionBlock) {
                    permissionBlock(NO);
                }
                [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeMacrophone cancelBlock:cancelBlock completeBlock:completeBlock];
            }
        }];
    } else {
        if (permissionBlock) permissionBlock(YES);
    }
}

+ (void)checkNotificationPermissionWithpermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeNotification cancelBlock:cancelBlock completeBlock:completeBlock];
    }
}

+ (void)checkVideoPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    if (AVAuthorizationStatusNotDetermined == [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [MZDPermissionInspector checkMacrophonePermissionWithPermissionBlock:^(BOOL valid) {
                    if (permissionBlock) permissionBlock(valid);
                } alertCancelBlock:cancelBlock alertCompleteBlock:completeBlock];
            }
            else {
                if (cancelBlock) cancelBlock();
            }
        }];
        return;
    } else if (AVAuthorizationStatusAuthorized != [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        if (permissionBlock) permissionBlock(NO);
        [MZDPermissionAlertManager popPermissionAlertViewWithType:MZDPermissionTypeCamera cancelBlock:cancelBlock completeBlock:completeBlock];
        return;
    } else {
        [MZDPermissionInspector checkMacrophonePermissionWithPermissionBlock:^(BOOL valid) {
            if (permissionBlock) permissionBlock(valid);
        } alertCancelBlock:cancelBlock alertCompleteBlock:completeBlock];
    }
}

@end
