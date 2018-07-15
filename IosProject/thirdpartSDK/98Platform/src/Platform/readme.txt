新游戏接入时，请修改cyplatform.plist文件。
1.字段_98_app_info和Android版本一致的，可公用。具体生成办法详见Android版工程下的tool目录
2.字段channel为渠道标识，上传苹果AppStore的为a_01，可以不修改。其他联运渠道，请修改
3.初始化平台的接口
- (void)initPlatformWithItuesPruchaseProducts:(NSArray *)products;
参数products为所有的内购项，没有则为nil