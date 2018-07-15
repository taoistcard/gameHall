//
//  CYDes.m
//  98Platform
//
//  Created by 张克敏 on 14-4-25.
//  Copyright (c) 2014年 CY. All rights reserved.
//

#import "CYDes.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation CYDes
@synthesize key = _key;
@synthesize iv = _iv;

- (NSString *)encrypt:(NSString *)str
{
    Byte *srcBytes = (Byte *)[str UTF8String];
    
    size_t dataLength = strlen((const char*)srcBytes);
    Byte *encryptBytes = malloc(1024);
    memset(encryptBytes, 0, 1024);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [_key UTF8String],
                                          kCCKeySizeDES,
                                          [_iv UTF8String],
                                          srcBytes,
                                          dataLength,
                                          encryptBytes,
                                          1024,
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        return [CYDes bin2hex:encryptBytes];
    }
    
    return nil;
}

- (NSString *)decrypt:(NSString *)str
{
    Byte *srcBytes = [CYDes hex2bin:str];
    
    size_t dataLength = strlen((const char*)srcBytes);
    Byte *decryptBytes = malloc(1024);
    memset(decryptBytes, 0, 1024);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [_key UTF8String],
                                          kCCKeySizeDES,
                                          [_iv UTF8String],
                                          srcBytes,
                                          dataLength,
                                          decryptBytes,
                                          1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess)
    {
        return [NSString stringWithUTF8String:(const char*)decryptBytes];
    }
    
    return nil;
}

+ (NSString *)bin2hex:(Byte *)bytes
{
    NSMutableString *output = [NSMutableString string];
    int length = strlen((const char *)bytes);
    for (int i = 0; i < length; i++)
    {
        [output appendFormat:@"%02x", (bytes[i] & 0xFF)];
    }
    return output;
}

+ (Byte *)hex2bin:(NSString *)hexString
{
    int length = [hexString length] / 2;
    Byte *bytes = malloc(length + 1);
    memset(bytes, 0, length + 1);
    
    for (int i = 0; i < length; i++)
    {
        int index = 2 * i;
        //两位16进制数中的第一位(高位*16)
        unichar hex_char1 = [hexString characterAtIndex:index];
        int int_ch1;
        if (hex_char1 >= '0' && hex_char1 <= '9')
        {
            int_ch1 = (hex_char1 - 48) * 16; //0的Ascll - 48
        }
        else if (hex_char1 >= 'A' && hex_char1 <= 'F')
        {
            int_ch1 = (hex_char1 - 55) * 16; //A的Ascll - 65
        }
        else
        {
            int_ch1 = (hex_char1 - 87) * 16; //a的Ascll - 97
        }
        index++;
        
        //两位16进制数中的第二位(低位)
        unichar hex_char2 = [hexString characterAtIndex:index];
        int int_ch2;
        if (hex_char2 >= '0' && hex_char2 <= '9')
        {
            int_ch2 = (hex_char2 - 48); //0的Ascll - 48
        }
        else if (hex_char1 >= 'A' && hex_char1 <='F')
        {
            int_ch2 = hex_char2 - 55; //A的Ascll - 65
        }
        else
        {
            int_ch2 = hex_char2 - 87; //a的Ascll - 97
        }
        
        // 两位16进制数转化后的10进制数
        bytes[i] = int_ch1 + int_ch2;
    }
    
    return bytes;
}

@end
