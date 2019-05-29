//
//  _JFQiniuUploadManager.m
//  JFUploader
//
//  Created by jumpingfrog0 on 05/24/2019.
//
//
//  Copyright (c) 2019 Jumpingfrog0 LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "_JFQiniuUploadManager.h"
#import "NSError+JFUploader.h"
#import <AFNetworking/AFHTTPSessionManager.h>

@interface _JFQiniuUploadManager ()
@property(nonatomic, strong) NSURL          *serverURL;
@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) AFHTTPSessionManager *session;

@end

@implementation _JFQiniuUploadManager

- (instancetype)init
{
    if (self = [super init]) {
        self.tasks = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static _JFQiniuUploadManager *sharedClient_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient_ = [[_JFQiniuUploadManager alloc] init];
    });

    return sharedClient_;
}

+ (void)schedule:(_JFQiniuUploadOperation *)operation
{
    _JFQiniuUploadManager *manager = [_JFQiniuUploadManager sharedInstance];
    manager.serverURL = [NSURL URLWithString:operation.baseURL];
    manager.session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:operation.baseURL]];

    NSString *name     = @"file";
    NSString *fileName = @"file";

    NSDictionary *params = @{
        @"token": operation.token,
    };

    AFHTTPRequestSerializer<AFURLRequestSerialization> *rs = manager.session.requestSerializer;

    NSMutableURLRequest *request = [rs
        multipartFormRequestWithMethod:@"POST"
                             URLString:manager.session.baseURL.absoluteString
                            parameters:params
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                 [formData appendPartWithFileData:operation.data name:name fileName:fileName mimeType:operation.mime];
             }
                                 error:NULL];

//    NSMutableURLRequest *modifiedReq = [[JFDnsManager sharedManager] transformMutableRequest:request];
    NSMutableURLRequest *modifiedReq = request;

    AFHTTPSessionManager *s = manager.session;
    operation.task = [s uploadTaskWithStreamedRequest:modifiedReq
                                progress:operation.progress
                       completionHandler:^(NSURLResponse *resp, id respObj, NSError *e) {
                           if (!e) {
                               if (!respObj[@"key"]) {
                                   if (operation.failure) {
                                       NSString *message = @"七牛服务器返回 path = nil";
                                       NSError *error    = [NSError jf_uploader_errorWithCode:2 message:message];
                                       operation.failure(error);
                                   }
                               } else if (operation.success) {
                                   NSMutableDictionary *respJSON = [NSMutableDictionary dictionaryWithDictionary:respObj];
                                   NSString *url = [[NSURL URLWithString:operation.uriPrefix] URLByAppendingPathComponent:respJSON[@"key"]].absoluteString;
                                   respJSON[@"url"] = url;
                                   operation.success(respJSON);
                               }
                           } else {
                               if (operation.failure) {
                                   operation.failure(e);
                               }

                               // NSError URL Loading System Error Codes 判定走 dns 解析
                               if (e.code < 0) {
                                   // todo: dns defend
//                                   [[JFDnsManager sharedManager] invalidateURL:resp.URL];
                               } else if ([resp isKindOfClass:NSHTTPURLResponse.class]) {
                                   NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)resp;

                                   // todo: dns defend
//                                   if (urlResponse.statusCode >= 400) {
//                                       if (urlResponse.statusCode < 500) {
//                                           [[JFDnsManager sharedManager] invalidateURL:resp.URL];
//                                       }
//                                   }
                               }

                               // TODO: 上报失败统计
                               // 上报失败统计
//                               CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
//                               NSDictionary *param          = @{
//                                   @"carrier": info.subscriberCellularProvider.carrierName,
//                                   @"network": [JFHTTPClient network],
//                                   @"err_code": @(e.code),
//                               };
//                               [MobClick event:@"QiniuUploadFailure" attributes:param];
                           }
                           [manager.tasks removeObject:operation.task];
                           operation.task = nil;
                       }];
    [operation.task resume];
    [manager.tasks addObject:operation.task];
}

@end
