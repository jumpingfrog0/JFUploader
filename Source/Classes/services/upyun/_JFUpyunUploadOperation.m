//
//  _JFUpyunUploadOperation.m
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

#import "_JFUpyunUploadOperation.h"
#import "NSError+JFUploader.h"
#import "_JFUpyunUploadManager.h"
#import <JFHTTP/JFHTTP.h>

typedef NS_ENUM(NSInteger, JFUpyunUploadOperationState) {
    JFUpyunUploadOperationStateReady     = 0,
    JFUpyunUploadOperationStateExecuting = 1,
    JFUpyunUploadOperationStateFinished  = 2,
};

@interface _JFUpyunUploadOperation ()
@property(nonatomic, assign) JFUpyunUploadOperationState state;
@end

@implementation _JFUpyunUploadOperation
@synthesize data = _data;
@synthesize mime = _mime;
@synthesize success = _success;
@synthesize progress = _progress;
@synthesize failure = _failure;

- (void)setState:(JFUpyunUploadOperationState)newState
// Change the state of the operation, sending the appropriate KVO notifications.
{
    // any thread
    @synchronized (self) {
        JFUpyunUploadOperationState oldState;

        // The following check is really important.  The state can only go forward, and there
        // should be no redundant changes to the state (that is, newState must never be
        // equal to self->_state).

        // Transitions from executing to finished must be done on the run loop thread.

        oldState = self.state;
        if (newState == JFUpyunUploadOperationStateExecuting || oldState == JFUpyunUploadOperationStateExecuting) {
            [self willChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFUpyunUploadOperationStateFinished) {
            [self willChangeValueForKey:@"isFinished"];
        }

        _state = newState;
        if (newState == JFUpyunUploadOperationStateExecuting || oldState == JFUpyunUploadOperationStateExecuting) {
            [self didChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFUpyunUploadOperationStateFinished) {
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
    return self.state == JFUpyunUploadOperationStateExecuting;
}

- (BOOL)isFinished {
    // any thread
    return self.state == JFUpyunUploadOperationStateFinished;
}

- (void)cancel {
    if (!self.isFinished && !self.isCancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        [super cancel];
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
    self.state = JFUpyunUploadOperationStateExecuting;

    if ([self isCancelled]) {
        if (self.request.failure) {
            NSError *error = [NSError jf_uploader_errorWithCode:1 message:@"操作取消"];
            self.request.failure(error);
        }
        self.state = JFUpyunUploadOperationStateFinished;
        return;
    }

    if ((self.signature.length == 0 || self.policy.length == 0) && !self.request) {
        if (self.failure) {
            NSString *message = @"需要获取的又拍云的policy和signature";
            NSError  *error   = [NSError jf_uploader_errorWithCode:2 message:message];
            self.failure(error);
        }
        self.state = JFUpyunUploadOperationStateFinished;
        return;
    }

    __weak _JFUpyunUploadOperation *weakSelf = self;

    JFUploaderOperationSuccessBlock success = self.success;
    JFUploaderOperationFailureBlock failure = self.failure;

    self.success = ^(NSDictionary *result) {
        if (success) {
            success(result);
        }
        weakSelf.state = JFUpyunUploadOperationStateFinished;
    };
    self.failure = ^(NSError *error) {
        if (failure) {
            failure(error);
        }
        weakSelf.state = JFUpyunUploadOperationStateFinished;
    };

    if (self.signature.length > 0 && self.policy.length >0) {
        [_JFUpyunUploadManager schedule:self];
        return;
    }

    self.request.failure = self.failure;
    self.request.success = ^(NSDictionary *result) {
        weakSelf.policy    = result[@"policy"];
        weakSelf.signature = result[@"signature"];
        weakSelf.bucket    = result[@"bucket"];
        weakSelf.baseURL   = result[@"uri_prefix"];
        weakSelf.operator  = result[@"operator"];
        [_JFUpyunUploadManager schedule:weakSelf];
    };

    // todo
    [JFHTTPClient send:self.request];
}
@end
