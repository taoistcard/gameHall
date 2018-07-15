package com.zxsdk.UnitedPlatform;

//import com.zxsdk.IJKVideo.IJKVideoInterface;
import com.zxsdk.UnitedPlatform.UnitedPlatform;

import cn._98game.platform.Constants;


import android.app.Activity;
import android.util.Log;

public class MethodForLuaJ {
	static public String getChannel()
	{
		String ret =UnitedPlatform.getInstance().getChannelInfo(); 
		Log.i("DDZ", ret);
		return ret;
	}
	static public String getDeviceID()
	{
		return UnitedPlatform.getInstance().getDeviceID();
	}
	
	static public String PlatformLoadHistory()
	{
		return UnitedPlatform.getInstance().PlatformLoadHistory();
	}
	//UnitedPlatform
	//注册监听
	static public void registerLuaListener()
	{
		
	}
	//选择自定义头像
	static public void pickerImage(int type)
	{
		UnitedPlatform.getInstance().pickerImage(type);
	}
	//获取自定义头像地址
	static public String getCustomHeadImagePath(String fileName)
	{
		return UnitedPlatform.getInstance().getCustomHeadImagePath(fileName);
	}
	static public void downloadHeadImage(int userID, String fileName)
	{
		UnitedPlatform.getInstance().downloadHeadImage(userID, fileName);
	}
	//游客登录
	static public void guestLogin()
	{
		UnitedPlatform.getInstance().guestLogin();
	}
	//手机注册，获取验证码
	static public void PlatformPhoneRegCheckCode(String phone)
	{
		UnitedPlatform.getInstance().PlatformPhoneRegCheckCode(phone);
	}
	//手机注册
	static public void PlatformLoginPhone(String phone, String authCode, String pwd)
	{
		UnitedPlatform.getInstance().PlatformLoginPhone(phone, authCode, pwd);
	}
	//账号登录
	static public void PlatformLoginAcount(String account, String pwd)
	{
		UnitedPlatform.getInstance().PlatformLoginAcount(account, pwd);
	}
	//自动登录
	static public void PlatformLoginAuto()
	{
		UnitedPlatform.getInstance().PlatformLoginAuto();
	}
	//短信找回密码验证码
	static public void PlatformFindPasswordSmsAuth(String phone)
	{
		UnitedPlatform.getInstance().PlatformFindPasswordSmsAuth(phone);
	}
	//短信找回密码
	static public void PlatformFindPasswordSms(String phone, String code, String pwd)
	{
		UnitedPlatform.getInstance().PlatformFindPasswordSms(phone, code, pwd);
	}
	
	//网页购买
	static public void PlatformAppPurchases(String packageID) 
	{
		UnitedPlatform.getInstance().Pay(packageID);
	}
	//mm短信购买
	static public void PlatformCmccPurchases(String packageID, String productID) 
	{
		UnitedPlatform.getInstance().PayBySms(packageID, productID, Constants.SDK_MOBILE_MM);
	}
	//电信短信购买
	static public void PlatformCtccPurchases(String packageID, String productID, int price) 
	{
		UnitedPlatform.getInstance().PayBySms(packageID, productID, price, Constants.SDK_TELECOM_EGAME);
	}
	//微信支付
	static public void PlatformWechatPurchases(String packageID) 
	{
		UnitedPlatform.getInstance().Pay(packageID, Constants.SDK_WECHAT);
	}
	//支付宝支付
	static public void PlatformAlipayPurchases(String packageID) 
	{
		UnitedPlatform.getInstance().Pay(packageID, Constants.SDK_ALIPAY);
	}
	
	//用户反馈
	static public void PlatformFeedback()
	{
		UnitedPlatform.getInstance().PlatformFeedback();
	}
	//切换服务器
	static public void PlatformSwtichServer(int serverID)
	{
		//UnitedPlatform.getInstance().PlatformSwtichServer(serverID);
	}
	//进入免费筹码
	static public void freeChip(String url)
	{
		UnitedPlatform.getInstance().freeChip(url);
	}

	//QQ
	//tencentOAuth
	static public void tencentOAuth(final int luaCallbackFunction)
	{
		UnitedPlatform.getInstance().PlatformLoginQQ();
	}

	static public boolean isQQInstalled()
	{
		return UnitedPlatform.getInstance().IsQQInstalled();
	}
	static public boolean isWXAppInstalled()
	{
		return UnitedPlatform.getInstance().isWechatInstalled();
	}
	
	//Umeng
	//customer event


	//Umeng
	//customer event
	static public void OnUMengEvent(String eventId, String name)
	{
		UnitedPlatform.getInstance().OnUMengEvent(eventId, name);
	}
	//购买
	static public void OnUMengPay(double money, double gold, int channel)
	{
		UnitedPlatform.getInstance().OnUMengPay(money, gold, channel);
	}
	static public void OnUMengPageStart(String pageName)
	{
		UnitedPlatform.getInstance().OnUMengPageStart(pageName);
	}
	static public void OnUMengPageEnd(String pageName)
	{
		UnitedPlatform.getInstance().OnUMengPageEnd(pageName);
	}
	//add alias
	static public void addUmengPushAlias(String alias, String type)
	{
		UnitedPlatform.getInstance().addAlias(alias, type);
	}
	//remove alias
	static public void removeUmengAlias(String alias, String type)
	{
		UnitedPlatform.getInstance().removeAlias(alias, type);
	}
	
	/***************BEGIN----TOOLS*********************/
	static public String MD5AssetFile(String fileName)
	{
//		if(fileName.startsWith("assets/"))
//			fileName = fileName.substring(7);
//		
		return UnitedPlatform.getInstance().MD5AssetFile(fileName);
	}
	/***************END----TOOLS*********************/
	
	
//	//create vedioView int x ,int y,int width ,int height
//	static void IJKCreateVedioView(int x, int y, int width, int height)
//	{
//		IJKVideoInterface.getInstance().createVedioView(x,y,width,height);
//	}
//	
//	//播放美女主播 index
//	static void IJKPlayWithUrl(String url)
//	{
//		IJKVideoInterface.getInstance().play(url);
//	}
//	//停止视频播放
//	static void IJKStop()
//	{
//		IJKVideoInterface.getInstance().stop();
//	}
//
//	//设置视频是否可见
//	static void IJKSetViewVisible(boolean visible)
//	{
//		IJKVideoInterface.getInstance().setVisible(visible);
//	}
//	//设置视频是否可见
//	static void IJKSeekToZero()
//	{
//		IJKVideoInterface.getInstance().seek();
//	}
	
	//解压缩zip文件
	static void unZipFile()
	{
		
	}

	static void openWebView(String url, String screenOrientation, boolean needLogin)
	{
		UnitedPlatform.getInstance().openWebView(url, screenOrientation, needLogin);
	}
	
	static void PlatformRequestRecommandAppList()
	{
		UnitedPlatform.getInstance().PlatformRequestRecommandAppList();
	}
	static void openAppPkg(String packageName)
	{
		UnitedPlatform.getInstance().openApp(packageName);
	}
	static boolean checkAppPkg(String packageName)
	{
		return UnitedPlatform.getInstance().isAppInstall(packageName);
	}

	//分享
	static void showShare(String title, String desc, String typeStr, String url)
	{
		if(typeStr.isEmpty())
			return;
		
		if(typeStr.equals("1"))
		{
			Log.i("ddz", typeStr+"微信分享");
			UnitedPlatform.getInstance().wechatShare(0,title, desc, url);
		}
		else if(typeStr.equals("2"))	{
			Log.i("ddz", typeStr+"朋友圈分享");
			UnitedPlatform.getInstance().wechatShare(1, title, desc, url);
		}
		else if(typeStr.equals("3")){	
			Log.i("ddz", typeStr+"QQ分享");
			UnitedPlatform.getInstance().qqShare(0, title, desc, url);
		}
		else if(typeStr.equals("4")){	
			Log.i("ddz", typeStr+"QQ空间分享");
			UnitedPlatform.getInstance().qqShare(1, title, desc, url);
		}
		else if(typeStr.equals("5")){	
			Log.i("ddz", typeStr+"微博分享");
			UnitedPlatform.getInstance().sinaWeiboShare(title, desc, url);
		}
		else if(typeStr.equals("6")){	
			Log.i("ddz", typeStr+"短信分享");
			UnitedPlatform.getInstance().smsShare(title, desc, url);
		}
					
	}
}

