//
//  _JFUploadOperation.m
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

#import "_JFUploadOperation.h"
#import "NSError+JFUploader.h"
#import "_JFQiniuUploadOperation.h"

typedef NS_ENUM(NSInteger, JFUploadOperationState) {
    JFUploadOperationStateReady = 0,
    JFUploadOperationStateExecuting,
    JFUploadOperationStateFinished,
};

@interface _JFUploadOperation ()

@property (nonatomic, strong) JFUploadTask *task;
@property (nonatomic, assign) JFUploadOperationState state;

@end

@implementation _JFUploadOperation

- (instancetype)initWithTask:(JFUploadTask *)task
{
    if (self = [super init]) {
        self.task = task;
    }
    return self;
}

- (void)setState:(JFUploadOperationState)newState
// Change the state of the operation, sending the appropriate KVO notifications.
{
    // any thread
    @synchronized(self)
    {
        JFUploadOperationState oldState;

        // The following check is really important.  The state can only go forward, and there
        // should be no redundant changes to the state (that is, newState must never be
        // equal to self->_state).

        // Transitions from executing to finished must be done on the run loop thread.

        oldState = self.state;
        if (newState == JFUploadOperationStateExecuting || oldState == JFUploadOperationStateExecuting) {
            [self willChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFUploadOperationStateFinished) {
            [self willChangeValueForKey:@"isFinished"];
        }

        _state = newState;
        if (newState == JFUploadOperationStateExecuting || oldState == JFUploadOperationStateExecuting) {
            [self didChangeValueForKey:@"isExecuting"];
        }

        if (newState == JFUploadOperationStateFinished) {
            [self didChangeValueForKey:@"isFinished"];
        }
    }
}

#pragma mark * Overrides
- (BOOL)isConcurrent
{
    // any thread
    return YES;
}

- (BOOL)isExecuting
{
    // any thread
    return self.state == JFUploadOperationStateExecuting;
}

- (BOOL)isFinished
{
    // any thread
    return self.state == JFUploadOperationStateFinished;
}

- (void)cancel
{
    if (!self.isFinished && !self.isCancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        [super cancel];
        self.task.willUpload = nil;
        self.task.success    = nil;
        self.task.progress   = nil;

        if (self.task.failure) {
            NSError *error = [NSError errorWithDomain:@"wake-upload"
                                                 code:1
                                             userInfo:@{
                                                 NSLocalizedDescriptionKey: @"取消操作",
                                             }];
            self.task.failure(error);
        }
        [self didChangeValueForKey:@"isCancelled"];
    }
}

- (void)start
{
    self.state = JFUploadOperationStateExecuting;

    if ([self isCancelled]) {
        if (self.task.failure) {
            NSError *error = [NSError jf_uploader_errorWithCode:1 message:@"操作取消"];
            self.task.failure(error);
        }
        self.state = JFUploadOperationStateFinished;
        return;
    }

    NSData *uploadData = nil;
    if ([self.task.data respondsToSelector:@selector(uploadData)]) {
        uploadData = self.task.data.uploadData;
    }
    if (!uploadData) {
        if (self.task.failure) {
            NSString *message = @"upload data = nil";
            NSError *error    = [NSError jf_uploader_errorWithCode:3 message:message];
            self.task.failure(error);
        }
        self.state = JFUploadOperationStateFinished;
        return;
    }

    NSData *backupData   = nil;
    NSString *backupPath = nil;
    if ([self.task.data performSelector:@selector(backupData)]) {
        backupData = self.task.data.backupData;
    }
    if (backupData) {
        if ([self.task.cache respondsToSelector:@selector(cacheObjectBeforeUploading:)]) {
            backupPath = [self.task.cache cacheObjectBeforeUploading:backupData];
        }
    }

    if (self.task.willUpload) {
        self.task.willUpload(uploadData, backupPath);
    }

    __weak _JFUploadOperation *weakSelf = self;
    __weak JFUploadTask *weakTask       = self.task;

    self.task.operation.data    = uploadData;
    self.task.operation.mime    = self.task.data.mimeType;
    self.task.operation.success = ^(NSDictionary *result) {
        NSData *cacheData   = nil;
        NSString *cachePath = nil;

        if ([weakTask.data performSelector:@selector(cacheData)]) {
            cacheData = weakTask.data.cacheData;
        }
        if (cacheData) {
            if ([weakTask.cache respondsToSelector:@selector(cacheObjectWhenUploaded:)]) {
                cachePath = [weakTask.cache cacheObjectWhenUploaded:cacheData];
            }
        }

        if (weakTask.success) {
            weakTask.success(result, cachePath);
        }
        weakSelf.state = JFUploadOperationStateFinished;
    };
    self.task.operation.progress = self.task.progress;
    self.task.operation.failure  = ^(NSError *error) {
        if (weakTask.failure) {
            weakTask.failure(error);
        }
        weakSelf.state = JFUploadOperationStateFinished;
    };

    [self.task.operation start];
}

@end
