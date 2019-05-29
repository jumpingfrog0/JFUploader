//
//  JFVideoUploadTask.m
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

#import "JFVideoUploadTask.h"
#import "_JFVideoUploadCache.h"
#import "_JFVideoUploadData.h"
#import "_JFQiniuUploadOperation.h"

@interface JFVideoUploadTask ()
@property (nonatomic, strong) _JFVideoUploadData *uploadData;
@property (nonatomic, strong) _JFVideoUploadCache *uploadCache;
@property (nonatomic, strong) _JFQiniuUploadOperation *uploadOperation;
@end

@implementation JFVideoUploadTask

- (instancetype)init
{
    if (self = [super init]) {
        self.uploadCache      = [[_JFVideoUploadCache alloc] init];
        // todo
//        NSString *path        = [JFAccountService sharedInstance].creditService.sandbox;
//        self.uploadCache.path = [path stringByAppendingPathComponent:@"video"];

        self.uploadData      = [[_JFVideoUploadData alloc] init];
        self.uploadOperation = [[_JFQiniuUploadOperation alloc] init];

        self.uploadData.persistence = YES;
    }
    return self;
}

- (id<JFUploadDataProtocol>)data
{
    return self.uploadData;
}

- (id<JFUploadCacheProtocol>)cache
{
    return self.uploadCache;
}

- (id<_JFUploadOperationProtocol>)operation
{
    return self.uploadOperation;
}

- (void)setVideo:(NSData *)videoData {
    self.uploadData.data = videoData;
}

- (void)setVideoPath:(NSString *)videoPath
{
    self.uploadData.path = videoPath;
}

- (void)setVideoURL:(NSURL *)videoURL
{
    self.uploadData.url = videoURL;
}

- (void)setPersistence:(BOOL)persistence
{
    self.uploadData.persistence = persistence;
}

- (void)setCacheKey:(NSString *)cacheKey
{
    self.uploadCache.key = cacheKey;
}

- (void)setCachePath:(NSString *)cachePath
{
    self.uploadCache.path = cachePath;
}

- (void)setToken:(NSString *)token
{
    self.uploadOperation.token = token;
}

- (void)setTokenRequest:(JFHTTPRequest *)request
{
    self.uploadOperation.request = request;
}

@end
