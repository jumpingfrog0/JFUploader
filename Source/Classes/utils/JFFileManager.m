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


#import "JFFileManager.h"

@implementation JFFileManager
+ (NSString *)removeFilePath:(NSString *)path {
    NSString *filePath = JFDocumentsFilePath(path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath] || !path) {
        NSLog(@"Warning: [JFFileManger %@] File not exist... | path: %@", NSStringFromSelector(_cmd), filePath);
        return nil;
    }
    else {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            NSLog(@"Error: [JFFileManager %@] Remove File failed... | path: %@", NSStringFromSelector(_cmd), filePath);
            return nil;
        }
    }
    return filePath;
}

+ (NSString *)createDirectoryPath:(NSString *)path {
    NSString *filePath = JFDocumentsFilePath(path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error :[JFFileManager: %@] Create Directory Failed... | path: %@", NSStringFromSelector(_cmd), filePath);
            return nil;
        }
    }
    return filePath;
}


// filePath为相对路径
+ (BOOL)object:(id)object writeToFile:(NSString *)filePath atomically:(BOOL)atomically {
    if (filePath) {
        NSString *fileDirectoryPath = [filePath stringByDeletingLastPathComponent];
        NSString *fileName = [filePath lastPathComponent];
        NSString *wholeDirectoryPath = [JFFileManager createDirectoryPath:fileDirectoryPath];
        if (wholeDirectoryPath) {
            NSString *wholePath = [wholeDirectoryPath stringByAppendingPathComponent:fileName];
            if ([object isKindOfClass:[NSDictionary class]]) {
                return [((NSDictionary *)object) writeToFile:wholePath atomically:atomically];
            }
            else if ([object isKindOfClass:[NSData class]] || [object isKindOfClass:[NSArray class]]) {
                return [object writeToFile:wholePath atomically:atomically];
            }
            else {
                NSError *error = nil;
                BOOL result = [object writeToFile:wholePath atomically:atomically encoding:NSUTF8StringEncoding error:&error];
                if (error) {
                    NSLog(@"Error:[JFFileManager: %@] Write to file: %@ failed... reason: %@", NSStringFromSelector(_cmd), JFDocumentsFilePath(filePath), [error localizedDescription]);
                }
                return result;
            }
        }
        else {
            NSLog(@"Error:[JFFileManager: %@] Write to file: %@ failed... app reason: Path error !", NSStringFromSelector(_cmd), JFDocumentsFilePath(filePath));
        }
    }
    NSLog(@"Error:[JFFileManager: %@] filePath must not be nil...", NSStringFromSelector(_cmd));
    return NO;
}

@end
