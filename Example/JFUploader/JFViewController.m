//
//  JFViewController.m
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

#import "JFViewController.h"
#import "JFImageUploader.h"
#import "MZDPermissionInspector.h"

typedef void(^JFPermissionBlock)(BOOL valid);

@interface JFViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation JFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    
    [MZDPermissionInspector checkPhotoPermissionWithPermissionBlock:^(BOOL valid) {
        if (!valid) { return; }
        
        [self presentViewController:picker animated:YES completion:nil];
    } alertCancelBlock:nil alertCompleteBlock:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [JFImageUploader uploadImage:image completion:nil];
    
    [self dismissViewControllerAnimated:picker completion:nil];
}

@end
