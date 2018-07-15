//
//  ImagePickerViewController.h
//  PhotoSelecter
//
//  Created by 恒迅华成 on 15/6/4.
//
//

#import <UIKit/UIKit.h>

@interface ImagePickerViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString* filePath;
}

// 打开本地相册
- (void)localPhoto;

// 打开相机
- (void)takePhoto;

//裁切圆形
-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
@end
