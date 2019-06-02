//
//  MZDPermissionInspector.h
//  iLoving
//
//  Created by lfeng on 16/5/9.
//  Copyright © 2016年 MZD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZDPermissionAlertManager.h"

typedef void(^MZDPermissionBlock)(BOOL valid);

@interface MZDPermissionInspector : NSObject

/**
 *  权限判断
 *
 *  @param validBlock    权限通过回调
 *  @param cancelBlock   无权限弹框取消回调
 *  @param completeBlock 无权限弹框确定回调
 */
+ (void)checkCameraPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;
+ (void)checkPhotoPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;
+ (void)checkLocationPermissionWithPermssionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;
+ (void)checkNotificationPermissionWithpermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;

/**
 *  视频通话权限判断
 *
 *  @param validBlock    权限通过以后的回调
 *  @param invalidBlock  无权限时额外的回调，主要针对通话无权限时候接通，需要挂断通话
 *  @param cancelBlock   无权限弹框取消回调
 *  @param completeBlock 无权限弹框确定回调
 */
+ (void)checkVideoPermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;
+ (void)checkMacrophonePermissionWithPermissionBlock:(MZDPermissionBlock)permissionBlock alertCancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock alertCompleteBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;

@end
