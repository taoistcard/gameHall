package com.raccoon.cc.doudizhunew;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

public class SplashyActivity extends Activity {
	private long splashyTime = 2000;// 闪屏停留时间
	private boolean isStop = false;// 闪屏暂停
	private boolean isActivity = true;// 是否跳过闪屏直接进入主Activity

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);// 隐藏标题
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
				WindowManager.LayoutParams.FLAG_FULLSCREEN);// 设置全屏

		setContentView(R.layout.splashy);

		Thread splashyThread = new Thread() {
			public void run() {
				try {
					long ms = 0;
					while (isActivity && ms < splashyTime) {
						sleep(100);
						if (!isStop) {
							ms += 100;
						}
						Log.i("TAG", ms + "");
					}

					// 加入此
					// 会去配置文件AndroidManifest.xml找对应的com.google.app.splashy.CLEARSPLASH,有此标识的Activity是闪屏后切换的界面
					startActivity(new Intent("com.google.app.splashy.CLEARSPLASH"));

				} catch (InterruptedException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} finally {
					finish();
				}
			}
		};
		splashyThread.start();
	}

	@Override
	protected void onPause() {
		// TODO Auto-generated method stub
		super.onPause();
		isStop = true;
	}

	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		super.onRestart();
		isStop = false;
	}
}
