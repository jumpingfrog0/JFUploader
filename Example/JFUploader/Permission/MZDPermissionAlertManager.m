//
//  MZDPermissionAlertManager.m
//  iLoving
//
//  Created by lfeng on 16/4/29.
//  Copyright © 2016年 MZD. All rights reserved.
//

#import "MZDPermissionAlertManager.h"

@implementation MZDPermissionAlertManager

+ (void)popPermissionAlertViewWithType:(MZDPermissionType)type
                           cancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock
                         completeBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock
{
    NSString *title = nil;
    NSString *message = nil;
    switch (type) {
        case MZDPermissionTypeNotification:
            title = @"通知权限未开启";
            message = @"通知权限开启后，你能及时收到另一半的消息提醒";
            break;
        case MZDPermissionTypePhoto:
            title = @"照片权限未开启";
            message = @"请在系统设置中开启照片权限";
            break;
        case MZDPermissionTypeCamera:
            title = @"相机权限未开启";
            message = @"请在系统设置中开启相机权限";
            break;
        case MZDPermissionTypeMacrophone:
            title = @"麦克风权限未开启";
            message = @"麦克风权限开启后才能和另一半使用发送语音功能";
            break;
        case MZDPermissionTypeLocation:
            title = @"定位权限未开启";
            message = @"手机定位权限开启后才能和另一半使用发送距离功能";
            break;
        case MZDPermissionTypeSystemLocation:
            title = @"系统定位权限未开启";
            message = @"请在系统设置中开启定位权限";
        default:
            break;
    }
//    UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:title message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"去开启"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        if (buttonIndex == alertView.cancelButtonIndex) {
//            if (cancelBlock) {
//                cancelBlock();
//            }
//            return;
//        }
//
//        if (completeBlock) {
//            completeBlock();
//        }
//
//        if ([UIDevice mzd_uponVersion:10.0]) {
//            [self gotoSettingPermissionIOS10];
//            return;
//        }
//
//        if (type == MZDPermissionTypeSystemLocation) {  /** 系统定位权限单独处理 */
//            [self gotoSettingSystemLocationPermission];
//
//        } else {
//            [self gotoSettingLovingPermission];
//        }
//    }];
//    [alertView show];
}

#pragma mark - Action
+ (void)gotoSettingNotificationPermission
{

}

+ (void)gotoSettingPhotoPermission
{

}

+ (void)gotoSettingCameraPermission
{

}

+ (void)gotoSettingMacrophonePermission
{

}

+ (void)gotoSettingLocationPermission
{

}

+ (void)gotoSettingSystemLocationPermission
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)gotoSettingLovingPermission
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", identifier]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }
}

// iOS 设置支持
+ (void)gotoSettingPermissionIOS10
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
