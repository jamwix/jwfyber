#ifndef JWFYBER_H
#define JWFYBER_H


namespace jwfyber {
	
    void jwfStart(const char *sAppId, const char *sUserId, const char *sToken);
    void jwfLaunchOfferWall();
    void jwfPauseDownloads();
    void jwfResumeDownloads();
    void jwfRequestOffer();
    void jwfRequestOfferWithReward(const char *sRewardType, const char *sPlacement);
    void jwfShowVideoAd();
	
}


#endif
