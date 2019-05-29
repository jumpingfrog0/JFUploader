//
//  _JFImageUploadData.m
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

#import "_JFImageUploadData.h"
#import <JFUIKit/JFUIKit.h>

#define IMAGE_CACHE_WIDTH 1280.0
@interface UIImage (JFImageUploadTaskCompression)

@end

@implementation UIImage (JFImageUploadTaskCompression)

- (NSData *)jf_compressedJPEGImageData
{
    // todo
    CGFloat compressRate = 0.3;
    CGSize imageSize     = [UIImage jf_sizeForUploadWithImageSize:self.size compressRate:&compressRate];
    UIImage *targetImage = [self jf_resizedImage:imageSize interpolationQuality:kCGInterpolationDefault];

    return UIImageJPEGRepresentation(targetImage, compressRate);
}

+ (CGSize)jf_sizeForUploadWithImageSize:(CGSize)size compressRate:(CGFloat *)compressRate
{
    CGFloat imageWidth  = size.width;
    CGFloat imageHeight = size.height;

    if (imageWidth >= 1280.0) {
        CGFloat ratio = imageWidth / IMAGE_CACHE_WIDTH;
        imageHeight   = imageHeight / ratio;
        imageWidth    = IMAGE_CACHE_WIDTH;
        *compressRate = 0.3;
    } else if (imageWidth <= 720) {
        *compressRate = 0.6;
    } else {
        *compressRate = 0.8;
    }
    return CGSizeMake(imageWidth, imageHeight);
}

@end

@interface _JFImageUploadData ()

@property (nonatomic, strong) NSData *originData;
@property (nonatomic, strong) NSData *uploadData;

@end

@implementation _JFImageUploadData

- (NSData *)originData
{
    if (_originData) {
        return _originData;
    }

    if (self.image) {
        _originData = UIImageJPEGRepresentation(self.image, 1.0);
    } else if (self.path) {
        _originData = [NSData dataWithContentsOfFile:self.path];
    } else if (self.url) {
        _originData = [NSData dataWithContentsOfURL:self.url];
    }
    return _originData;
}

- (NSData *)cacheData
{
    return self.uploadData;
}

- (NSData *)backupData
{
    if (self.persistence) {
        return self.originData;
    }

    return nil;
}

- (NSData *)uploadData
{
    if (!_uploadData) {
        if (self.compress) {
            if (self.image) {
                _uploadData = [self.image jf_compressedJPEGImageData];
            } else {
                UIImage *image = [[UIImage alloc] initWithData:self.backupData];
                _uploadData    = [image jf_compressedJPEGImageData];
            }
        } else {
            _uploadData = self.originData;
        }
    }

    return _uploadData;
}

- (NSString *)mimeType
{
    return @"image/jpeg";
}


@end
