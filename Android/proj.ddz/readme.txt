/****************by zhaxun 2015-12-29****************/

本工程路径：runtime-src/proj.android_no_anysdk
使用说明：

1、lib库的生成和使用
    a、该工程为基础库工程，用于生成libcocos2dlua.so文件, build_native.sh用于debug的so文件生成，build_native_release.sh用语release的so文件生成，so文件生成后放在ini目录下
    b、如要发布新渠道，请拷贝整个目录，lib文件请使用本工程生成的lib库
    c、Andoird.mk和Application.mk中添加相应的lib库和宏定义


2、资源的配置和使用
    a、assets资源请使用update.sh进行更新，具体可以参考lua工程，或者修改update.sh文件
    b、string.xml, channel与UMENG_CHANNEL相同,其他参数请参考下面文件配置,具体参数值请填写对应应用在平台的配置信息

<resources>
    <string name="app_name">欢乐斗地主</string>
    <string name="channel">CMCC</string>
    <string name="channel_name">移动MM</string>
    <string name="AppId">1005</string>
    <string name="AppKey">34a9c6a95776107d065672c4eec6213d</string>
    <string name="AppServer">3</string>
    
    <!--UMeng  -->
    <string name="UMENG_APPKEY">55c8622767e58ef6ff0037ba</string>
    <string name="UMENG_CHANNEL">CMCC</string>
    <string name="UMENG_MESSAGE_SECRET">e9d3483aae154462c300eaee04a0de67</string>
       
    
    <!--Tecent -->
    <string name="QQ_AppId">1104678578</string>
    <string name="QQ_AppKey">fg89ghDDtD5nE4L7</string>
    <string name="QQ_Scope">get_user_info,get_simple_userinfo</string>
    
    <!-- weichat -->
    <string name="Wechat_AppId">wx4fe4f4dc50342a2c</string>
    
</resources>

    c、AndroidManifest.xml文件中的配置参数，请引用string.xml中的配置或工程配置
    