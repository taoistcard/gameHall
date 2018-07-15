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
package cn.game100.HappyHall;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URLEncoder;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lib.Cocos2dxVideoHelper;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONObject;

import cn._98game.platform.Constants;
import cn._98game.platform.listener.CustomAvatarListener;

//import cn.play.dserv.CheckTool;

import com.zxsdk.Tencent.WechatPlatform;
import com.zxsdk.UnitedPlatform.UnitedPlatform;
//import com.zxsdk.IJKVideo.IJKVideoHelper;
//import com.zxsdk.IJKVideo.IJKVideoInterface;
import com.zxsdk._98Platform.ImagePickerActivity;
import com.zxsdk._98Platform._98Platform;
import com.zxsdk._98Platform._98Platform.PayDataListener;


import com.alipay.sdk.app.PayTask;
import com.umeng.message.UmengRegistrar;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap.CompressFormat;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.provider.Settings;
import android.text.TextUtils;
import android.text.format.Formatter;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.Toast;


public class GameActivity extends AppActivity implements PayDataListener{
	
	public static GameActivity instance=null;
//    private IAPListener mListener;
//	public static Purchase purchase;
	
	// 计费信息
	// 计费信息 (现网环境)
	private String MM_APPID = "";
	private String MM_APPKEY = "";
	
	private String EGAME_APPID = "";
	private String EGAME_APPKEY = "";
	private int EGAME_CLIENTID = 0;
	
	private static final int PRODUCT_NUM = 1;
	private static String mPayCode = "";
	private static int mPayPrice = 0;
	private static int sdkType = 0;
		
    static String hostIPAdress = "0.0.0.0";
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		instance = this;
		
		//初始化三方sdk
		initThirdSdk();
		keepScreenLight();

		//手动触发登陆
		initLogin();
	}
	
	private void initThirdSdk()
	{
		Log.i("sdk", "start init sdk!");
		UnitedPlatform.getInstance().init(this);
		
//		initMMSdk();//初始化MM计费
//		initEGAMESdk();//初始化爱游戏计费
		
		//初始化视频
//		IJKVideoInterface.getInstance().init(this);
//		IJKVideoInterface.getInstance().onStart();
	}
	private void keepScreenLight()
	{
		Cocos2dxHelper.setKeepScreenOn(true);
//		this.powerManager = (PowerManager)this.getSystemService(Context.POWER_SERVICE);
//        this.wakeLock = this.powerManager.newWakeLock(PowerManager.FULL_WAKE_LOCK, "My Lock");
	}
	
	private boolean isNetworkConnected() {
	        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
	        if (cm != null) {  
	            NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
			ArrayList networkTypes = new ArrayList();
			networkTypes.add(ConnectivityManager.TYPE_WIFI);
			try {
				networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
			} catch (NoSuchFieldException nsfe) {
			}
			catch (IllegalAccessException iae) {
				throw new RuntimeException(iae);
			}
			if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
	                return true;  
	            }  
	        }  
	        return false;  
	    } 
	 
	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}
	
	public static String getLocalIpAddress() {
		return hostIPAdress;
	}
	
   @Override
    protected void onResume() {
        super.onResume();
//        EgameUser.onResume(GameActivity.this);
        UnitedPlatform.getInstance().onResume(this);
//        this.wakeLock.acquire();

    }

    @Override
    protected void onPause() {
        super.onPause();
//        EgameUser.onPause(GameActivity.this);
        UnitedPlatform.getInstance().onPause(this);
//        this.wakeLock.release();
    }
    
    protected void onDestroy() {
    // TODO Auto-generated method stub
        super.onDestroy();
//        IJKVideoInterface.getInstance().release();
//        this.wakeLock.release(); //解除保持唤醒
    } 
    
//	private static native boolean nativeIsLandScape();
//	private static native boolean nativeIsDebug();

    protected void initEGAMESdk(){
//    	EGAME_APPID = this.getString(R.string.CTCC_AppId);
//	    EGAME_APPKEY = this.getString(R.string.CTCC_AppKey);
//	    EGAME_CLIENTID = Integer.parseInt(this.getString(R.string.CTCC_ClientID));
//	    
//	    EgamePay.init(this);
//		CheckTool.init(this);
    }
	/*********************************/
	protected void initMMSdk(){
//		MM_APPID = this.getString(R.string.CMCC_AppId);
//	    MM_APPKEY = this.getString(R.string.CMCC_AppKey);
//	        
//		IAPHandler iapHandler = new IAPHandler(this);
//		/**
//		 * IAP组件初始化.包括下面3步。
//		 */
//		/**
//		 * step1.实例化PurchaseListener。实例化传入的参数与您实现PurchaseListener接口的对象有关。
//		 * 例如，此Demo代码中使用IAPListener继承PurchaseListener，其构造函数需要Context实例。
//		 */
//		mListener = new IAPListener(this, iapHandler);
//		/**
//		 * step2.获取Purchase实例。
//		 */
//		purchase = Purchase.getInstance();
//		/**
//		 * step3.向Purhase传入应用信息。APPID，APPKEY。 需要传入参数APPID，APPKEY。 APPID，见开发者文档
//		 * APPKEY，见开发者文档
//		 */
//		try {
//			purchase.setAppInfo(MM_APPID, MM_APPKEY);
//	
//		} catch (Exception e1) {
//			e1.printStackTrace();
//		}
//		/**
//		 * step4. IAP组件初始化开始， 参数PurchaseListener，初始化函数需传入step1时实例化的
//		 * PurchaseListener。
//		 */
//		try {
//			purchase.init(this, mListener);
//	
//		} catch (Exception e) {
//			e.printStackTrace();
//			return;
//		}
	}
	
	public void order(String packageID, String payCode, int sdk) {
		try {

			HashMap<String, String> params = new HashMap();
			params.put(Constants.PARAM_PRODUCTID, payCode);
			params.put(Constants.PARAM_ORDERCOUNT, "1");
			params.put(Constants.PARAM_CHANNELID, Integer.toString(sdk));

			this.mPayCode = payCode;
			this.sdkType = sdk;
			
			
			_98Platform.getInstance().PayBySms(params, this);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public void order1(String packageID, String payCode, int price, int sdk) {
		try {
			HashMap<String, String> params = new HashMap();
			params.put(Constants.PARAM_FEE, Integer.toString(price));
			params.put(Constants.PARAM_PACKAGEID, packageID);
//			params.put(Constants.PARAM_ISCHILD, "1");
			params.put(Constants.PARAM_CHANNELID, Integer.toString(sdk));
			this.mPayCode = payCode;
			this.mPayPrice = price;
			this.sdkType = sdk;
			
			_98Platform.getInstance().PayBySms(params, this);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public void order2(String packageID, int sdk)
	{
		try{
			HashMap<String, String> params = new HashMap();
			params.put(Constants.PARAM_PACKAGEID, packageID);
			params.put(Constants.PARAM_CHANNELID, Integer.toString(sdk));
			
			this.sdkType = sdk;
			
			_98Platform.getInstance().Pay(params, this);
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	public static final String removeBOM(String data) {
		if (TextUtils.isEmpty(data)) {
		return data;
		}
	
		if (data.startsWith("\ufeff")) {
		return data.substring(1);
		} else {
		return data;
		}
	}
	public void onPayOrderResult(final int code, String orderID)
	{
		Log.i("DDZ", "orderID = " + orderID);
		try{
			if(this.sdkType == Constants.SDK_MOBILE_MM)
				//mm支付
//				purchase.order(this, this.mPayCode, this.PRODUCT_NUM, mListener);
				Log.d("DDZ", "mm支付订单号"+ orderID);
			
			else if(this.sdkType == Constants.SDK_TELECOM_EGAME)
				Log.d("DDZ", "EGame支付订单号"+ orderID);
			  
			else if(this.sdkType == Constants.SDK_ALIPAY)
            {
				/*{
				    "Params": "partner=\"2088111773850773\"&seller_id=\"2088111773850773\"&out_trade_no=\"ZFB20151105175154382A6E90E\"&subject=\"每日首充1元\"&body=\"每日一次，赠送1万金币\"&total_fee=\"1.00\"&notify_url=\"http://service.game100.cn/mobilepay/alipayapp/notify\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&app_id=\"2015102900586167\"&sign=\"oaeBrmqymlQueYzcicD7SDhxdNYHpiXS38scGVZzv15zf%2B6Mwn6%2FABDjpM%2BZE%2Few40pk1ArIqHboPgqLsRqCe0bYhWG8hqhmq9u6CPgZVq6%2F7BDzhPjrCeJPpPJtpJQCiXAmqylRi0K5%2FwP1lTinh1TlGO30rtJLjuIJuNsmRmE%3D\"&sign_type=\"RSA\"",
				    "ParamsType": "AlipayApp"
				}*/
				try{
					orderID = this.removeBOM(orderID);
					JSONObject json = new JSONObject(orderID);
					this.alipay(json.getString("Params"));
				}
				catch(Exception e)
				{
					Log.d("DDZ", "Alipay支付订单号"+ orderID);
				}
                //应用注册scheme,在Info.plist定义URLtypes
//                NSString *appScheme = @"alipaydemo";
//                NSString *params = [data valueForKey:@"Params"];
//                //将签名成功字符串格式化为订单字符串,请严格按照该格式
//                if (params != nil) {
//                    [[AlipaySDK defaultService] payOrder:params fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//                        NSLog(@"reslut = %@",resultDic);
//                    }];
//                }
				
				
            }
			else if(this.sdkType == Constants.SDK_WECHAT)
            {
				try{
					JSONObject json = new JSONObject(orderID);
					JSONObject params = json.getJSONObject("Params");
					WechatPlatform.getInstance().sendReq(params);
				}
				catch(Exception e)
				{
					Log.d("DDZ", "Wechat支付订单号"+ orderID);
				}
				
            }

		}
		catch(Exception e1){
			e1.printStackTrace();
			return;
		}
	}
	public void finish()
	{
		super.finish();
		Log.i("DDZ", "-------this.finished()!!!");
	}
	
//    @Override
//    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//        if (resultCode == ErrorCode.TOEKN_INVALID) {
//            //在此处重新调用登陆接口
//            initLogin();
//        }
//        super.onActivityResult(requestCode, resultCode, data);
//    }

    public void initLogin() {
    }
    
    /******************支付宝*****************************/
	
	public class PayResult {
		private String resultStatus;
		private String result;
		private String memo;
	
		public PayResult(String rawResult) {
	
			if (TextUtils.isEmpty(rawResult))
				return;
	
			String[] resultParams = rawResult.split(";");
			for (String resultParam : resultParams) {
				if (resultParam.startsWith("resultStatus")) {
					resultStatus = gatValue(resultParam, "resultStatus");
				}
				if (resultParam.startsWith("result")) {
					result = gatValue(resultParam, "result");
				}
				if (resultParam.startsWith("memo")) {
					memo = gatValue(resultParam, "memo");
				}
			}
		}
	
		@Override
		public String toString() {
			return "resultStatus={" + resultStatus + "};memo={" + memo
					+ "};result={" + result + "}";
		}
	
		private String gatValue(String content, String key) {
			String prefix = key + "={";
			return content.substring(content.indexOf(prefix) + prefix.length(),
					content.lastIndexOf("}"));
		}
	
		/**
		 * @return the resultStatus
		 */
		public String getResultStatus() {
			return resultStatus;
		}
	
		/**
		 * @return the memo
		 */
		public String getMemo() {
			return memo;
		}
	
		/**
		 * @return the result
		 */
		public String getResult() {
			return result;
		}
	}


	// 支付宝公钥
	public static final String RSA_PUBLIC = "";
	private static final int SDK_PAY_FLAG = 1;
	private static final int SDK_CHECK_FLAG = 2;
	
	private Handler mHandler = new Handler() {
		public void handleMessage(Message msg) {
			switch (msg.what) {
			case SDK_PAY_FLAG: {
				
				PayResult payResult = new PayResult((String) msg.obj);

				// 支付宝返回此次支付结果及加签，建议对支付宝签名信息拿签约时支付宝提供的公钥做验签
				String resultInfo = payResult.getResult();

				String resultStatus = payResult.getResultStatus();

				// 判断resultStatus 为“9000”则代表支付成功，具体状态码代表含义可参考接口文档
				if (TextUtils.equals(resultStatus, "9000")) {
					Toast.makeText(GameActivity.this, "支付成功",
							Toast.LENGTH_SHORT).show();
				} else {
					// 判断resultStatus 为非“9000”则代表可能支付失败
					// “8000”代表支付结果因为支付渠道原因或者系统原因还在等待支付结果确认，最终交易是否成功以服务端异步通知为准（小概率状态）
					if (TextUtils.equals(resultStatus, "8000")) {
						Toast.makeText(GameActivity.this, "支付结果确认中",
								Toast.LENGTH_SHORT).show();

					} else {
						// 其他值就可以判断为支付失败，包括用户主动取消支付，或者系统返回的错误
						Toast.makeText(GameActivity.this, "支付失败",
								Toast.LENGTH_SHORT).show();

					}
				}
				break;
			}
			case SDK_CHECK_FLAG: {
				Toast.makeText(GameActivity.this, "检查结果为：" + msg.obj,
						Toast.LENGTH_SHORT).show();
				break;
			}
			default:
				break;
			}
		};
	};
	
	/**
	 * check whether the device has authentication alipay account.
	 * 查询终端设备是否存在支付宝认证账户
	 * 
	 */
	public void checkAlipay(View v) {
		Runnable checkRunnable = new Runnable() {

			@Override
			public void run() {
				// 构造PayTask 对象
				PayTask payTask = new PayTask(GameActivity.this);
				// 调用查询接口，获取查询结果
				boolean isExist = payTask.checkAccountIfExist();

				Message msg = new Message();
				msg.what = SDK_CHECK_FLAG;
				msg.obj = isExist;
				mHandler.sendMessage(msg);
			}
		};

		Thread checkThread = new Thread(checkRunnable);
		checkThread.start();

	}
	public void alipay(final String payInfo) {
		

		Runnable payRunnable = new Runnable() {

			@Override
			public void run() {
				// 构造PayTask 对象
				PayTask alipay = new PayTask(GameActivity.this);
				// 调用支付接口，获取支付结果
				String result = alipay.pay(payInfo);

				Message msg = new Message();
				msg.what = SDK_PAY_FLAG;
				msg.obj = result;
				mHandler.sendMessage(msg);
			}
		};

		// 必须异步调用
		Thread payThread = new Thread(payRunnable);
		payThread.start();
	}
	
	/******************支付宝 end*****************************/
}
