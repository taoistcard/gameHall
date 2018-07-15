package com.zxsdk.UMeng;

import java.util.HashMap;

//import android.content.ClipboardManager;
import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import cn.game100.HappyHall.R;

import com.umeng.analytics.game.UMGameAgent;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.PushAgent;
import com.umeng.message.UmengRegistrar;

public class UMengPlatform {
	private Context mCtx;
	private PushAgent mPushAgent; 


	private volatile static UMengPlatform instance;
	private UMengPlatform(){}
	static public UMengPlatform getInstance()
	{
		if(instance==null)
		{
			synchronized(UMengPlatform.class)
			{
				if(instance==null)
				{
					instance = new UMengPlatform();
				}
			}
		}
		return instance;
	}
	
	private void updateStatus() {

//		String deviceToken = mPushAgent.getRegistrationId();
//		if (!TextUtils.isEmpty(deviceToken))
//		{
//			Toast.makeText(mCtx, deviceToken, Toast.LENGTH_SHORT).show();
//		}
	}
	
	public void init(Context ctx)
	{
		mCtx = ctx;

		//友盟统计
//	    UMGameAgent.setDebugMode(true);//设置输出运行时日志
	    UMGameAgent.init(mCtx);
	    
	    //开启推送服务
		mPushAgent = PushAgent.getInstance(mCtx);
		mPushAgent.onAppStart();
		mPushAgent.enable();
		
	    //获取设备的Device Token（可选）
	    //如果在测试或其他使用场景中，需要获取设备的Device Token，可以使用下面的方法。
		String device_token = UmengRegistrar.getRegistrationId(mCtx);
		if(true ==  UmengRegistrar.isRegisteredToUmeng(mCtx))
			Log.i("umeng", "umeng log : 注册成功！");
		else
			Log.i("umeng", "umeng log : 注册失败！");
//		
//	    Log.i("umeng", "umeng log : device_token = " + device_token);
	}
	
	//页面切换
	public void OnPageStart(String pageName)
	{
		UMGameAgent.onPageStart(pageName);
	}
	//页面切换	
	public void OnPageEnd(String pageName)
	{
		UMGameAgent.onPageEnd(pageName);
	}
	public void OnPay(double money, double gold, int channel)
	{
		/*
		1	Google Play
		2	支付宝
		3	网银
		4	财付通
		5	移动通信
		6	联通通信
		7	电信通信
		8	paypal
		*/
		UMGameAgent.pay(money, gold, channel);
	}
	public void OnEvent(String eventId, String name)
	{
		Log.d("cocos", "友盟消息：id" + eventId + ", name = " + name);
		UMGameAgent.onEvent(eventId, name);
		
	}
	
	public void onResume(Context ctx) {
		UMGameAgent.onResume(ctx);
	}
	
	public void onPause(Context ctx) {
		UMGameAgent.onPause(ctx);
	}
	
	public void addAlias(String alias, String type)
	{	
		try {
			mPushAgent.addAlias(alias, type);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void removeAlias(String alias, String type)
	{	
		try {
			mPushAgent.addAlias(alias, type);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
