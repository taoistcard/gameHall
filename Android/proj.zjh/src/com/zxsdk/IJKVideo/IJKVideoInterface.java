package com.zxsdk.IJKVideo;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxVideoHelper;

import android.content.Context;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;


public class IJKVideoInterface  {
	private volatile static IJKVideoInterface instance;	
	private IJKVideoHelper mVideoHelper=null;
	private int mCurVideo=0;

	static public IJKVideoInterface getInstance()
	{
		if(instance==null)
		{
			synchronized(IJKVideoInterface.class)
			{
				if(instance==null)
				{
					instance = new IJKVideoInterface();
				}
			}
		}
		return instance;
	}

    public void init(Cocos2dxActivity ctx)
    {

		if (mVideoHelper == null) {
            mVideoHelper = new IJKVideoHelper(ctx, ctx.getFrameLayout());
        }
		
    	// 	init player
	    IjkMediaPlayer.loadLibrariesOnce(null);
	    IjkMediaPlayer.native_profileBegin("libijkplayer.so");

    }
    public void createVedioView(int x,int y, int w, int h)
    {
    	mCurVideo = IJKVideoHelper.createVideoWidget();
	    IJKVideoHelper.setVideoRect(mCurVideo, x, y, w, h);
    }
    public void play(String url)
    {
    	IJKVideoHelper.setVideoUrl(mCurVideo, 1, url);
	    IJKVideoHelper.startVideo(mCurVideo);
    }
    public void stop()
    {
	    IJKVideoHelper.removeVideoWidget(mCurVideo);
	    mCurVideo--;
    }
    public void seek() {

    	IJKVideoHelper.seekVideoTo(mCurVideo, 0);
    }
    public void setVisible(boolean visible)
    {
    	IJKVideoHelper.setVideoVisible(mCurVideo, visible);
    }
    
    public void release() {

        IjkMediaPlayer.native_profileEnd();
    }

}
