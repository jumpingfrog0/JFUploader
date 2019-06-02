//
//  _JFUpyunUploadManager.m
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

#import "_JFUpyunUploadManager.h"
#import "NSError+JFUploader.h"
#import <AFNetworking/AFHTTPSessionManager.h>
#import <JFFoundation/JFFoundation.h>

static NSString *const UPLOAD_HOST = @"http://v0.api.upyun.com";

@interface _JFUpyunUploadManager () <NSURLSessionTaskDelegate>
@property(nonatomic, strong) NSURL          *serverURL;
@property(nonatomic, strong) NSMutableArray *tasks;

@property(nonatomic, strong) AFHTTPSessionManager *session;
@end

@implementation _JFUpyunUploadManager
- (instancetype)init {
    if (self = [super init]) {
        self.tasks = [NSMutableArray array];

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        sessionConfiguration.HTTPShouldSetCookies = YES;


        self.session = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        self.session.requestSerializer = [AFJSONRequestSerializer serializer];
        self.session.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.session.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static _JFUpyunUploadManager *sharedClient_ = nil;
    static dispatch_once_t        onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient_ = [[_JFUpyunUploadManager alloc] init];
    });

    return sharedClient_;
}

+ (void)schedule:(_JFUpyunUploadOperation *)operation {
    _JFUpyunUploadManager *manager = [_JFUpyunUploadManager sharedInstance];
    manager.serverURL = [NSURL URLWithString:[UPLOAD_HOST stringByAppendingPathComponent:operation.bucket]];

    NSString *fileName;
    if ([NSData jf_isPNGForImageData:operation.data]) {
        fileName = @"fileName.png";
    } else {
        fileName = @"fileName.jpeg";
    }

    NSDictionary *params = @{
                             @"policy" : operation.policy,
                             @"signature" : operation.signature,
                             };
    
    // append form data
    NSString *boundary = @"simpleHttpClientFormBoundaryFriSep25V01|hash3ad538ea94b02b486cc9e4ab6c499f69";
    boundary = [NSString stringWithFormat:@"%@%u", boundary,  arc4random() & 0x7FFFFFFF];
    NSMutableData *body = [NSMutableData data];
    for (NSString *key in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", params[key]]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (operation.data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",@"file", fileName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", operation.mime]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:operation.data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:manager.serverURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *task = nil;
    AFHTTPSessionManager   *s        = manager.session;
    task = [s uploadTaskWithStreamedRequest:request
                                progress:operation.progress
                       completionHandler:^(NSURLResponse *resp, id respObj, NSError *e) {
                           
                           NSMutableDictionary *respJSON = [NSMutableDictionary dictionaryWithDictionary:respObj];
                           NSLog(@"%@", respJSON);
                           
                           if (!e) {
                               if (!respJSON[@"url"]) {
                                   if (operation.failure) {
                                       NSString *message = @"又拍云服务器返回 url = nil";
                                       NSError  *error   = [NSError jf_uploader_errorWithCode:2 message:message];
                                       operation.failure(error);
                                   }
                               } else if (operation.success) {
                                   NSString *url = [operation.baseURL stringByAppendingString:respJSON[@"url"]];
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
                                   NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *) resp;

                                   // todo: dns defend
//                                   if (urlResponse.statusCode >= 400) {
//                                       if (urlResponse.statusCode < 500) {
//                                           [[JFDnsManager sharedManager] invalidateURL:resp.URL];
//                                       }
//                                   }
                               }

                               // TODO: 上报失败统计
                           }
                           [manager.tasks removeObject:task];
                       }];
    [task resume];
    [manager.tasks addObject:task];
}

#pragma mark NSURLSessionDelegate



- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {

}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSLog(@"%@", response);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {

    NSLog(@"%@ -- \n", data);
}
@end
