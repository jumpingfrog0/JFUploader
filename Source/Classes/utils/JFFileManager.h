//
//  JFFileManager.m
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

#import <Foundation/Foundation.h>

// 获取Documents 下指定`fileName`为相对路径的文件的绝对路径
static inline NSString * JFDocumentsFilePath(NSString *fileName)
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [directories[0] stringByAppendingPathComponent:fileName];
}

// 获取Caches 下指定`fileName`为相对路径的文件的绝对路径
static inline NSString * JFCachesFilePath(NSString *fileName)
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [directories[0] stringByAppendingPathComponent:fileName];
}

#define JFImageDirectory  @"image"
#define JFAudioDirectory  @"audio"

/**
 *	@brief	文件管理器工具类，提供文件和目录的创建和删除操作
 */
@interface JFFileManager : NSObject

/**
 *	@brief	删除文件/目录，如果 path 为 nil，则删除 Documents 目录及其所属的所有文件
 *
 *	@param 	path 相对于 Documents 目录的相对路径
 *
 *	@return	如果删除成功，则返回删除文件的绝对路径，失败则返回nil
 */
+ (NSString *)removeFilePath:(NSString *)path;

/**
 *	@brief	创建目录，如果目录的中间路径不存在，则将中间目录一起创建
 *
 *	@param 	path 相对于Documents目录的相对路径
 *
 *	@return	如果创建目录成功，则返回创建目录的绝对路径，失败则返回nil
 */
+ (NSString *)createDirectoryPath:(NSString *)path;


+ (BOOL)object:(id)object writeToFile:(NSString *)filePath atomically:(BOOL)atomically;

@end
