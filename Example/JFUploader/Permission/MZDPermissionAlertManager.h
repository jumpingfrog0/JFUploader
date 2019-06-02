//
//  MZDPermissionAlertManager.h
//  iLoving
//
//  Created by lfeng on 16/4/29.
//  Copyright © 2016年 MZD. All rights reserved.
//  请求用户各项权限，引导用户开启各项权限

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MZDPermissionType) {
    MZDPermissionTypeNotification = 1,
    MZDPermissionTypePhoto,
    MZDPermissionTypeCamera,
    MZDPermissionTypeMacrophone,
    MZDPermissionTypeLocation,
    MZDPermissionTypeSystemLocation,
};

typedef void(^MZDPermissionAlertViewCancelBlock)();
typedef void(^MZDPermissionAlertViewCompleteBlock)();

@interface MZDPermissionAlertManager : NSObject

+ (void)popPermissionAlertViewWithType:(MZDPermissionType)type
                           cancelBlock:(MZDPermissionAlertViewCancelBlock)cancelBlock
                         completeBlock:(MZDPermissionAlertViewCompleteBlock)completeBlock;
@end
