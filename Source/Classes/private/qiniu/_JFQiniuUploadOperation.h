//
//  _JFQiniuUploadOperation.h
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

#import "_JFUploadOperationProtocol.h"
#import <JFHTTP/JFHTTPRequest.h>

@interface _JFQiniuUploadOperation : NSOperation <_JFUploadOperationProtocol>

@property (nonatomic, copy) NSString *bucket;       // 存储空间
@property (nonatomic, copy) NSString *deadline;     // 失效时间
@property (nonatomic, copy) NSString *baseURL;      // 上传地址
@property (nonatomic, copy) NSString *token;        // 令牌
@property (nonatomic, copy) NSString *uriPrefix;    // 存储前缀

@property (nonatomic, strong) JFHTTPRequest *request;
@property (nonatomic, strong) NSURLSessionUploadTask *task;

@end
