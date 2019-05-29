//
//  JFImageUploadTask.m
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

#import "JFImageUploadTask.h"
#import "_JFImageUploadCache.h"
#import "_JFImageUploadData.h"
#import "_JFUpyunUploadOperation.h"


@interface JFImageUploadTask ()

@property (nonatomic, strong) _JFImageUploadData *uploadData;
@property (nonatomic, strong) _JFImageUploadCache *uploadCache;
@property (nonatomic, strong) _JFUpyunUploadOperation *uploadOperation;
@end

@implementation JFImageUploadTask

- (instancetype)init
{
    if (self = [super init]) {
        self.uploadCache      = [[_JFImageUploadCache alloc] init];
        // todo
//        NSString *path        = [JFAccountService sharedInstance].creditService.sandbox;
//        self.uploadCache.path = [path stringByAppendingPathComponent:@"media"];

        self.uploadData      = [[_JFImageUploadData alloc] init];
        self.uploadOperation = [[_JFUpyunUploadOperation alloc] init];
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

- (void)setImage:(UIImage *)image
{
    self.uploadData.image = image;
}

- (void)setImagePath:(NSString *)imagePath
{
    self.uploadData.path = imagePath;
}

- (void)setImageURL:(NSURL *)imageURL
{
    self.uploadData.url = imageURL;
}

- (void)setCompress:(BOOL)compress
{
    self.uploadData.compress = compress;
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

- (void)setPolicy:(NSString *)policy {
    self.uploadOperation.policy = policy;
}

- (void)setSignature:(NSString *)signature {
    self.uploadOperation.signature = signature;
}

- (void)setTokenRequest:(JFHTTPRequest *)request
{
    self.uploadOperation.request = request;
}

@end
