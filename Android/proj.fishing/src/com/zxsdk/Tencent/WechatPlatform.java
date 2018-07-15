package com.zxsdk.Tencent;

import org.json.JSONObject;

import android.app.Activity;
import android.util.Log;

import cn.game100.HappyHall.R;
import com.tencent.mm.sdk.modelmsg.SendMessageToWX;
import com.tencent.mm.sdk.modelmsg.WXMediaMessage;
import com.tencent.mm.sdk.modelmsg.WXTextObject;
import com.tencent.mm.sdk.modelmsg.WXWebpageObject;
import com.tencent.mm.sdk.modelpay.PayReq;
import com.tencent.mm.sdk.openapi.IWXAPI;
import com.tencent.mm.sdk.openapi.WXAPIFactory;
import com.tencent.tauth.Tencent;

public class WechatPlatform {

	private Activity mCtx;
	private PayReq mWechatReq;
	private IWXAPI mWechatApi;
	public IWXAPI getWXAPI(){return mWechatApi;}
	
	private volatile static WechatPlatform instance;
	private WechatPlatform(){}
	static public WechatPlatform getInstance()
	{
		if(instance==null)
		{
			synchronized(QQPlatform.class)
			{
				if(instance==null)
				{
					instance = new WechatPlatform();
				}
			}
		}
		return instance;
	}
	public void init(Activity ctx) {
		mCtx = ctx;
        
		//微信支付
		mWechatReq = new PayReq();
		mWechatApi = WXAPIFactory.createWXAPI(mCtx, null);
		mWechatApi.registerApp(mCtx.getString(R.string.Wechat_AppId));

	}
	public void sendReq(JSONObject params)
	{
		/*{
	    "Params": {
	        "sign": "5AD7A3544BF918B5E062E206E6403F8E",
	        "timestamp": 1446711898,
	        "package": "Sign=WXPay",
	        "noncestr": "026C87BC8DFD256A87316F1747A30FC2",
	        "partnerid": "1280110901",
	        "appid": "wx4fe4f4dc50342a2c",
	        "prepayid": "wx20151105162458955b697c6c0511056127"
	    },
	    "ParamsType": "WinXinZhiFu"
		}*/
		try{
			mWechatReq.appId = params.getString("appid");
			mWechatReq.partnerId = params.getString("partnerid");
			mWechatReq.prepayId= params.getString("prepayid");
			mWechatReq.packageValue = params.getString("package");
			mWechatReq.nonceStr= params.getString("noncestr");
			mWechatReq.timeStamp= params.getString("timestamp");
			mWechatReq.sign= params.getString("sign");
			boolean ret = mWechatApi.sendReq(mWechatReq);
			Log.d("DDZ", "mWechatApi.sendReq " + ret);
		}
		catch(Exception e)
		{
			Log.d("DDZ", "订单解析失败！");
		}
	}
	private String buildTransaction(final String type) {
		return (type == null) ? String.valueOf(System.currentTimeMillis()) : type + System.currentTimeMillis();
	}
	public void wechatShare(int flag, String title, String text, String url)
	{
		WXWebpageObject webpage = new WXWebpageObject();
		webpage.webpageUrl = url;
		WXMediaMessage msg = new WXMediaMessage(webpage);
		msg.title = title;
		msg.description = text;
		
		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("webpage");
		req.message = msg;
		req.scene = flag==0? SendMessageToWX.Req.WXSceneTimeline : SendMessageToWX.Req.WXSceneSession;
		
	    if(req.checkArgs())
	    	this.mWechatApi.sendReq(req);
	    else
	    	Log.i("DDZ", "微信参数校验失败！");
	
	}
	public void wechatShareText(int flag, String text)
	{
		WXTextObject textObj = new WXTextObject();
		textObj.text = text;

		WXMediaMessage msg = new WXMediaMessage();
		msg.mediaObject = textObj;

		msg.title = mCtx.getString(R.string.app_name);
		msg.description = text;

		SendMessageToWX.Req req = new SendMessageToWX.Req();
		req.transaction = buildTransaction("text"); 
		req.message = msg;
	    req.scene = flag==0?SendMessageToWX.Req.WXSceneSession:SendMessageToWX.Req.WXSceneTimeline;  

	    if(req.checkArgs())
	    	this.mWechatApi.sendReq(req);
	    else
	    	Log.i("DDZ", "微信参数校验失败！");
	
	}
}
