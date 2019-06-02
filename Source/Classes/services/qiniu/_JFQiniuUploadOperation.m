//
//  _JFQiniuUploadOperation.m
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

#import "_JFQiniuUploadOperation.h"
#import "NSError+JFUploader.h"
#import "_JFQiniuUploadManager.h"

typedef NS_ENUM(NSInteger, JFQiniuUploadOperationState) {
    JFQiniuUploadOperationStateReady     = 0,
    JFQiniuUploadOperationStateExecuting = 1,
    JFQiniuUploadOperationStateFinished  = 2,
};

@interface _JFQiniuUploadOperation ()

@property(nonatomic, assign) JFQiniuUploadOperationState state;

@end

@implementation _JFQiniuUploadOperation
@synthesize data = _data;
@synthesize mime = _mime;
@synthesize success = _success;
@synthesize progress = _progress;
@synthesize failure = _failure;

- (void)setState:(JFQiniuUploadOperationState)newState
// Change the state of the operation, sending the appropriate KVO notifications.
{
    // any thread
    @synchronized (self) {
        JFQiniuUploadOperationState oldState;

        // The following check is really important.  The state can only go forward, and there
        // should be no redundant changes to the state (that is, newState must never be
        // equal to self->_state).

        // Transitions from executing to finished must be done on the run loop thread.

        oldState = self.state;
        if (newState == JFQiniuUploadOperationStateExecuting || oldState == JFQiniuUploadOperationStateExecuting) {
            [self willChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFQiniuUploadOperationStateFinished) {
            [self willChangeValueForKey:@"isFinished"];
        }

        _state = newState;
        if (newState == JFQiniuUploadOperationStateExecuting || oldState == JFQiniuUploadOperationStateExecuting) {
            [self didChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFQiniuUploadOperationStateFinished) {
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

#pragma mark * Overrides

- (BOOL)isConcurrent {
    // any thread
    return YES;
}

- (BOOL)isExecuting {
    // any thread
    return self.state == JFQiniuUploadOperationStateExecuting;
}

- (BOOL)isFinished {
    // any thread
    return self.state == JFQiniuUploadOperationStateFinished;
}

- (void)cancel {
    if (!self.isFinished && !self.isCancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        [super cancel];
        [self.task cancel];
        self.task     = nil;
        self.success  = nil;
        self.progress = nil;

        if (self.failure) {
            NSError *error = [NSError jf_uploader_errorWithCode:1 message:@"操作取消"];
            self.failure(error);
        }
        [self didChangeValueForKey:@"isCancelled"];
    }
}

- (void)start {
    self.state = JFQiniuUploadOperationStateExecuting;

    if ([self isCancelled]) {
        if (self.request.failure) {
            NSError *error = [NSError jf_uploader_errorWithCode:1 message:@"操作取消"];
            self.request.failure(error);
        }
        self.state = JFQiniuUploadOperationStateFinished;
        return;
    }

    if (self.token.length == 0 && !self.request) {
        if (self.failure) {
            NSString *message = @"需要获取七牛的上传token";
            NSError  *error   = [NSError jf_uploader_errorWithCode:2 message:message];
            self.failure(error);
        }
        self.state = JFQiniuUploadOperationStateFinished;
        return;
    }

    __weak _JFQiniuUploadOperation *weakSelf = self;

    JFUploaderOperationSuccessBlock success = self.success;
    JFUploaderOperationFailureBlock failure = self.failure;

    self.success = ^(NSDictionary *result) {
        if (success) {
            success(result);
        }
        weakSelf.state = JFQiniuUploadOperationStateFinished;
    };
    self.failure = ^(NSError *error) {
        if (failure) {
            failure(error);
        }
        weakSelf.state = JFQiniuUploadOperationStateFinished;
    };

    if (self.token.length > 0) {
        [_JFQiniuUploadManager schedule:self];
        return;
    }

    self.request.failure = self.failure;
    self.request.success = ^(NSDictionary *result) {
        weakSelf.baseURL   = result[@"upload_url"];
        weakSelf.bucket    = result[@"bucket"];
        weakSelf.deadline  = result[@"deadline"];
        weakSelf.token     = result[@"uptoken"];
        weakSelf.uriPrefix = result[@"uri_prefix"];
        [_JFQiniuUploadManager schedule:weakSelf];
    };

    // todo
//    [JFHTTPManager send:self.request];
}

@end
