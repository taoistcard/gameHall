/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.zxsdk._98Platform;

import java.io.File;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import com.zxsdk._98Platform._98Platform.PayDataListener;
import com.raccoon.cc.doudizhunew.R;
//import com.zxsdk.TianTian.TTPlatform;
import com.umeng.analytics.MobclickAgent;


import cn._98game.platform.*;
import cn._98game.platform.listener.CommandListener;
import cn._98game.platform.listener.CustomAvatarListener;
import cn._98game.platform.listener.DataConfigureListener;
import cn._98game.platform.listener.LoginProcessListener;
import cn._98game.platform.listener.PayProcessListener;
import cn._98game.platform.util.LogUtil;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.graphics.drawable.Drawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.provider.Settings;
import android.text.TextUtils;
import android.text.format.Formatter;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;


public class _98Platform implements LoginProcessListener,CustomAvatarListener,
DataConfigureListener,
PayProcessListener, CommandListener{
	private String mAppId;
	private String mAppKey;
	private String mAppServer;
	private String mAppName;
	private String mAppChannel;
	private String mAppChannelName;
	public String getChannel(){return mAppChannel;}
	public String getChannelName(){return mAppChannelName;}
	
	private Platform mPlatform;
	private Activity mCtx;
	private boolean isServerSideLogin = false;
	private PayDataListener payDataListener;

//	private TTPlatform mTTCPlatform;
	private volatile static _98Platform instance;
	private _98Platform(){
		
	}
	static public _98Platform getInstance()
	{
		if(instance==null)
		{
			synchronized(_98Platform.class)
			{
				if(instance==null)
				{
					instance = new _98Platform();
				}
			}
		}
		return instance;
	}
	
	public void init(Activity ctx) {
		mCtx = ctx;
	    
		mAppId = mCtx.getString(R.string.AppId);
		mAppKey = mCtx.getString(R.string.AppKey);
		mAppServer = mCtx.getString(R.string.AppServer);
		
		mAppName = mCtx.getString(R.string.app_name);
		mAppChannel = mCtx.getString(R.string.channel);
		mAppChannelName = mCtx.getString(R.string.channel_name);
		
		mPlatform = Platform.getInstance();
		mPlatform.setGuestLogin(true);
		mPlatform.registerLoginProcessListener(this);
		mPlatform.registerCommandListener(this);
		mPlatform.setGuestLogin(true);
		mPlatform.initPlatform(mCtx, mAppId, mAppKey, mAppServer);
		mPlatform.registerDataConfigureListener(this);
		this.requestOnlineConfig();

		//初始化TTC
//		mTTCPlatform = TTPlatform.getInstance();
	}
	
    public void uploadAvatarImage(String filePath) {
    	mPlatform.uploadAvatarImage(filePath, this);
    }
	//qq登录
	public boolean LoginQQ(final String _token, final String _openid)
	{
		HashMap<String, String> params = new HashMap<String, String>(){
			{
				put("token", _token);
				put("openid", _openid);
			}
		};
		mPlatform.thirdSdkLogin(Constants.SDK_QQ, params);
		return true;
	}
	//egam登录
	public boolean LoginEGame(final String _token, final String _openid)
	{
		HashMap<String, String> params = new HashMap<String, String>(){
			{
				put("token", _token);
				put("openid", _openid);
			}
		};
		mPlatform.thirdSdkLogin(Constants.SDK_TELECOM_EGAME, params);
		return true;
	}

	   /**
     * 游客登录
     */
    public boolean guestLogin() {
        return mPlatform.guestLogin();
    }

    public void PlatformPhoneRegCheckCode(String phone)
    {
    	HashMap<String, String> param = new HashMap<String, String>();
		param.put(Constants.PARAM_PHONE, phone);
		mPlatform.submitCommand(Constants.CMD_PHONE_REG_SMS, param);
    }
    
	public void PlatformLoginPhone(String phone, String authCode, String password)
	{
		mPlatform.phoneReg(phone, authCode, password);
	}
	
	public void PlatformLoginAccount(String account, String pwd)
	{
		mPlatform.loginWithAccount(account, pwd);
	}
    /**
     * 自动登录模式，根据上次登录成功的账号自动登录，可支持游客登录
     * 
     * @param guestLogin true-支持游客登录，false-不支持游客登录
     */
    public boolean autoLogin(boolean guestLogin) {
    	return mPlatform.autoLogin(guestLogin);
    }
    
    public void PlatformFindPwdSmsAuth(String phone)
    {
    	HashMap<String, String> param = new HashMap<String, String>();
		param.put(Constants.PARAM_PHONE, phone);
		mPlatform.submitCommand(Constants.CMD_FIND_PWD_SMS, param);
    }
    
    public void PlatformFindPwdSms(String phone, String code, String pwd)
    {
    	HashMap<String, String> param = new HashMap<String, String>();
		param.put(Constants.PARAM_PHONE, phone);
		param.put(Constants.PARAM_CODE, code);
		param.put(Constants.PARAM_PASSWORD, pwd);
		mPlatform.submitCommand(Constants.CMD_FIND_PWD, param);
    }
    //网页支付
    public void Pay(String packageID)
    {
    	mPlatform.webMobilePayWithPackageID(packageID, mCtx, this);
    }
    //短信支付
    public void PayBySms(HashMap<String, String> hashMap, PayDataListener listener)
    {
    	this.setPayDataListener(listener);
    	String channel = hashMap.get(Constants.PARAM_CHANNELID);
    	Log.i("PayBySms", "channel = "+channel);
    	mPlatform.getPayOrderId(Integer.parseInt(channel), hashMap);
    }
    //第三方支付
    public void Pay(HashMap<String, String> hashMap, PayDataListener listener)
    {
    	this.setPayDataListener(listener);
    	String channel = hashMap.get(Constants.PARAM_CHANNELID);
    	Log.i("Pay", "channel = "+channel);
    	mPlatform.getPayOrderId(Integer.parseInt(channel), hashMap);
    }
    
    public void feedback()
    {
    	mPlatform.feedback(mCtx);
    }
    
    public void switchServer(int serverID)
    {
    	mPlatform.switchServer(serverID);
    }
    
    public void freeChip(String url)
    {
    	String sessionid = mPlatform.getSessionID();
    	url = String.format("%s?sessionid=%s", url, sessionid);
    	Log.i("cocos", "url =" + url);
    	
        if (checkLoginStatus()) {
            Intent intent = new Intent(mCtx, WebViewActivity.class);
            intent.putExtra(WebViewActivity.TAG_URL, url);
            mCtx.startActivity(intent);
        }
    }
    public void openWebView(String url, String screenOrientation)
    {
    	String sessionid = mPlatform.getSessionID();
    	url = String.format("%s?sessionid=%s", url, sessionid);
    	Log.i("cocos", "url =" + url);
    	
        if (checkLoginStatus()) {
	        Intent intent = new Intent(mCtx, WebViewActivity.class);
	        intent.putExtra(WebViewActivity.TAG_URL, url);
	        intent.putExtra(WebViewActivity.TAG_screenOrientation, screenOrientation);
	        mCtx.startActivity(intent);
        }
    }
    public void openPureWeb(String url, String screenOrientation)
    {
    	Log.i("cocos", "url =" + url);    	
        Intent intent = new Intent(mCtx, WebViewActivity.class);
        intent.putExtra(WebViewActivity.TAG_URL, url);
        if(!screenOrientation.isEmpty())
        	intent.putExtra(WebViewActivity.TAG_screenOrientation, screenOrientation);
        mCtx.startActivity(intent);
    }
    
    public boolean checkLoginStatus()
    {
    	return mPlatform.checkLoginStatus();
    	//return true;
    	
    }
    
    public void onRequestServerListResult(int code, String data)
    {
    	
    }
	
	// --------------------DataConfigureListener--------------------
	//Override
	public void onDataConfigureResult(int code, int dataType, String data) {
		switch(code){
		case Constants.SUCCESS:
		{
			switch(dataType)
			{
			case Constants.DATA_ONLINE_CONFIG:
				if(mPlatform.getOnlineConfig().has("review"))
				{
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
							"onUnitedPlatFormDataConfigResult", "review" + "," + mPlatform.getOnlineConfig().get("review") + ",");
				}
				if(mPlatform.getOnlineConfig().has("charge"))
				{
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
							"onUnitedPlatFormDataConfigResult", "charge" + "," + mPlatform.getOnlineConfig().get("charge") + ",");
				}
				break;
			case Constants.DATA_VERSION_UPDATE:
				
				break;
			case Constants.DATA_PAY_ORDERID:
				if( this.payDataListener != null)
					this.payDataListener.onPayOrderResult(code, data);
				break;
			case Constants.DATA_APP_LIST:
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
						"onRequestRecommandAppListSuccess", data);
				break;
			}
			break;
		}
		case Constants.FAILURE:
		{
			break;
		}
		default:
			break;
		}
	}
	
	//Override
	public void onPlatformLoginResult(int code, int type, String error) {
		
		UserInfo userInfo;
		switch (code) {
		// 登陆成功
		case Constants.SUCCESS:

			// 登陆成功以后的操作流程
			userInfo = this.mPlatform.getUserInfo();
			int userId = userInfo.getUserID();// 用户ID
			String userId1 = userInfo.getStringUserID();// 用户ID
			String username = userInfo.getUserName();// 账号
			String NickName = userInfo.getNickName(); // 昵称
			int ServerID = userInfo.getServerID();// 服务器ID
			String password = userInfo.getPassword();// 密码，加密
			Log.i("onPlatformLoginResult", "userId:" + userId + "userId1:"
					+ userId1 + "username:" + username + "NickName:" + NickName
					+ "ServerID:" + ServerID + "password:" + password +", "+  this.mPlatform.getSessionID());
			//chooseserver = ServerID;
		
			Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
							"onUnitedPlatFormLoginSuccess", userId + ","
									+ NickName +"," + this.mPlatform.getSessionID());
			//isLogin = true;
//			mTTCPlatform.TTCLogin(this.mPlatform.getSessionID());
			
			break;
		// 失败
		case Constants.FAILURE:
			Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
					"onUnitedPlatFormLoginFailed", error);
//			Toast.makeText(mCtx, error, Toast.LENGTH_LONG).show();
			//if (this.listener != null) {
			//	this.listener.onLoginFinish(false);
			//}
			//isLogin = false;
			break;
		default:
			break;
		}
		// onLoginResult(code,error,type);
	}

	/**
	 * 友盟在线参数回调接口，注意此接口只在在线参数有变化的时候才会回调
	 */
	//Override
	public void onDataReceived(JSONObject data) {
		/*
		
		String channel = this.getUmengChannel();
		int versionCode = this.platform.getAppVersionCode();
		String params = MobclickAgent.getConfigParams(
				UnitedPlatFormHelper.activity, channel);

		int currentVersion = Platform.getInstance().getAppVersionCode();

		try {
			PackageInfo pi = UnitedPlatFormHelper.activity.getPackageManager()
					.getPackageInfo(
							UnitedPlatFormHelper.activity.getPackageName(), 0);
			Log.i("onDataReceived1", pi.versionCode + "");


		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		*/
	}
	
	//Override
	public void onPaymentResult(final int code, String error) {
		Log.i("onPaymentResult", code + "");
		mCtx.runOnUiThread(new Runnable() {
			//Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
						"onUnitedPlatFormAppPurchaseResult", code + ",");
			}
		});
	}

	//Override
	public void onCommandResult(final int code, int cmd, String error) {
		Log.i("onCommandResult", code + "");

		switch(code)
		{
		case Constants.SUCCESS:
		{		
			String strCmd = "";
			if (cmd == Constants.CMD_FIND_PWD_SMS || cmd == Constants.CMD_PHONE_REG_SMS)
				strCmd = "手机验证码获取成功，请注意查收短信！";
			if (cmd == Constants.CMD_FIND_PWD)
				strCmd = "账号密码已经通过手机短信密码验证重置，请重新登录！";
			
			Toast.makeText(mCtx, strCmd, Toast.LENGTH_LONG).show();

			Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
					"onUnitedPlatFormAppCommandResult", code + "," + cmd + ",");
			break;
		}
		case Constants.FAILURE:
		{
			if(!error.isEmpty()){
				Toast.makeText(mCtx, error, Toast.LENGTH_LONG).show();
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
						"onUnitedPlatFormAppCommandResult", code + "," + "-1" + ",");
			}
		}
		}
	}

	/**********************************begin 自定义头像功能接口***************************************/
	/************************************打开相机********************************************/
	   /**
     * 获取玩家的自定义头像
     */
    public void downloadAvatarImageWithUserID(int userID, String fileName) {
    	Log.i("ttc", "开始下载文件:"+fileName + ", userID:" + userID);   	
    	mPlatform.dowloadAvatarImageWithUserID(userID, fileName, this);
    }
    /**
     * 获取玩家的自定义头像
     */
    public String getCustomHeadImagePath(String fileName) {
    	return mPlatform.getAvatarImagePathWithName(fileName);
    }
	public void requestOnlineConfig()
	{
		mPlatform.syncDataConfig(Constants.DATA_ONLINE_CONFIG);
	}
	public void requestRecommandApplist()
	{
		mPlatform.syncDataConfig(Constants.DATA_APP_LIST);
	}
	public void gotoImagePickerActivity(int type)
	{
		//REQUEST_CODE_GETIMAGE_BYSDCARD = 0;// 从sd卡得到图像的请求码
		//REQUEST_CODE_GETIMAGE_BYCAMERA = 1;// 从相机得到图像的请求码

        Intent in = new Intent(mCtx, ImagePickerActivity.class);
        Bundle bundle=new Bundle();  
        bundle.putInt("type", type);
        in.putExtras(bundle);  
        Log.i("ttc", "gotoImagePickerActivity----" + type);
        mCtx.startActivity(in);
		
	}
	
	   /**
	  * 自定义头像上传结果通知
	  */
	 public void onAvatarUploadResult(final int code, final Map<String, String> map)
	 {
	 	Log.i("ttc","onAvatarUploadResult = " + map.get("md5"));
	 	Cocos2dxHelper.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					String result = ""; 
					result += code;
					if (map.containsKey("md5"))
					{
						result += ",";
						result += map.get("md5");
					}
					if(map.containsKey("userID"))
					{
						result += ",";
						result += map.get("userID");
					}
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
						"onUnitedPlatFormAppAvatarUploadResult", result);
				}
			});
	 }
	
	 /**
	  * 自定义头像下载结果通知
	  */
		public void onAvatarDownloadResult(final int code, final int userID, final Map<String, String> map)
		{
	 	Log.i("ttc","onAvatarDownloadResult = " + map.get("code") + ", userID = " + map.get("userID") + "fileName =" + map.get("md5"));
	 	Cocos2dxHelper.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					String result = ""; 
					result += code;
					result += ",";
					result += userID;
					if (map.containsKey("md5"))
					{
						result += ",";
						result += map.get("md5");
					}
					Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString(
						"onUnitedPlatFormAppAvatarDownloadResult", result);
				}
			});
	 }
	/**********************************end 自定义头像功能接口***************************************/
		
	public void setPayDataListener(PayDataListener listener)
	{
		this.payDataListener = listener;
	}
	
	public void removePayDataListener(PayDataListener listener)
	{
		this.payDataListener = null;
	}
	//////////////////interface////////////////////////////////////////
	public static interface PayDataListener {
		/**
		 * 获取订单号回调
		 */
		public void onPayOrderResult(int code, String data);

	}
}
