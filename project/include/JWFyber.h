#ifndef JWFYBER_H
#define JWFYBER_H


namespace jwfyber {
	
    extern "C"
    {
        void jwfStart(const char *sAppId, const char *sUserId, const char *sToken, bool useToast);
        void jwfLaunchOfferWall();
        void jwfPauseDownloads();
        void jwfResumeDownloads();
        void jwfRequestOffer();
        void jwfRequestOfferWithReward(const char *sRewardType, const char *sPlacement);
        void jwfShowVideoAd();
    }
	
}


#endif
