#import "ImagePickerViewController.h"
#import "cocos2d.h"
#import "MyNickImageViewController.h"
#import "CYPlatform.h"
#import "AppController.h"

@interface ImagePickerViewController ()

@end

@implementation ImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self localPhoto];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)localPhoto{
    AppController * myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.isSupportedPortrait = YES;
    MyNickImageViewController *picker = [[MyNickImageViewController alloc] init];
    picker.delegate      = self;
    picker.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self.view.window.rootViewController presentModalViewController:picker animated:YES];
//    [self presentViewController:picker animated:YES completion:^(void){
//        NSLog(@"Imageviewcontroller is presented");
//    }];
    [picker autorelease];
    
    NSLog(@"-(void)localPhoto();");
}

- (void)takePhoto{
    AppController * myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.isSupportedPortrait = YES;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([MyNickImageViewController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        MyNickImageViewController* picker = [[MyNickImageViewController alloc] init];
        picker.delegate = self;
        //设置拍照后的图像可编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;

        [self.view.window.rootViewController presentModalViewController:picker animated:YES];
        [picker autorelease];
    }
    else{
        NSLog(@"模拟器中无法打开照相机，请在真机中调试");
    }
}

- (void)imagePickerController:(MyNickImageViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    AppController * myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.isSupportedPortrait = NO;
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
//        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage* image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        UIImage *smallImage=[self scaleFromImage:image toSize:CGSizeMake(110.0f, 110.0f)];//将图片尺寸改为110*110
    
        
        NSData *data;
//        if (UIImagePNGRepresentation(smallImage) == nil)
//        {
            data = UIImageJPEGRepresentation(smallImage, 0.7);
//        data = UIImageJPEGRepresentation(image, 1.0);
//        }
//        else
//        {
//            data = UIImagePNGRepresentation(smallImage);
//        }
        
        //图片保存的路径
        //这里将图片放在沙盒的documents文件夹中
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        //文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //生成唯一字符串
        NSString* uuid = [[NSUUID UUID] UUIDString];
         CYUserInfo* userInform = [CYPlatform sharePlatform].userInfo;
        NSInteger  _userID = [userInform userID];
        //文件名
        NSString * imageFilePath = [[NSString alloc]initWithFormat:@"%@%@", DocumentsPath, @"/avatarImages"];
        NSString* fileName = [NSString stringWithFormat:@"/%d", _userID];
        filePath = [[NSString alloc]initWithFormat:@"%@%@", imageFilePath, fileName];
//         NSLog(@"filePath=%@",filePath);
        // 目录不存在则创建
        BOOL isFileExist = [[NSFileManager defaultManager] isExecutableFileAtPath:imageFilePath];
        if (!isFileExist)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:imageFilePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        //把刚刚图片转换的data对象拷贝至沙盒中 并保存为XXXXXXXX-XXXX-XXXX....XXXX.png
//        [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        [[CYPlatform sharePlatform] uploadAvatarImage:smallImage];
        //得到选择后沙盒中图片的完整路径
        
       
        //关闭相册界面
        [picker dismissModalViewControllerAnimated:YES];
        
        std::string strFilePath = [filePath UTF8String];
        cocos2d::Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("ImagePickerEvent", &strFilePath);
    }
    
}
// 改变图像的尺寸，方便上传服务器
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)imagePickerControllerDidCancel:(MyNickImageViewController *)picker{
    AppController * myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.isSupportedPortrait = NO;
    NSLog(@"您取消了选择图片");
    [picker dismissModalViewControllerAnimated:YES];
}

-(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context, 1);
    
    //CGContextSetStrokeColorWithColor(context, [UIColorredColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}

@end
