package com.jamwix;

#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import openfl.events.EventDispatcher;
import openfl.events.Event;

#if (android && openfl)
import openfl.utils.JNI;
#end


class JWFyber {
	
	private static var initialized = false;
	private static var dispatcher = new EventDispatcher ();

	public static function start(appId:String, userId:String, token:String):Void 
	{
		#if (android || ios)
		if (!initialized) 
		{
			set_event_handle(notifyListeners);
			initialized = true;
		}

		jwfyber_start(appId, userId, token);
		#end
	}
	
	public static function pauseDownloads():Void
	{
		#if (android || ios)
		jwfyber_pause_downloads();
		#end
	}

	public static function resumeDownloads():Void
	{
		#if (android || ios)
		jwfyber_resume_downloads();
		#end
	}

	public static function requestOffer(rewardType:String = null, placementId:String = null):Void
	{
		#if (android || ios)
		if (rewardType != null && placementId != null)
		{
			jwfyber_request_offer_with_reward(rewardType, placementId);
		}
		else
		{
			jwfyber_request_offer_();
		}
		#end
	}

	public static function showVideoAd():Void
	{
		#if (android || ios)
		jwfyber_show_video_ad();
		#end
	}

	private static function notifyListeners(inEvent:Dynamic):Void
	{
		
		#if ios
		
		var type = Std.string (Reflect.field (inEvent, "type"));
		var data = Std.string (Reflect.field (inEvent, "data"));
		
		switch (type) {
			
			case "VIDEO_CLOSE_FINISHED":
				
				dispatchEvent(new JWFyberEvent(JWFyberEvent.VIDEO_CLOSE_FINISHED, data));
			
			case "VIDEO_CLOSE_ABORTED":
				
				dispatchEvent(new JWFyberEvent(JWFyberEvent.VIDEO_CLOSE_ABORTED, data));

			case "VIDEO_STARTED":

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.VIDEO_STARTED, data));
			
			case "VIDEO_ERROR":

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.VIDEO_ERROR, data));

			case "OFFERS_AVAILABLE":

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.OFFERS_AVAILABLE, data));

			case "OFFERS_NOT_AVAILABLE":

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.OFFERS_NOT_AVAILABLE, data));

			case "CURRENCY_REWARDED":

				var returnData:Dynamic = null;
				try {
					returnData = Json.parse(data);
				} catch (err:String) {
					trace("Unable to parse currency reward data: " + err);
					returnData = null;
				}

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.CURRENCY_REWARDED, returnData));

			case "CURRENCY_ERROR":

				dispatchEvent(
					new JWFyberEvent(JWFyberEvent.CURRENCY_ERROR, data));

			default:
			
		}

		#end
	}

	public static function dispatchEvent (event:Event):Bool {
		return dispatcher.dispatchEvent (event);
	}

	public static function addEventListener (type:String, listener:Dynamic):Void {
		dispatcher.addEventListener(type, listener);
	}

	public static function removeEventListener (type:String, listener:Dynamic):Void {
		dispatcher.removeEventListener(type, listener);
	}

	#if android
	private static var jwfyber_start = JNI.createStaticMethod ("com.jamwix.JWFyber", "startFyber", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Z;)V");
	private static var jwfyber_pause_downloads = JNI.createStaticMethod("com.jamwix.JWFyber", "pauseDownloads", "()V");
	private static var jwfyber_resume_downloads = JNI.createStaticMethod("com.jamwix.JWFyber", "resumeDownloads", "()V");
	private static var jwfyber_request_offer = JNI.createStaticMethod("com.jamwix.JWFyber", "requestOffer", "()V");
	private static var jwfyber_request_offer_with_reward = JNI.createStaticMethod(
		"com.jamwix.JWFyber", 
		"requestOfferWithReward",
		"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V");
	private static var jwfyber_show_video_ad = JNI.createStaticMethod("com.jamwix.JWFyber", "showVideoAd", "()V");
	#elseif ios
	private static var jwfyber_start = Lib.load("jwfyber", "jwfyber_start", 4);
	private static var set_event_handle = Lib.load("jwfyber", "jwfyber_set_event_handle", 1);
	private static var jwfyber_pause_downloads = Lib.load("jwfyber", "jwfyber_pause_downloads", 0);
	private static var jwfyber_resume_downloads = Lib.load("jwfyber", "jwfyber_resume_downloads", 0);
	private static var jwfyber_request_offer = Lib.load("jwfyber", "jwfyber_request_offer", 0);
	private static var jwfyber_request_offer_with_reward = Lib.load("jwfyber", "jwfyber_request_offer_with_reward", 2);
	private static var jwfyber_show_video_ad = Lib.load("jwfyber", "jwfyber_show_video_ad", 0);
	#end
	
	
}

#if android

private class FyberHandler 
{
	public function new ()
	{
	}

	public function onOffersAvailable():Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.OFFERS_AVAILABLE));
	}

	public function onOffersNotAvailable():Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.OFFERS_NOT_AVAILABLE));
	}

	public function onOffersError(err:String):Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.VIDEO_ERROR, err));
	}

	public function onCurrencyError(err:String):Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.CURRENCY_ERROR, err));
	}

	public function onCurrencyRecieved(currId:String, currName:String, amount:Float, transId:String):Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.CURRENCY_REWARDED, {
			currId: currId,
			currName: currName,
			amount: amount,
			transId: transId
		}));
	}

	public function onVideoFinished():Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.VIDEO_CLOSE_FINISHED));
	}

	public function onVideoAborted():Void
	{
		JWFyber.dispatchEvent(new JWFyberEvent(JWFyberEvent.VIDEO_CLOSE_ABORTED));
	}
}
#end
