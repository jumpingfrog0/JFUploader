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

//+ (void)uploadImage:(UIImage *)image completion:(void (^ __nullable)(void))completion {
//    JFHTTPRequest *tokenRequest = [[JFHTTPRequest alloc] init];
//    tokenRequest.method = @"get";
//    tokenRequest.api = @"/getQiniuToken";
//    tokenRequest.mock = YES;
//    tokenRequest.sign = NO;
//
//    NSData *data = UIImagePNGRepresentation(image);
//
//    JFVideoUploadTask *task = [[JFVideoUploadTask alloc] init];
////    [task setImage:image];
//    [task setTokenRequest:tokenRequest];
////    [task setUploadOperation:]
//    task.success = ^(NSDictionary *result, NSString *cachePath) {
//        NSLog(@"result = %@", result);
//        NSLog(@"cachePath = %@", cachePath);
//    };
//    task.failure = ^(NSError *error) {
//        NSLog(@"%@", error);
//    };
//    [JFUploadQueue runTask:task];
//}

+ (void)uploadImage:(UIImage *)image completion:(void (^ __nullable)(void))completion {
    JFHTTPRequest *tokenRequest = [[JFHTTPRequest alloc] init];
    tokenRequest.method = @"get";
    tokenRequest.api = @"/getQiniuToken";
    tokenRequest.mock = YES;
    tokenRequest.sign = NO;
    
    NSData *data = UIImagePNGRepresentation(image);
    
    JFVideoUploadTask *task = [[JFVideoUploadTask alloc] init];
    [task setVideo:data];
    [task setTokenRequest:tokenRequest];
    //    [task setUploadOperation:]
    task.success = ^(NSDictionary *result, NSString *cachePath) {
        NSLog(@"result = %@", result);
        NSLog(@"cachePath = %@", cachePath);
    };
    task.failure = ^(NSError *error) {
        NSLog(@"%@", error);
    };
    task.progress = ^(NSProgress *progress) {
        NSLog(@"progress = %f", progress.completedUnitCount * 1.0 / progress.totalUnitCount);
    };
    [JFUploadQueue runTask:task];
}
@end
