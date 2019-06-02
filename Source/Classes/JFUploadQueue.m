//
//  JFUploadQueue.m
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

#import "JFUploadQueue.h"
#import "JFUploadTask.h"
#import "_JFUploadOperation.h"

@interface JFUploadQueue ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation JFUploadQueue

+ (instancetype)sharedInstance
{
    static JFUploadQueue *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[JFUploadQueue alloc] init];
    });

    return shared;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.queue                             = [[NSOperationQueue alloc] init];
        // todo: only concurrent one?
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

+ (void)runTask:(JFUploadTask *)task
{
    _JFUploadOperation *operation = [[_JFUploadOperation alloc] initWithTask:task];
    JFUploadQueue *queue          = [JFUploadQueue sharedInstance];
    [queue.queue addOperation:operation];
}

@end
