package com.zxsdk.UnitedPlatform;

import org.json.JSONObject;
import android.app.Activity;
import android.content.SharedPreferences;


public class UnitedLoadHistory {
	public static String        DB_NAME                = "98pk";
	
	
	private static final String KEY_USERINFO               = "userinfo";
    private static final String USER         = "user";
    private static final String PWD          = "pwd";
    /* 加密种子 */
    public static String        SEED                   = "com.98pk.game";
    
    private SharedPreferences mSharePre=null;
    private static UnitedLoadHistory instance=null;
    public static  UnitedLoadHistory GetInstance() {
		if(instance==null)
		{
			instance=new UnitedLoadHistory();
		}
		return instance;
	}
 
	public void init(Activity activity) 
	{
		 this.mSharePre=activity.getSharedPreferences(DB_NAME, activity.MODE_PRIVATE);
		 this.Load();
	}
	
	private String mUserName="";
	private String mPassword="";
	public String GetUserinfo() 
	{
		if(mUserName!=null&&mUserName.length()>0&&mPassword!=null&&mPassword.length()>0)
		{
			return mUserName+"|"+mPassword;
		}
		return "";
	}
	
	private void Load()
	{
		    String string = this.mSharePre.getString(KEY_USERINFO, null);
	        if (string == null) {
	            return;
	        }
	        try 
	        {
	            string =UnifieCryptoTool.decrypt(SEED, string);
	            JSONObject json = new JSONObject(string);
	            this.mUserName = json.optString(USER, null);
	            this.mPassword = json.optString(PWD, null);
	        } catch (Exception e) {

	            return;
	        }
	}
}
