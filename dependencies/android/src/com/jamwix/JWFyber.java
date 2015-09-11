package com.jamwix;


import java.lang.Runnable;

import android.app.Activity;
import android.content.res.AssetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.util.Log;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import com.sponsorpay.SponsorPay;
import com.sponsorpay.publisher.mbe.player.caching.SPCacheManager;
import com.sponsorpay.publisher.SponsorPayPublisher;
import com.sponsorpay.publisher.mbe.SPBrandEngageClient;
import com.sponsorpay.publisher.mbe.SPBrandEngageRequestListener;
import com.sponsorpay.publisher.currency.SPCurrencyServerErrorResponse;
import com.sponsorpay.publisher.currency.SPCurrencyServerListener;
import com.sponsorpay.publisher.currency.SPCurrencyServerSuccessfulResponse;

/* 
	You can use the Android Extension class in order to hook
	into the Android activity lifecycle. This is not required
	for standard Java code, this is designed for when you need
	deeper integration.
	
	You can access additional references from the Extension class,
	depending on your needs:
	
	- Extension.assetManager (android.content.res.AssetManager)
	- Extension.callbackHandler (android.os.Handler)
	- Extension.mainActivity (android.app.Activity)
	- Extension.mainContext (android.content.Context)
	- Extension.mainView (android.view.View)
	
	You can also make references to static or instance methods
	and properties on Java classes. These classes can be included 
	as single files using <java path="to/File.java" /> within your
	project, or use the full Android Library Project format (such
	as this example) in order to include your own AndroidManifest
	data, additional dependencies, etc.
	
	These are also optional, though this example shows a static
	function for performing a single task, like returning a value
	back to Haxe from Java.
*/
public class JWFyber extends Extension {

    private static Handler mHandler = new Handler(Looper.getMainLooper());
	
    private static final String TAG = "JWFyber";

	public static HaxeObject callback;
    private static JWBEListener _beListener;
    private static JWCurrencyListener _currencyListener;
    private static int VID_ACTIVITY = 9061933;
    private static boolean _doToast;

	/**
	 * Called when an activity you launched exits, giving you the requestCode 
	 * you started it with, the resultCode it returned, and any additional data 
	 * from it.
	 */
	public boolean onActivityResult (int requestCode, int resultCode, Intent data) {
        Log.d(TAG, "onActivityResult");
		
        if (resultCode == Activity.RESULT_OK && requestCode == JWFyber.VID_ACTIVITY) {
            String engagementResult = data.getStringExtra(SPBrandEngageClient.SP_ENGAGEMENT_STATUS);
            Log.d(TAG, "engagementResult: " + engagementResult);

            if (engagementResult.equals("CLOSE_FINISHED")) {
                JWFyber.callback.call0("onVideoFinished");
            } else if (engagementResult.equals("CLOSE_ABORTED")) {
                JWFyber.callback.call0("onVideoAborted");
            } else if (engagementResult.equals("VIDEO_ERROR")) {
                JWFyber.callback.call1("onOffersError", "Unknown Video Error");
            } else if (engagementResult.equals("VIDEO_STARTED")) {
                JWFyber.callback.call0("onVideoStarted");
            }
        }
		return true;
		
	}
	
	
	/**
	 * Called when the activity is starting.
	 */
	public void onCreate (Bundle savedInstanceState) {
        com.sponsorpay.utils.SponsorPayLogger.enableLogging(true);
		
	}
	
	
	/**
	 * Perform any final cleanup before an activity is destroyed.
	 */
	public void onDestroy () {
		
		
		
	}
	
	
	/**
	 * Called as part of the activity lifecycle when an activity is going into
	 * the background, but has not (yet) been killed.
	 */
	public void onPause () {
		
		
		
	}
	
	
	/**
	 * Called after {@link #onStop} when the current activity is being 
	 * re-displayed to the user (the user has navigated back to it).
	 */
	public void onRestart () {
		
		
		
	}
	
	
    public static void startFyber(String appId, String userId, String securityToken, 
                                  boolean doToast, HaxeObject myCallback) {
        _doToast = doToast;
        Log.d(TAG, "Attempting JWFyber start");
        callback = myCallback;
        _currencyListener = new JWCurrencyListener();
        _beListener = new JWBEListener();

        try {
            SponsorPay.start(appId, userId, securityToken, Extension.mainActivity);
        } catch (RuntimeException e){
            Log.e(TAG, e.getLocalizedMessage());
        }
        Log.d(TAG, "JWFyber star call finished");
    }

    public static void pauseDownloads() {
        SPCacheManager.pauseDownloads(Extension.mainContext);
    }

    public static void resumeDownloads() {
        SPCacheManager.resumeDownloads(Extension.mainContext);
    }

    public static void requestOffer() {
        Log.d(TAG, "JWFyber requestOffer");
        mHandler.post(new Runnable() {
            public void run() {
                SPBrandEngageClient.INSTANCE.setShowRewardsNotification(_doToast);
                SponsorPayPublisher.getIntentForMBEActivity(Extension.mainActivity, _beListener);
            }
        });
        Log.d(TAG, "JWFyber requestOffer complete");
    }

    public static void requestOfferWithReward(String currType, String placementId) {
        SponsorPayPublisher.getIntentForMBEActivity(
            Extension.mainActivity, 
            _beListener, 
            _currencyListener,
            currType,
            placementId);
    }

    public static void showVideoAd() {
        if (_beListener != null && _beListener.intent != null) {
            Extension.mainActivity.startActivityForResult(_beListener.intent, JWFyber.VID_ACTIVITY);
        }
    }


	/**
	 * Called after {@link #onRestart}, or {@link #onPause}, for your activity 
	 * to start interacting with the user.
	 */
	public void onResume () {
		
	}
	
	
	/**
	 * Called after {@link #onCreate} &mdash; or after {@link #onRestart} when  
	 * the activity had been stopped, but is now again being displayed to the 
	 * user.
	 */
	public void onStart () {
		
		
		
	}
	
	
	/**
	 * Called when the activity is no longer visible to the user, because 
	 * another activity has been resumed and is covering this one. 
	 */
	public void onStop () {
		
		
		
	}
	
	
}

class JWBEListener implements SPBrandEngageRequestListener {
    private static final String TAG = "JWFyber";

	public Intent intent;

    @Override
    public void onSPBrandEngageOffersAvailable(Intent spBrandEngageActivity) {
            Log.d(TAG, "SPBrandEngage - intent available");
            intent = spBrandEngageActivity;
            JWFyber.callback.call0( "onOffersAvailable" );
    }

    @Override
    public void onSPBrandEngageOffersNotAvailable() {
            Log.d(TAG, "SPBrandEngage - no offers for the moment");
            JWFyber.callback.call0( "onOffersNotAvailable" );
            intent = null;
    }

    @Override
    public void onSPBrandEngageError(String errorMessage) {
        Log.d(TAG, "SPBrandEngage - an error occurred:\n" + errorMessage);
        JWFyber.callback.call1( "onOffersError", errorMessage);
        intent = null;
    }    
}

class JWCurrencyListener implements SPCurrencyServerListener {
    private static final String TAG = "JWFyber";

    @Override
    public void onSPCurrencyServerError(SPCurrencyServerErrorResponse response) {
        Log.e(TAG, "VCS error received - " + response.getErrorMessage());
        JWFyber.callback.call1( "onCurrencyError", response.getErrorMessage());
    }

    @Override
    public void onSPCurrencyDeltaReceived(SPCurrencyServerSuccessfulResponse response) {
        Log.d(TAG, "VCS coins received - " + response.getDeltaOfCoins());
        JWFyber.callback.call4( 
            "onCurrencyRecieved", 
             response.getCurrencyId(),
             response.getCurrencyName(),
             response.getDeltaOfCoins(),
             response.getLatestTransactionId()
        );
    }
}
