package com.zxsdk._98Platform;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.zxsdk._98Platform._98Platform;
//import com.zxsdk.TianTian.TTPlatform;

import cn._98game.platform.listener.CustomAvatarListener;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

public class ImagePickerActivity extends Activity{

	private static final int REQUEST_CODE_GETIMAGE_BYSDCARD = 0;// 从sd卡得到图像的请求码
	private static final int REQUEST_CODE_GETIMAGE_BYCAMERA = 1;// 从相机得到图像的请求码
	private static final int REQUEST_CODE_FIXED_BYPHOTO = 2;
	private static final int REQUEST_CODE_FIXED_BYCAMERA = 3;
	private static final int REQUEST_CODE_FIXED_IMAGE = 4;
	
	private String thisLarge = null, theSmall = null;
	private byte[] picture2;
	protected void onCreate(Bundle savedInstanceState) {
		// TODO Auto-generated method stub
		super.onCreate(savedInstanceState);
//		// 窗体状态设置-设置为无标题栏状态【全屏】
//		this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
//				WindowManager.LayoutParams.FLAG_FULLSCREEN);
//		requestWindowFeature(Window.FEATURE_NO_TITLE);
//		// 强制横屏
//		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
//	
		Intent in = this.getIntent();
		int type = in.getExtras().getInt("type");
		
		Log.i("ttc", "type = "+type);
		this.imageChooseItem(type);
	}

	/**
	 * 操作选择
	 * 
	 * @param items
	 */
	public void imageChooseItem(int item) {
		if (item == 0) {
			// 手机选图
			Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
			intent.setType("image/*");
			startActivityForResult(intent, REQUEST_CODE_GETIMAGE_BYSDCARD);
		}
		// 拍照
		else if (item == 1) {
			Intent intentC = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
			intentC.putExtra(MediaStore.EXTRA_OUTPUT, 
							Uri.fromFile(new File(Environment.getExternalStorageDirectory(), 
												"temp.jpg")));
			startActivityForResult(intentC, REQUEST_CODE_GETIMAGE_BYCAMERA);
		}
	}
	//裁减图片
	public void startPhotoZoom(Uri uri, int requestCode) {
		System.out.println(uri);
		Intent intent = new Intent("com.android.camera.action.CROP");
		intent.setDataAndType(uri, "image/*");
		intent.putExtra("crop", "true");
		// aspectX aspectY 是宽高的比例
		intent.putExtra("aspectX", 1);
		intent.putExtra("aspectY", 1);
		// outputX outputY 是裁剪图片宽高
		intent.putExtra("outputX", 110);
		intent.putExtra("outputY", 110);
		intent.putExtra("return-data", true);
		startActivityForResult(intent, requestCode);
	}
	// 获取图片
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.i("ttc","requestCode="+requestCode+", resultCode="+resultCode);
		super.onActivityResult(requestCode,resultCode,data);
		
		if (requestCode == REQUEST_CODE_GETIMAGE_BYSDCARD) {
			
			if (data != null) {
				Uri selectedImage = data.getData();				 
				this.startPhotoZoom(selectedImage, REQUEST_CODE_FIXED_IMAGE);
			}
			else
				this.finish();
		}
		else if (requestCode == REQUEST_CODE_GETIMAGE_BYCAMERA) {
			
			if (resultCode == RESULT_OK) {
				// 设置文件保存路径这里放在跟目录下
				File picture = new File(Environment.getExternalStorageDirectory() + "/temp.jpg");
				this.startPhotoZoom(Uri.fromFile(picture), REQUEST_CODE_FIXED_IMAGE);
			}
			else
				this.finish();
		} 
		else if (requestCode == REQUEST_CODE_FIXED_IMAGE) {
			if (data != null){
				Bitmap bmp = data.getParcelableExtra("data");
				this.finishActivity(REQUEST_CODE_FIXED_BYPHOTO);
				this.saveImage(bmp);
			}
			this.finish();
		}
	}
	
	public void saveImage(Bitmap bmp)
	{
		String path = Environment.getExternalStorageDirectory() + "/temp.jpg";
		
		try {

			File file = new File(path);
            file.delete();  

			FileOutputStream stream = new FileOutputStream(path);  
			bmp.compress(Bitmap.CompressFormat.JPEG, 100, stream);
			stream.flush();
			stream.close();
		}
		catch (FileNotFoundException e) {  
			e.printStackTrace();  
		}
		catch (IOException e) { 
			e.printStackTrace();
		}
		
		this.upLoadImage(path);
	}
	
	public void upLoadImage(String filePath) {
		
		_98Platform.getInstance().uploadAvatarImage(filePath);
	} 
}
