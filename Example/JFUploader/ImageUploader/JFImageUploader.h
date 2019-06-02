//
//  JFImageUploader.h
//  JFUploader_Example
//
//  Created by sheldon on 2019/6/1.
//  Copyright © 2019 jumpingfrog0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFImageUploader : NSObject
+ (void)uploadImage:(UIImage *)image completion:(void (^ __nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
