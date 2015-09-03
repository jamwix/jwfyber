#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "JWFyber.h"


using namespace jwfyber;


AutoGCRoot* fyber_event_handle = 0;

static value jwfyber_set_event_handle(value onEvent)
{
	fyber_event_handle = new AutoGCRoot(onEvent);
	return alloc_null();
}
DEFINE_PRIM(jwfyber_set_event_handle, 1);

static value jwfyber_start (value appId, value userId, value token) {
    jwfStart(val_string(appId), val_string(userId), val_string(token));
	return alloc_null();
}
DEFINE_PRIM (jwfyber_start, 3);

static value jwfyber_pause_downloads () {
    jwfPauseDownloads();
	return alloc_null();
}
DEFINE_PRIM (jwfyber_pause_downloads, 0);

static value jwfyber_resume_downloads () {
    jwfResumeDownloads();
	return alloc_null();
}
DEFINE_PRIM (jwfyber_resume_downloads, 0);

static value jwfyber_request_offer () {
    jwfRequestOffer();
	return alloc_null();
}
DEFINE_PRIM (jwfyber_request_offer, 0);

static value jwfyber_request_offer_with_reward (value rewardType, value placementId) {
    jwfRequestOfferWithReward(val_string(rewardType), val_string(placementId));
	return alloc_null();
}
DEFINE_PRIM (jwfyber_request_offer_with_reward, 2);

static value jwfyber_show_video_ad () {
    jwfShowVideoAd();
	return alloc_null();
}
DEFINE_PRIM (jwfyber_show_video_ad, 0);


extern "C" void jwfyber_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (jwfyber_main);



extern "C" int jwfyber_register_prims () { return 0; }
