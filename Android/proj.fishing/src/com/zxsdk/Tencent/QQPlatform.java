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
package com.zxsdk.Tencent;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.HashMap;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.json.JSONException;
import org.json.JSONObject;

import com.zxsdk._98Platform._98Platform;
import cn.game100.HappyHall.R;

import com.zxsdk.UnitedPlatform.*;
import com.tencent.connect.share.QQShare;
import com.tencent.connect.share.QzoneShare;
import com.tencent.tauth.IRequestListener;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.SystemClock;
import android.provider.Settings;
import android.text.format.Formatter;
import android.util.Log;
import android.view.WindowManager;
import android.widget.Toast;


public class QQPlatform {
	
	private String SCOPE = "get_user_info,get_simple_userinfo";
	private String QQAppID  = "1104678578";
	private String QQAPPKey ="fg89ghDDtD5nE4L7";
	private Tencent mTencent;
	private Activity mCtx;
	private boolean isServerSideLogin = false;
	
	private volatile static QQPlatform instance;
	private QQPlatform(){}
	static public QQPlatform getInstance()
	{
		if(instance==null)
		{
			synchronized(QQPlatform.class)
			{
				if(instance==null)
				{
					instance = new QQPlatform();
				}
			}
		}
		return instance;
	}
	
	public void init(Activity ctx) {
		mCtx = ctx;
        
        SCOPE = mCtx.getString(R.string.QQ_Scope);
        QQAppID  = mCtx.getString(R.string.QQ_AppId);
        QQAPPKey = mCtx.getString(R.string.QQ_AppKey);
        Log.i("tencent", "QQAppID = " + QQAppID + ", mCtx = " + mCtx);
        mTencent = Tencent.createInstance(QQAppID, mCtx);

	}

	public boolean QQLogin()
	{
		
		IUiListener loginListener = new BaseUiListener() {
 		@Override
 		public void onComplete(Object arg0){
 			Log.i("cocos", "qqlogin completed!");
 			thirdLogin();
 			}
	 	};
	 	
	 	Log.d("tencent", "begin call QQLogin");
 		Log.d("tencent", "qq platform -----  QQLogin, mTencent = " + mTencent);

	 	if (!mTencent.isSessionValid()) {
	 		Log.d("SDKQQAgentPref", "qq platform -----  QQLogin, mTencent = " + mTencent.toString());
	 		
			mTencent.login((Activity)mCtx, SCOPE, loginListener);
            isServerSideLogin = false;
			Log.d("SDKQQAgentPref", "FirstLaunch_SDK:" + SystemClock.elapsedRealtime());
		} 
	 	else //已经登陆成功，跳转统一平台登陆
	 	{
	 		Log.d("tencent", "begin call 98 platform login by thirdSdk");
            thirdLogin();
		}
		return true;
	}
	
	public void thirdLogin()
	{
		_98Platform.getInstance().LoginQQ(mTencent.getAccessToken(), mTencent.getOpenId());
	}
	
	public boolean QQLoginOut()
	{
		mTencent.logout((Activity)mCtx);
		return true;
	}
	
	public boolean IsQQInstalled()
	{
		try{
			mCtx.getPackageManager().getApplicationInfo("com.tencent.mobileqq", PackageManager.GET_META_DATA);
			return true;
		}
		catch(Exception e) {
			return false;
		}
	}
	
	private class BaseUiListener implements IUiListener {
		@Override
		public void onError(UiError e) {
			Log.i("onError:", "code:" + e.errorCode + ", msg:" + e.errorMessage + ", detail:" + e.errorDetail);
		}
		@Override
		public void onCancel() {
			Log.i("onCancel", "");
		}
		@Override
		public void onComplete(Object arg0) {
			// TODO Auto-generated method stub
			
		}
	}
	
	public void shareToQQ(String title, String desc, String url) { 
	    final Bundle params = new Bundle();
	    params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, QQShare.SHARE_TO_QQ_TYPE_DEFAULT);
	    params.putString(QQShare.SHARE_TO_QQ_TITLE, title);
	    params.putString(QQShare.SHARE_TO_QQ_SUMMARY,  desc);
	    params.putString(QQShare.SHARE_TO_QQ_TARGET_URL,  url);
	    params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, UnitedPlatform.getInstance().getShareImageUrl());
	    params.putString(QQShare.SHARE_TO_QQ_APP_NAME, mCtx.getString(R.string.app_name));
	    params.putInt(QQShare.SHARE_TO_QQ_EXT_INT,  QQShare.SHARE_TO_QQ_FLAG_QZONE_ITEM_HIDE);		
	    mTencent.shareToQQ(mCtx, params, new BaseUiListener());
	}
	
	public void shareToQQzone(String title, String desc, String url){
		
		final Bundle params = new Bundle();
		params.putInt(QzoneShare.SHARE_TO_QZONE_KEY_TYPE, QzoneShare.SHARE_TO_QZONE_TYPE_IMAGE_TEXT );
	    params.putString(QzoneShare.SHARE_TO_QQ_TITLE, title);//必填
	    params.putString(QzoneShare.SHARE_TO_QQ_SUMMARY, desc);//选填
	    params.putString(QzoneShare.SHARE_TO_QQ_TARGET_URL, url);//必填
	    
	    // 支持传多个imageUrl，在这里我测试只放一张图片，最多可以放9张
		ArrayList imageUrls = new ArrayList();
		imageUrls.add(UnitedPlatform.getInstance().getShareImageUrl());
		//      for (int i = 0; i
		//          LinearLayout addItem = (LinearLayout)mImageContainerLayout.getChildAt(i);
		//          EditText editText = (EditText)addItem.getChildAt(1);
		//         imageUrls.add(editText.getText().toString());
		//      }
		//String imageUrl = "XXX";
		//params.putString(Tencent.SHARE_TO_QQ_IMAGE_URL,imageUrl);
		params.putStringArrayList(QzoneShare.SHARE_TO_QQ_IMAGE_URL, imageUrls);

	    mTencent.shareToQzone(mCtx, params, new BaseUiListener());
	}
}
