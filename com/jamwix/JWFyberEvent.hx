package com.jamwix;

import openfl.events.Event;

class JWFyberEvent extends Event 
{
	public static inline var VIDEO_CLOSE_FINISHED = "VIDEO_CLOSE_FINISHED"; 
	public static inline var VIDEO_CLOSE_ABORTED = "VIDEO_CLOSE_ABORTED";
	public static inline var VIDEO_STARTED = "VIDEO_STARTED";
	public static inline var VIDEO_ERROR = "VIDEO_ERROR";
	public static inline var OFFERS_AVAILABLE = "OFFERS_AVAILABLE";
	public static inline var OFFERS_NOT_AVAILABLE = "OFFERS_NOT_AVAILABLE";
	public static inline var CURRENCY_REWARDED = "CURRENCY_REWARDED";
	public static inline var CURRENCY_ERROR = "CURRENCY_ERROR";
	public static inline var ERROR = "ERROR";
	public static inline var OPENED = "OPENED";
	public static inline var PUBLISH_ALLOWED = "PUBLISH_ALLOWED";
	public static inline var PUBLISH_DENIED = "PUBLISH_DENIED";
	public static inline var GRAPH_SUCCESS = "GRAPH_SUCCESS";
	public static inline var GRAPH_ERROR = "GRAPH_ERROR";
	
	public var data:String;

	public function new (type:String, data:String = null) 
	{
		super(type);
		
		this.data = data;
	}
}
