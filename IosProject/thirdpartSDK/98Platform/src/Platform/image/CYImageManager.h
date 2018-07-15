//
//  CYImageManager.h
//  98Platform
//
//  Created by yuval on 9/29/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"

@interface CYImageManager : NSObject<ASIHTTPRequestDelegate>
{
    ASINetworkQueue     *_downloadQueue;
    NSString            *_imageFilePath;//随着用户帐户改变,即当用户切换帐户后删除
    NSMutableDictionary *_imagePaths;
    NSMutableDictionary *_imageCache;
}

- (void)clearCache;
- (void)uploadImage:(UIImage *)image;
- (UIImage *)imageWithUserID:(NSInteger)userID;
- (NSString *)imagePathWithUserID:(NSInteger)userID;
- (void)downloadAvatarImageByTokenIdAndMd5:(NSInteger)tokenId md5:(NSString *)md5;
@end




