//
//  JFImageUploader.m
//  JFUploader_Example
//
//  Created by sheldon on 2019/6/1.
//  Copyright © 2019 jumpingfrog0. All rights reserved.
//

#import "JFImageUploader.h"
#import <JFUploader/JFUploader.h>
#import <JFHTTP/JFHTTP.h>

@implementation JFImageUploader

+ (void)uploadImage:(UIImage *)image completion:(void (^ __nullable)(void))completion {
    JFHTTPRequest *tokenRequest = [[JFHTTPRequest alloc] init];
    tokenRequest.method = @"get";
    tokenRequest.api = @"/getQiniuToken";
    tokenRequest.mock = YES;
    tokenRequest.sign = NO;
    
    JFImageUploadTask *task = [[JFImageUploadTask alloc] init];
    [task setImage:image];
    [task setTokenRequest:tokenRequest];
//    [task setUploadOperation:]
    task.success = ^(NSDictionary *result, NSString *cachePath) {
        NSLog(@"result = %@", result);
        NSLog(@"cachePath = %@", cachePath);
    };
    task.failure = ^(NSError *error) {
        NSLog(@"%@", error);
    };
    [JFUploadQueue runTask:task];
}
@end
