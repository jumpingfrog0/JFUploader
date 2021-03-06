//
//  _JFImageUploadCache.m
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

#import "_JFImageUploadCache.h"
#import "JFFileManager.h"
#import <JFFoundation/NSString+JFEncrypt.h>
//#import <SDWebImage/SDImageCache.h>

@implementation _JFImageUploadCache

- (NSString *)cachePath
{
    return [self.path stringByAppendingPathComponent:[self.key jf_md5]];
}

#pragma mark--
- (NSString *)cacheObjectBeforeUpload:(id)object
{
    NSString *cachePath = self.cachePath;
    [JFFileManager object:object writeToFile:cachePath atomically:NO];
    return cachePath;
}

- (NSString *)cacheObjectWhenUpload:(id)object
{
    // todo
//    [[SDImageCache sharedImageCache] storeImage:nil
//                           recalculateFromImage:NO
//                                      imageData:object
//                                         forKey:self.key
//                                         toDisk:YES];
    return nil;
}

@end
