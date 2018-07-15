package com.zxsdk.UnitedPlatform;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.security.MessageDigest;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import cn.game100.HappyHall.GameActivity;
import cn.game100.HappyHall.R;
import cn.game100.HappyHall.wxapi.WXEntryActivity;

import org.json.JSONObject;

import cn._98game.platform.util.DeviceUtil;

import com.zxsdk.Tencent.QQPlatform;
import com.zxsdk.Tencent.WechatPlatform;
//import com.zxsdk.TianTian.TTPlatform;
import com.zxsdk.UMeng.UMengPlatform;
import com.zxsdk._98Platform._98Platform;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;
import com.umeng.analytics.game.UMGameAgent;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

public class UnitedPlatform {

	private volatile static UnitedPlatform instance;
	private Activity mCtx;
	private QQPlatform mQQPlatform;
	private WechatPlatform mWechatPlatform;
	private _98Platform m98Platform;
	private UMengPlatform mUMPlatform;
//	private TTPlatform mTTCPlatform;
	
	private UnitedPlatform(){}
	static public UnitedPlatform getInstance()
	{
		if(instance==null)
		{
			synchronized(UnitedPlatform.class)
			{
				if(instance==null)
				{
					instance = new UnitedPlatform();
				}
			}
		}
		return instance;
	}

	public void init(Activity context)
	{
		mCtx = context;
		//腾讯sdk
		mQQPlatform = QQPlatform.getInstance();
		mQQPlatform.init(context);
		
		mWechatPlatform = WechatPlatform.getInstance();
		mWechatPlatform.init(context);
		
		//98平台
		m98Platform = _98Platform.getInstance();
		m98Platform.init(context);

		//友盟sdk
		mUMPlatform = UMengPlatform.getInstance();
		mUMPlatform.init(context);

		//TTC
//		mTTCPlatform = TTPlatform.getInstance();
//		mTTCPlatform.init(context);
		
	}
	
	public Context getContext()
	{
		return mCtx;
	}
	
	// 注册监听
	public void registerLuaListener()
	{
		
	}
	
	//选择自定义头像图片
	public void pickerImage(int type)
	{
		m98Platform.gotoImagePickerActivity(type);
	}
	//获取头像路径
	public String getCustomHeadImagePath(String fileName)
	{
		return m98Platform.getCustomHeadImagePath(fileName);
	}
	public void downloadHeadImage(int userID, String fileName)
	{
		m98Platform.downloadAvatarImageWithUserID(userID, fileName);
	}
	// 游客登录
	public boolean guestLogin()
	{
		m98Platform.guestLogin();
		return true;
	}
	
	public String getDeviceID()
	{
		return DeviceUtil.getUUID(mCtx);
	}
	//获取渠道信息
	public String getChannelInfo()
	{
		return m98Platform.getInstance().getChannel()+","+m98Platform.getInstance().getChannelName();
	}
	//电信爱游戏登录
	public void PlatformLoginEGame()
	{
//		((DdzActivity)mCtx).initLogin();
	}
	
	public String PlatformLoadHistory()
	{
		UnitedLoadHistory.GetInstance().init(mCtx);
		return UnitedLoadHistory.GetInstance().GetUserinfo();
	}
	// 手机注册，获取验证码
	public void PlatformPhoneRegCheckCode(String phone)
	{
		m98Platform.PlatformPhoneRegCheckCode(phone);
	}
	
	// 手机注册
	public void PlatformLoginPhone(String phone, String authCode, String password)
	{
		m98Platform.PlatformLoginPhone(phone, authCode, password);
	}
	// 账号登录
	public void PlatformLoginAcount(String account, String password)
	{
		m98Platform.PlatformLoginAccount(account, password);
	}
	// 自动登录
	public void PlatformLoginAuto()
	{
		boolean isSurportGuest = true;
		m98Platform.autoLogin(isSurportGuest);
	}
	//qq登陆
	public void PlatformLoginQQ()
	{
		mQQPlatform.QQLogin();
	}
	public boolean IsQQInstalled()
	{
		return mQQPlatform.IsQQInstalled();
	}
	public boolean isWechatInstalled()
	{
		return WechatPlatform.getInstance().getWXAPI().isWXAppInstalled();
	}
	// 短信找回密码验证码
	public void PlatformFindPasswordSmsAuth(String phone)
	{
		m98Platform.PlatformFindPwdSmsAuth(phone);
	}
	// 短信找回密码
	public void PlatformFindPasswordSms(String phone, String authCode, String newpassword)
	{
		m98Platform.PlatformFindPwdSms(phone, authCode, newpassword);
	}
	//请求在线配置
	public void PlatformRequestOnLineSetting()
	{
		m98Platform.requestRecommandApplist();
	}

	//mm充值
	public void PayBySms(String packageID, String payCode, int sdkType)
	{
//		((DdzActivity)mCtx).order(packageID, payCode, sdkType);
	}
	//mm充值
	public void PayBySms(String packageID, String payCode, int price, int sdkType)
	{
		((GameActivity)mCtx).order1(packageID, payCode, price, sdkType);
	}
	//第三方充值
	public void Pay(String packageID, int sdkType)
	{
		((GameActivity)mCtx).order2(packageID, sdkType);
	}
	// 网页购买
	public void Pay(String packageID)
	{
		m98Platform.Pay(packageID);
	}
	// 用户反馈
	public void PlatformFeedback()
	{
		m98Platform.feedback();
	}
	// 切换服务器
	public void PlatformSwtichServer(int serverID)
	{
		Log.i("DDZ","serverID = "+serverID);
		m98Platform.switchServer(serverID);
	}
	// 进入免费筹码
	public void freeChip(String url)
	{
		m98Platform.freeChip(url);
	}
	// 进入免费筹码
	public void openWebView(String url, String screenOrientation, boolean needLogin)
	{
		if (needLogin)
			m98Platform.openWebView(url, screenOrientation);
		else
			m98Platform.openPureWeb(url, screenOrientation);
		
	}
	//友盟接口
	public void addAlias(String alias, String type)
	{	
		UMengPlatform.getInstance().addAlias(alias,type);
	}
	
	public void removeAlias(String alias, String type)
	{	
		UMengPlatform.getInstance().removeAlias(alias,type);
	}
	
	public void OnUMengEvent(String eventId, String name)
	{
		UMengPlatform.getInstance().OnEvent(eventId, name);
	}
	
	public void OnUMengPageStart(String pageName)
	{
		UMengPlatform.getInstance().OnPageStart(pageName);
	}
	public void OnUMengPageEnd(String pageName)
	{
		UMengPlatform.getInstance().OnPageEnd(pageName);
	}
	public void OnUMengPay(double money, double gold, int channel)
	{
		UMengPlatform.getInstance().OnPay(money, gold, channel);
	}
	
	public void onResume(Context ctx) {
		UMengPlatform.getInstance().onResume(ctx);
	}
	
	public void onPause(Context ctx) {
		UMengPlatform.getInstance().onPause(ctx);
	}
	
	// tools
	public String MD5AssetFile(String fileName) {
		try {
			InputStream in = mCtx.getAssets().open(fileName);

			MessageDigest digest = null;
			byte buffer[] = new byte[1024];
			int len;
			try {
				digest = MessageDigest.getInstance("MD5");
				while ((len = in.read(buffer, 0, 1024)) != -1) {
					digest.update(buffer, 0, len);
				}
				in.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			BigInteger bigInt = new BigInteger(1, digest.digest());
			
			Log.d("DDZ", fileName + "md5 = " + bigInt.toString(16));
			
			return bigInt.toString(16);

		} catch (IOException e) {
			e.printStackTrace();
		}

		Log.d("DDZ", fileName + "md5 = \"\"");
		return "";
	}
	
	public void openApp(String packageName)
	{
		Intent LaunchIntent = mCtx.getPackageManager().getLaunchIntentForPackage(packageName);  
		mCtx.startActivity(LaunchIntent);   
	}
	public boolean isAppInstall(String packageName)
	{
		PackageManager pm = mCtx.getPackageManager();  
        boolean installed = false;  
        try {  
            pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES);  
            installed = true;  
        } catch (PackageManager.NameNotFoundException e) {  
            installed = false;  
        }  
        return installed;  
	}
	public void PlatformRequestRecommandAppList()
	{
		m98Platform.requestRecommandApplist();
	}
	
	public void share()
	{
		 Intent intent=new Intent(Intent.ACTION_SEND); 
         intent.setType("text/plain");
         intent.putExtra(Intent.EXTRA_SUBJECT,"分享");   
         intent.putExtra(Intent.EXTRA_TEXT, "我正在浏览这个,觉得真不错,推荐给你哦~ 地址:"+"http://www.google.com.hk/");
         intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);   
         mCtx.startActivity(Intent.createChooser(intent, "share"));
	}
	
	public void wechatShare(int flag, String title, String text, String url)
	{
		WechatPlatform.getInstance().wechatShare(flag, title, text, url);
	}
	public void qqShare(int flag, String title, String desc, String url)
	{
		if(flag == 0)
			mQQPlatform.shareToQQ(title, desc, url);
		else
			mQQPlatform.shareToQQzone(title, desc, url);
	}
	
	public void sinaWeiboShare(String title, String desc, String url)
	{
		Toast.makeText(mCtx, "暂不支持微博分享!",
				Toast.LENGTH_SHORT).show();
	}
	
	public void smsShare(String title, String desc, String url)
	{
		  //发短信   

	    String smsBody = desc;
		Uri smsToUri = Uri.parse( "smsto:" );  
		Intent sendIntent =  new  Intent(Intent.ACTION_VIEW, smsToUri);  
		//sendIntent.putExtra("address", "123456"); // 电话号码，这行去掉的话，默认就没有电话   
		//短信内容
		sendIntent.putExtra( "sms_body", smsBody);  
		sendIntent.setType( "vnd.android-dir/mms-sms" );  
		mCtx.startActivityForResult(sendIntent, 1002 );  
	}
	public String getShareImageUrl()
	{
//		http://www.98pk.net/static/platform/1026/150.jpg 牛牛
//		http://www.98pk.net/static/platform/1005/150.jpg 斗地主
		return "http://www.98pk.net/static/platform/" + mCtx.getString(R.string.AppId) + "/150.jpg";
	}
}
