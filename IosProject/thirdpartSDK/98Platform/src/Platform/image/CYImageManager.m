//
//  CYImageManager.m
//  98Platform
//
//  Created by yuval on 9/29/13.
//
//

#import "CYImageManager.h"
#import "CYPlatform.h"
#import "CYHttpDefine.h"
#import "CYConstants.h"

#import "ASIFormDataRequest.h"

@implementation CYImageManager

#pragma mark - api
- (void)clearCache
{
    [_imageCache removeAllObjects];
}

- (void)uploadImage:(UIImage *)image
{
    NSURL *url = [NSURL URLWithString:CY_HTTP_UPLOAD_IMAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:30];
    request.delegate = self;
    [request setDidFailSelector:@selector(uploadImageFailed:)];
    [request setDidFinishSelector:@selector(uploadImageFinished:)];
    
    // param
    NSString *sessionID = [CYPlatform sharePlatform].sessionID;
//    NSData *data;
//    if (UIImagePNGRepresentation(image) == nil)
//    {
//        data = UIImageJPEGRepresentation(image, 1.0);
//    }
//    else
//    {
//        data = UIImagePNGRepresentation(image);
//    }
    NSData *data = UIImageJPEGRepresentation(image, 0.7);
    [request addPostValue:sessionID forKey:@"sessionid"];
    [request addData:data forKey:@"avatarpic"];
    // start
    [request startSynchronous];
}

- (UIImage *)imageWithUserID:(NSInteger)userID
{
    if (userID < 1)
    {
        return nil;
    }
    
    NSString *key = [NSString stringWithFormat:@"%d", userID];
    UIImage *image = nil;
    
    //先从内存里面找
    if ([_imageCache count] > 0)
    {
        image = [_imageCache objectForKey:key];
    }
    
    //内存里木有，再去本地找，找到后查看是否要更新
    if (!image)
    {
        image = [self checkImageWithUserID:key];
    }
    
    //本地也木有，就去下载
    if (!image)
    {
        [self downloadImageWithUID:key lastModifiedDate:nil];
    }
    
    return image;
}
- (NSString *)imagePathWithUserID:(NSInteger)userID
{

    if (userID < 1)
    {
        return nil;
    }
     NSString *key = [NSString stringWithFormat:@"%d", userID];
    NSString * imagePath = nil;
    
    if (!imagePath) {
        imagePath = [self checkImagePathWithUserID:key];
    }
    //本地也木有，就去下载
    if (!imagePath)
    {
        [self downloadImageWithUID:key lastModifiedDate:nil];
    }
    return imagePath;
}
#pragma mark - Http Callback
- (void)uploadImageFailed:(ASIFormDataRequest *)request
{
    id callback = [CYPlatform sharePlatform].customAvatarDelegate;
    if (callback)
    {
        [callback onCYAvatarUploadResult:CY_FAILURE md5:nil tokenID:nil];
    }
}

- (void)uploadImageFinished:(ASIFormDataRequest *)request
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[request responseData] options:kNilOptions error:nil];
    NSNumber *responseCode = [dic valueForKey:@"code"];
    NSString * avatar_md5 = [dic valueForKey:@"avatar_md5"];
    NSString * userid = [dic valueForKey:@"userid"];
    if ([responseCode integerValue] == 1000)
    {
        id callback = [CYPlatform sharePlatform].customAvatarDelegate;
        if (callback)
        {
            [callback onCYAvatarUploadResult:CY_SUCCESS md5:avatar_md5 tokenID:userid];
        }
//        NSString *uid = [NSString stringWithFormat:@"%d", [CYPlatform sharePlatform].userInfo.userID];
//        UIImage *image = [UIImage imageWithData:[request postValueForKey:@"avatarpic"]];
//        if (!image)
//        {
//            return;
//        }
//        [_imageCache setObject:image forKey:uid];
    }else{
        id callback = [CYPlatform sharePlatform].customAvatarDelegate;
        if (callback)
        {
            [callback onCYAvatarUploadResult:[responseCode integerValue ] md5:avatar_md5 tokenID:userid];
        }
        NSString * msg = [dic valueForKey:@"msg"];
        NSLog(@"msg=%@responseCode=%@",msg,responseCode);
    }
        
}

- (void)downloadImageFailed:(ASIHTTPRequest *)request
{
    NSLog(@"download Image Fail-------------");
}

- (void)downloadImageFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    UIImage *downloadImage = [UIImage imageWithData:data];
    NSDictionary *userInfo = [request userInfo];
    NSString *uid = [userInfo objectForKey:@"uId"];
    NSNumber *check = [userInfo objectForKey:@"Check"];
    NSString *downloadDate = [userInfo objectForKey:@"downlodaDate"];
    NSString *modified = [[request responseHeaders] objectForKey:@"Last-Modified"];
    //头像不存在
    if (downloadImage == nil)
    {
        id callback = [CYPlatform sharePlatform].customAvatarDelegate;
        if (callback)
        {
            [callback onCYAvatarDownloadResult:CY_FAILURE data:@"头像不存在" tokenID:uid];
        }
        return;
    }
    //If-Modified-Since
    if ([check boolValue])
    {
        if ([request responseStatusCode] == 304)
        {
            //更改文件名，修改其downloadDate字段
            NSString *oldName = [_imagePaths valueForKey:uid];
            NSString *newName = [NSString stringWithFormat:@"%@_%@_%@", uid, downloadDate, modified];
            [self renameImageWithOldName:oldName newName:newName];
            return ;
        }
    }
    
    //文件命名，uid_下载时间_LastModified
//    NSString *imageName=[NSString stringWithFormat:@"%@_%@_%@", uid, downloadDate, modified];
    NSString *imageName=[NSString stringWithFormat:@"%@", uid];
//    NSLog(@"imageName=%@",imageName);
    [self clearCheckPortraitWithUserID:uid];
    [self saveImage:data withName:imageName];
    NSString *savePath = [_imageFilePath stringByAppendingPathComponent:imageName];
//    NSLog(@"savePath=%@",savePath);
    [_imageCache setObject:downloadImage forKey:uid];
    
    id callback = [CYPlatform sharePlatform].customAvatarDelegate;
    if (callback)
    {
        [callback onCYAvatarDownloadResult:CY_SUCCESS data:savePath tokenID:uid];
    }
}

#pragma mark - PrivateMethod
- (NSString *)getDownloadURLWithUID:(NSString *)userID
{
    // 长度不够，用0补齐
    NSMutableString *url = [NSMutableString string];
    NSInteger zeroCount = 11 - [userID length];
    for (NSInteger i = 0; i < zeroCount; i++)
    {
        [url appendString:@"0"];
    }
    [url appendString:userID];
    [url insertString:@"/" atIndex:3];
    [url insertString:@"/" atIndex:7];
    [url insertString:@"/" atIndex:11];
    [url appendString:@"_avatar_large"];
    [url insertString:CY_HTTP_DOWNLOAD_IMAGE_PREFIX atIndex:0];
    
    return url;
}

- (void)downloadImageWithUID:(NSString *)uid lastModifiedDate:(NSString *)modifiedDate
{
    NSString *todayDate = [self getTodayDateString];
    CYUserInfo* userInform = [CYPlatform sharePlatform].userInfo;
    NSString* url = userInform.avatar;
//    NSURL *imageUrl = [NSURL URLWithString:[self getDownloadURLWithUID:uid]];
    NSURL *imageUrl = [NSURL URLWithString:url];

    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageUrl];
    NSDictionary *userInfo = nil;
    if (modifiedDate)
    {
        NSMutableDictionary *header = [NSMutableDictionary dictionaryWithObject:modifiedDate forKey:@"If-Modified-Since"];
        [request setRequestHeaders:header];
        
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    todayDate, @"downlodaDate",
                    uid, @"uId",
                    [NSNumber numberWithBool:YES], @"Check",
                    nil];
    }
    else
    {
        userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                    todayDate, @"downlodaDate",
                    uid, @"uId",
                    [NSNumber numberWithBool:NO], @"Check",
                    nil];
    }
    
    [request setUserInfo:userInfo];
    [_downloadQueue addOperation:request];
}
- (void)downloadAvatarImageByTokenIdAndMd5:(NSInteger)tokenId md5:(NSString *)md5
{
    NSDictionary *userInfo = nil;
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                tokenId, @"uId",
                nil];
    NSURL *imageUrl = [NSURL URLWithString:[self getDownloadURLWithUID:tokenId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:imageUrl];
    [request setUserInfo:userInfo];
    [_downloadQueue addOperation:request];
}
- (BOOL)saveImage:(NSData *)data withName:(NSString *)name
{
    // 创建文件
    NSString *savePath = [_imageFilePath stringByAppendingPathComponent:name];
    NSLog(@"savePath----%@",savePath);
    BOOL isSuccess = [[NSFileManager defaultManager]createFileAtPath:savePath
                                                          contents:data
                                                        attributes:nil];
    return isSuccess;
}
- (NSString *)checkImagePathWithUserID:(NSString*)userID
{
    NSString * returnImagePath = nil;
    NSArray *imagePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_imageFilePath error:nil];
    for (NSString *fileName in imagePaths)
    {
        NSArray *temp = [fileName componentsSeparatedByString:@"_"];
        if ([temp count] < 3)
        {
            //.DS_STORE 这个东西发现了一个bug
            continue;
        }
        
        NSString *uid = [temp objectAtIndex:0];
        if (![userID isEqualToString:uid])
        {
            continue;
        }
        
        NSString *todayDate = [self getTodayDateString];
        NSString *filePath = [_imageFilePath stringByAppendingPathComponent:fileName];
        NSLog(@"filePath=%@",filePath);
        returnImagePath = filePath;

        
        // 检查是否需要更新
        NSString *downloadDate = [temp objectAtIndex:1];
        if (![todayDate isEqualToString:downloadDate])
        {
            NSString *modifiedDate = [temp objectAtIndex:2];
            [_imagePaths setObject:fileName forKey:userID];
            [self downloadImageWithUID:uid lastModifiedDate:modifiedDate];
        }else
        {
            id callback = [CYPlatform sharePlatform].customAvatarDelegate;
            if (callback)
            {
                [callback onCYAvatarDownloadResult:CY_SUCCESS data:returnImagePath];
            }
        }
    }
    return returnImagePath;
}
- (UIImage *)checkImageWithUserID:(NSString *)userID
{
    UIImage *returnImage = nil;
    
    NSArray *imagePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_imageFilePath error:nil];
    for (NSString *fileName in imagePaths)
    {
		NSArray *temp = [fileName componentsSeparatedByString:@"_"];
		if ([temp count] < 3)
		{
			//.DS_STORE 这个东西发现了一个bug
			continue;
		}
        
        NSString *uid = [temp objectAtIndex:0];
        if (![userID isEqualToString:uid])
        {
            continue;
        }
        
        NSString *todayDate = [self getTodayDateString];
        NSString *filePath = [_imageFilePath stringByAppendingPathComponent:fileName];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        returnImage = [UIImage imageWithData:imageData];
        
        // 内存缓存起来
        [_imageCache setObject:returnImage forKey:userID];
        
        // 检查是否需要更新
        NSString *downloadDate = [temp objectAtIndex:1];
        if (![todayDate isEqualToString:downloadDate])
        {
            NSString *modifiedDate = [temp objectAtIndex:2];
            [_imagePaths setObject:fileName forKey:userID];
            [self downloadImageWithUID:uid lastModifiedDate:modifiedDate];
        }
    }
    return returnImage;
}

- (void)clearCheckPortraitWithUserID:(NSString *)userID
{
    NSArray *imagePaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_imageFilePath error:nil];
    for (int i = 0; i<[imagePaths count]; i++)
    {
        NSString *fileName = [imagePaths objectAtIndex:i];
        NSArray *temp = [fileName componentsSeparatedByString:@"_"];
		
		if ([temp count] < 3)
		{
			continue;
		}
        NSString *uid = [temp objectAtIndex:0];
        if ([userID isEqualToString:uid])
        {
            NSString *fileFullPath = [_imageFilePath stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:fileFullPath error:nil];
        }
    }
}

- (NSString *)getTodayDateString
{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSUInteger unitFlags = (NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit);
    NSDateComponents *conponent = [cal components:unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%d",[conponent day]];
}

- (BOOL)renameImageWithOldName:(NSString *)oldName
                       newName:(NSString *)newName
{
    NSString *fileOldPaht = [_imageFilePath stringByAppendingPathComponent:oldName];
    NSString *fileNewPath = [_imageFilePath stringByAppendingPathComponent:newName];
    BOOL isRenameSuccess = [[NSFileManager defaultManager] moveItemAtPath:fileOldPaht
                                                                   toPath:fileNewPath
                                                                    error:nil];
    return isRenameSuccess;
}

#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self)
    {
        _downloadQueue = [[ASINetworkQueue alloc] init];
        [_downloadQueue setRequestDidFinishSelector:@selector(downloadImageFinished:)];
        [_downloadQueue setRequestDidFailSelector:@selector(downloadImageFailed:)];
        [_downloadQueue setDelegate:self];
        [_downloadQueue go];
        
        // 保存图片文件的目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatarImages"];
        _imageFilePath = [[NSString alloc] initWithString:filePath];
        // 目录不存在则创建
        BOOL isFileExist = [[NSFileManager defaultManager] isExecutableFileAtPath:_imageFilePath];
        if (!isFileExist)
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:_imageFilePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        // 缓存
        _imagePaths = [[NSMutableDictionary alloc] init];
        _imageCache = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_downloadQueue release];
    [_imageFilePath release];
    [_imagePaths release];
    [_imageCache release];
    [super dealloc];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"requestFinished");
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"requestFailed");
}

@end
