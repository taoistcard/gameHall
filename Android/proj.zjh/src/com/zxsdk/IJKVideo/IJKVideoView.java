/*
 * Copyright (C) 2006 The Android Open Source Project
 * Copyright (c) 2014 Chukong Technologies Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.zxsdk.IJKVideo;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetFileDescriptor;
import android.content.res.Resources;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnErrorListener;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.FrameLayout;
import android.widget.MediaController.MediaPlayerControl;

import java.io.IOException;
import java.util.Map;

import org.cocos2dx.lib.Cocos2dxActivity;

import tv.danmaku.ijk.media.player.AndroidMediaPlayer;
import tv.danmaku.ijk.media.player.IMediaPlayer;
import tv.danmaku.ijk.media.player.IjkMediaPlayer;

public class IJKVideoView extends SurfaceView implements MediaPlayerControl {
    private String TAG = "VideoView";
    public class Settings {
        private Context mAppContext;
        private SharedPreferences mSharedPreferences;

        public static final int PV_PLAYER__Auto = 0;
        public static final int PV_PLAYER__AndroidMediaPlayer = 1;
        public static final int PV_PLAYER__IjkMediaPlayer = 2;
        public static final int PV_PLAYER__IjkExoMediaPlayer = 3;
        
        public static final boolean UsingOpenSLES = true;
        public static final boolean UsingMediaCodec = true;
        public static final String PixelFormat = "";
        public static final boolean UsingMediaCodecAutoRotate = true;
        		
    }
    private Settings mSettings;
    
    private Uri         mUri;   
    private int         mDuration;

    // all possible internal states
    private static final int STATE_ERROR              = -1;
    private static final int STATE_IDLE               = 0;
    private static final int STATE_PREPARING          = 1;
    private static final int STATE_PREPARED           = 2;
    private static final int STATE_PLAYING            = 3;
    private static final int STATE_PAUSED             = 4;
    private static final int STATE_PLAYBACK_COMPLETED = 5;

    /**
     * mCurrentState is a VideoView object's current state.
     * mTargetState is the state that a method caller intends to reach.
     * For instance, regardless the VideoView object's current state,
     * calling pause() intends to bring the object to a target state
     * of STATE_PAUSED.
     */
    private int mCurrentState = STATE_IDLE;
    private int mTargetState  = STATE_IDLE;

    // All the stuff we need for playing and showing a video
    private SurfaceHolder mSurfaceHolder = null;
    private IMediaPlayer mMediaPlayer = null;
    private int         mVideoWidth = 0;
    private int         mVideoHeight = 0;
    
    
    private OnVideoEventListener mOnVideoEventListener;
    private IMediaPlayer.OnPreparedListener mOnPreparedListener;
    private int         mCurrentBufferPercentage;
    private IMediaPlayer.OnErrorListener mOnErrorListener;
    
    // recording the seek position while preparing
    private int         mSeekWhenPrepared;  

    protected Cocos2dxActivity mCocos2dxActivity = null;
    
    protected int mViewLeft = 0;
    protected int mViewTop = 0;
    protected int mViewWidth = 0;
    protected int mViewHeight = 0;
    
    protected int mVisibleLeft = 0;
    protected int mVisibleTop = 0;
    protected int mVisibleWidth = 0;
    protected int mVisibleHeight = 0;
    
    protected boolean mFullScreenEnabled = false;
    protected int mFullScreenWidth = 0;
    protected int mFullScreenHeight = 0;
    
    private int mViewTag = 0;
    
    public IJKVideoView(Cocos2dxActivity activity,int tag) {
        super(activity);
        
        mViewTag = tag;
        mCocos2dxActivity = activity;
        initVideoView();
    }
    public IMediaPlayer createPlayer(int playerType) {
        IMediaPlayer mediaPlayer = null;

        switch (playerType) {
            case Settings.PV_PLAYER__IjkMediaPlayer: {
                IjkMediaPlayer ijkMediaPlayer = null;
                if (mUri != null) {
                    ijkMediaPlayer = new IjkMediaPlayer();
                    ijkMediaPlayer.native_setLogLevel(IjkMediaPlayer.IJK_LOG_DEBUG);

                    if (mSettings.UsingMediaCodec) {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 1);
                        if (mSettings.UsingMediaCodecAutoRotate) {
                            ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec-auto-rotate", 1);
                        } else {
                            ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec-auto-rotate", 0);
                        }
                    } else {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "mediacodec", 0);
                    }

                    if (mSettings.UsingOpenSLES) {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "opensles", 1);
                    } else {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "opensles", 0);
                    }

                    if (TextUtils.isEmpty(mSettings.PixelFormat)) {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "overlay-format", IjkMediaPlayer.SDL_FCC_RV32);
                    } else {
                        ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "overlay-format", mSettings.PixelFormat);
                    }
                    ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "framedrop", 1);
                    ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "start-on-prepared", 0);

                    ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "http-detect-range-support", 0);

                    ijkMediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_CODEC, "skip_loop_filter", 48);
                }
                mediaPlayer = ijkMediaPlayer;
            }
            break;
            case Settings.PV_PLAYER__IjkExoMediaPlayer: {
//                IjkExoMediaPlayer IjkExoMediaPlayer = new IjkExoMediaPlayer(mAppContext);
//                mediaPlayer = IjkExoMediaPlayer;
            }
            break;
            case Settings.PV_PLAYER__AndroidMediaPlayer:
            default: {
                AndroidMediaPlayer androidMediaPlayer = new AndroidMediaPlayer();
                mediaPlayer = androidMediaPlayer;
            }
            break;
        }

//        if (mSettings.getEnableDetachedSurfaceTextureView()) {
//            mediaPlayer = new TextureMediaPlayer(mediaPlayer);
//        }

        return mediaPlayer;
    }
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (mVideoWidth == 0 || mVideoHeight == 0) {
            setMeasuredDimension(mViewWidth, mViewHeight);
            Log.i(TAG, ""+mViewWidth+ ":" +mViewHeight);
        }
        else {
            setMeasuredDimension(mVisibleWidth, mVisibleHeight);
            Log.i(TAG, ""+mVisibleWidth+ ":" +mVisibleHeight);
        }
        
    }
    
    public void setVideoRect(int left, int top, int maxWidth, int maxHeight) {
        mViewLeft = left;
        mViewTop = top;
        mViewWidth = maxWidth;
        mViewHeight = maxHeight;
        
        if (mVideoWidth != 0 && mVideoHeight != 0) {
            fixSize(mViewLeft, mViewTop, mViewWidth, mViewHeight);
        }
    }
    
    public void setFullScreenEnabled(boolean enabled, int width, int height) {
        if (mFullScreenEnabled != enabled) {
            mFullScreenEnabled = enabled;
            if (width != 0 && height != 0) {
                mFullScreenWidth = width;
                mFullScreenHeight = height;
            }
            
            fixSize();
        }
    }
    
    public int resolveAdjustedSize(int desiredSize, int measureSpec) {
        int result = desiredSize;
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize =  MeasureSpec.getSize(measureSpec);

        switch (specMode) {
            case MeasureSpec.UNSPECIFIED:
                /* Parent says we can be as big as we want. Just don't be larger
                 * than max size imposed on ourselves.
                 */
                result = desiredSize;
                break;

            case MeasureSpec.AT_MOST:
                /* Parent says we can be as big as we want, up to specSize.
                 * Don't be larger than specSize, and don't be larger than
                 * the max size imposed on ourselves.
                 */
                result = Math.min(desiredSize, specSize);
                break;

            case MeasureSpec.EXACTLY:
                // No choice. Do what we are told.
                result = specSize;
                break;
        }
        return result;
}

    private boolean mNeedResume = false;
    
    @Override
    public void setVisibility(int visibility) {
        if (visibility == INVISIBLE) {
            mNeedResume = isPlaying();
            if (mNeedResume) {
                mSeekWhenPrepared = getCurrentPosition();
            }
        }
        else if (mNeedResume){
            start();
            mNeedResume = false;
        }
        super.setVisibility(visibility);
    }
    
    private void initVideoView() {
        mVideoWidth = 0;
        mVideoHeight = 0;
        getHolder().addCallback(mSHCallback);
        setFocusable(true);
        setFocusableInTouchMode(true);
        mCurrentState = STATE_IDLE;
        mTargetState  = STATE_IDLE;
    }
    
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if((event.getAction() & MotionEvent.ACTION_MASK) == MotionEvent.ACTION_UP)
        {
            if (isPlaying()) {
                pause();
            } else if(mCurrentState == STATE_PAUSED){
                resume();
            }
        }
        
        return true;
    }
    
    private boolean isAssetRouse = false;
    private String fileName = null;
    
    public void setVideoFileName(String path) {
        if (path.startsWith("/")) {
            isAssetRouse = false;
            setVideoURI(Uri.parse(path),null);
        }
        else {
            fileName = path;
            isAssetRouse = true;
            setVideoURI(Uri.parse(path),null);
        }
    }
    
    public void setVideoURL(String url) {
        isAssetRouse = false;
        setVideoURI(Uri.parse(url), null);
    }

    /**
     * @hide
     */
    private void setVideoURI(Uri uri, Map<String, String> headers) {
        mUri = uri;
        mSeekWhenPrepared = 0;
        mVideoWidth = 0;
        mVideoHeight = 0;
        openVideo();
        requestLayout();
        invalidate();
    }
    
    public void stopPlayback() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
            mTargetState  = STATE_IDLE;
        }
    }

    private void openVideo() {
        if (mSurfaceHolder == null) {
            // not ready for playback just yet, will try again later
            return;
        }
        if (isAssetRouse) {
            if(fileName == null)
                return;
        } else {
            if(mUri == null)
                return;
        }
        
        // Tell the music playback service to pause
        // TODO: these constants need to be published somewhere in the framework.
        Intent i = new Intent("com.android.music.musicservicecommand");
        i.putExtra("command", "pause");
        mCocos2dxActivity.sendBroadcast(i);

        // we shouldn't clear the target state, because somebody might have
        // called start() previously
        release(false);
        
        try {
            //if (mMediaPlayer == null) {
                mMediaPlayer = createPlayer(mSettings.PV_PLAYER__IjkMediaPlayer);
                mMediaPlayer.setOnPreparedListener(mPreparedListener);
                mMediaPlayer.setOnVideoSizeChangedListener(mSizeChangedListener);                
                mMediaPlayer.setOnCompletionListener(mCompletionListener);
                mMediaPlayer.setOnErrorListener(mErrorListener);
                mMediaPlayer.setOnBufferingUpdateListener(mBufferingUpdateListener);
                
                mMediaPlayer.setDisplay(mSurfaceHolder);
                mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                mMediaPlayer.setScreenOnWhilePlaying(true);
            //}
            
            mDuration = -1;
            mCurrentBufferPercentage = 0;
            if (isAssetRouse) {
                AssetFileDescriptor afd = mCocos2dxActivity.getAssets().openFd(fileName);
//                mMediaPlayer.setDataSource(afd.getFileDescriptor(),afd.getStartOffset(),afd.getLength());
                mMediaPlayer.setDataSource(afd.getFileDescriptor());
            } else {
                mMediaPlayer.setDataSource(mCocos2dxActivity, mUri);
            }
            
            mMediaPlayer.prepareAsync();

            /**
             * Don't set the target state here either, but preserve the target state that was there before.
             */
            mCurrentState = STATE_PREPARING;
        } catch (IOException ex) {
            Log.w(TAG, "Unable to open content: " + mUri, ex);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
            mErrorListener.onError(mMediaPlayer, MediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
            return;
        } catch (IllegalArgumentException ex) {
            Log.w(TAG, "Unable to open content: " + mUri, ex);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;
            mErrorListener.onError(mMediaPlayer, MediaPlayer.MEDIA_ERROR_UNKNOWN, 0);
            return;
        }
    }
    
    private boolean mKeepRatio = false;
    
    public void setKeepRatio(boolean enabled) {
        mKeepRatio = enabled;
        fixSize();
    }

    public void fixSize() {
        if (mFullScreenEnabled) {
            fixSize(0, 0, mFullScreenWidth, mFullScreenHeight);
        } else {
            fixSize(mViewLeft, mViewTop, mViewWidth, mViewHeight);
        }
    }
    
    public void fixSize(int left, int top, int width, int height) {
        if (width != 0 && height != 0) {
            if (mKeepRatio) {
                if ( mVideoWidth * height  > width * mVideoHeight ) {
                    mVisibleWidth = width;
                    mVisibleHeight = width * mVideoHeight / mVideoWidth;
                } else if ( mVideoWidth * height  < width * mVideoHeight ) {
                    mVisibleWidth = height * mVideoWidth / mVideoHeight;
                    mVisibleHeight = height;
                }
                mVisibleLeft = left + (width - mVisibleWidth) / 2;
                mVisibleTop = top + (height - mVisibleHeight) / 2;
            } else {
                mVisibleLeft = left;
                mVisibleTop = top;
                mVisibleWidth = width;
                mVisibleHeight = height;
            }
        }
        else {
            mVisibleLeft = left;
            mVisibleTop = top;
            mVisibleWidth = mVideoWidth;
            mVisibleHeight = mVideoHeight;
        }
        
        getHolder().setFixedSize(mVisibleWidth, mVisibleHeight);
        
        FrameLayout.LayoutParams lParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT);
        lParams.leftMargin = mVisibleLeft;
        lParams.topMargin = mVisibleTop;
        lParams.gravity = Gravity.TOP | Gravity.LEFT;
        setLayoutParams(lParams);
    }

    protected 
    IMediaPlayer.OnVideoSizeChangedListener mSizeChangedListener =
        new IMediaPlayer.OnVideoSizeChangedListener() {
            public void onVideoSizeChanged(IMediaPlayer mp, int width, int height, int sar_num, int sar_den) {
                mVideoWidth = mp.getVideoWidth();
                mVideoHeight = mp.getVideoHeight();
                if (mVideoWidth != 0 && mVideoHeight != 0) {
                    getHolder().setFixedSize(mVideoWidth, mVideoHeight);
                }
            }
    };
    

    
    IMediaPlayer.OnPreparedListener mPreparedListener = new IMediaPlayer.OnPreparedListener() {
        public void onPrepared(IMediaPlayer mp) {
            mCurrentState = STATE_PREPARED;

            if (mOnPreparedListener != null) {
                mOnPreparedListener.onPrepared(mMediaPlayer);
            }
            
            mVideoWidth = mp.getVideoWidth();
            mVideoHeight = mp.getVideoHeight();

            // mSeekWhenPrepared may be changed after seekTo() call
            int seekToPosition = mSeekWhenPrepared;  
            if (seekToPosition != 0) {
                seekTo(seekToPosition);
            }
            if (mVideoWidth != 0 && mVideoHeight != 0) {
                fixSize();
            } 
            
            if (mTargetState == STATE_PLAYING) {
                start();
            }
        }
    };

    private IMediaPlayer.OnCompletionListener mCompletionListener =
        new IMediaPlayer.OnCompletionListener() {
        public void onCompletion(IMediaPlayer mp) {
            mCurrentState = STATE_PLAYBACK_COMPLETED;
            mTargetState = STATE_PLAYBACK_COMPLETED;
            
            release(true);
            if (mOnVideoEventListener != null) {
                mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_COMPLETED);
            }
        }
    };
    
    
    private static final int EVENT_PLAYING = 0;
    private static final int EVENT_PAUSED = 1;
    private static final int EVENT_STOPPED = 2;
    private static final int EVENT_COMPLETED = 3;
    
    public interface OnVideoEventListener
    {
        void onVideoEvent(int tag,int event);
    }

    private IMediaPlayer.OnErrorListener mErrorListener =
        new IMediaPlayer.OnErrorListener() {
    	
        public boolean onError(IMediaPlayer mp, int framework_err, int impl_err) {
            Log.d(TAG, "Error: " + framework_err + "," + impl_err);
            mCurrentState = STATE_ERROR;
            mTargetState = STATE_ERROR;

            /* If an error handler has been supplied, use it and finish. */
            if (mOnErrorListener != null) {
                if (mOnErrorListener.onError(mMediaPlayer, framework_err, impl_err)) {
                    return true;
                }
            }

            /* Otherwise, pop up an error dialog so the user knows that
             * something bad has happened. Only try and pop up the dialog
             * if we're attached to a window. When we're going away and no
             * longer have a window, don't bother showing the user an error.
             */
            if (getWindowToken() != null) {
                Resources r = mCocos2dxActivity.getResources();
                int messageId;
                
                if (framework_err == MediaPlayer.MEDIA_ERROR_NOT_VALID_FOR_PROGRESSIVE_PLAYBACK) {
                    // messageId = com.android.internal.R.string.VideoView_error_text_invalid_progressive_playback;
                    messageId = r.getIdentifier("VideoView_error_text_invalid_progressive_playback", "string", "android");
                } else {
                    // messageId = com.android.internal.R.string.VideoView_error_text_unknown;
                    messageId = r.getIdentifier("VideoView_error_text_unknown", "string", "android");
                }
                
                int titleId = r.getIdentifier("VideoView_error_title", "string", "android");
                int buttonStringId = r.getIdentifier("VideoView_error_button", "string", "android");
                
                new AlertDialog.Builder(mCocos2dxActivity)
                        .setTitle(r.getString(titleId))
                        .setMessage(messageId)
                        .setPositiveButton(r.getString(buttonStringId),
                                new DialogInterface.OnClickListener() {
                                    public void onClick(DialogInterface dialog, int whichButton) {
                                        /* If we get here, there is no onError listener, so
                                         * at least inform them that the video is over.
                                         */
                                        if (mOnVideoEventListener != null) {
                                            mOnVideoEventListener.onVideoEvent(mViewTag,EVENT_COMPLETED);
                                        }
                                    }
                                })
                        .setCancelable(false)
                        .show();
            }
            return true;
        }
    };

    private IMediaPlayer.OnBufferingUpdateListener mBufferingUpdateListener =
        new IMediaPlayer.OnBufferingUpdateListener() {
        public void onBufferingUpdate(IMediaPlayer mp, int percent) {
            mCurrentBufferPercentage = percent;
        }
    };

    /**
     * Register a callback to be invoked when the media file
     * is loaded and ready to go.
     *
     * @param l The callback that will be run
     */
    public void setOnPreparedListener(IMediaPlayer.OnPreparedListener l)
    {
        mOnPreparedListener = l;
    }

    /**
     * Register a callback to be invoked when the end of a media file
     * has been reached during play back.
     *
     * @param l The callback that will be run
     */
    public void setOnCompletionListener(OnVideoEventListener l)
    {
        mOnVideoEventListener = l;
    }

    /**
     * Register a callback to be invoked when an error occurs
     * during play back or setup.  If no listener is specified,
     * or if the listener returned false, VideoView will inform
     * the user of any errors.
     *
     * @param l The callback that will be run
     */
    public void setOnErrorListener(IMediaPlayer.OnErrorListener l)
    {
        mOnErrorListener = l;
    }

    SurfaceHolder.Callback mSHCallback = new SurfaceHolder.Callback()
    {
        public void surfaceChanged(SurfaceHolder holder, int format,
                                    int w, int h)
        {
            boolean isValidState =  (mTargetState == STATE_PLAYING);
            boolean hasValidSize = (mVideoWidth == w && mVideoHeight == h);
            if (mMediaPlayer != null && isValidState && hasValidSize) {
                if (mSeekWhenPrepared != 0) {
                    seekTo(mSeekWhenPrepared);
                }
                start();
            }
        }

        public void surfaceCreated(SurfaceHolder holder)
        {
            mSurfaceHolder = holder;
            openVideo();
        }

        public void surfaceDestroyed(SurfaceHolder holder)
        {
            // after we return from this we can't use the surface any more
            mSurfaceHolder = null;
            
            release(true);
        }
    };

    /*
     * release the media player in any state
     */
    private void release(boolean cleartargetstate) {
        if (mMediaPlayer != null) {
            mMediaPlayer.reset();
            mMediaPlayer.release();
            mMediaPlayer = null;
            mCurrentState = STATE_IDLE;
            if (cleartargetstate) {
                mTargetState  = STATE_IDLE;
            }
        }
    }
    
    public void start() {
        if (isInPlaybackState()) {
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
            if (mOnVideoEventListener != null) {
                mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PLAYING);
            }
        }
        mTargetState = STATE_PLAYING;
    }

    public void pause() {
        if (isInPlaybackState()) {
            if (mMediaPlayer.isPlaying()) {
                mMediaPlayer.pause();
                mCurrentState = STATE_PAUSED;
                if (mOnVideoEventListener != null) {
                    mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PAUSED);
                }
            }
        }
        mTargetState = STATE_PAUSED;
    }
    
    public void stop() {
        if (isInPlaybackState()) {
            if (mMediaPlayer.isPlaying()) {
               stopPlayback();
                if (mOnVideoEventListener != null) {
                    mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_STOPPED);
                }
            }
        }
    }

    public void suspend() {
        release(false);
    }

    public void resume() {
        if (isInPlaybackState()) {
            if (mCurrentState == STATE_PAUSED) {
                mMediaPlayer.start();
                mCurrentState = STATE_PLAYING;
                if (mOnVideoEventListener != null) {
                    mOnVideoEventListener.onVideoEvent(mViewTag, EVENT_PLAYING);
                }
            }
        }
    }

    public void restart() {
        if (isInPlaybackState()) {
            mMediaPlayer.seekTo(0);
            mMediaPlayer.start();
            mCurrentState = STATE_PLAYING;
            mTargetState = STATE_PLAYING;
        }
    }
    // cache duration as mDuration for faster access
    public int getDuration() {
        if (isInPlaybackState()) {
            if (mDuration > 0) {
                return mDuration;
            }
            mDuration = (int)mMediaPlayer.getDuration();
            return mDuration;
        }
        mDuration = -1;
        return mDuration;
    }

    public int getCurrentPosition() {
        if (isInPlaybackState()) {
            return (int)mMediaPlayer.getCurrentPosition();
        }
        return 0;
    }

    public void seekTo(int msec) {
        if (isInPlaybackState()) {
            mMediaPlayer.seekTo(msec);
            mSeekWhenPrepared = 0;
        } else {
            mSeekWhenPrepared = msec;
        }
    }

    public boolean isPlaying() {
        return isInPlaybackState() && mMediaPlayer.isPlaying();
    }

    public int getBufferPercentage() {
        if (mMediaPlayer != null) {
            return mCurrentBufferPercentage;
        }
        return 0;
    }

    public boolean isInPlaybackState() {
        return (mMediaPlayer != null &&
                mCurrentState != STATE_ERROR &&
                mCurrentState != STATE_IDLE &&
                mCurrentState != STATE_PREPARING);
    }

    @Override
    public boolean canPause() {
        // TODO Auto-generated method stub
        return true;
    }

    @Override
    public boolean canSeekBackward() {
        // TODO Auto-generated method stub
        return true;
    }

    @Override
    public boolean canSeekForward() {
        // TODO Auto-generated method stub
        return true;
    }
        
    public int getAudioSessionId () {
       // TODO Auto-generated method stub
       return mMediaPlayer.getAudioSessionId();
    }
}
