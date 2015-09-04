#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import "SponsorPaySDK.h"
#include "JWFyber.h"

extern "C" void send_fyber_event(const char* type, const char* data);

@interface JWFyber:NSObject <SPBrandEngageClientDelegate, SPVirtualCurrencyConnectionDelegate> 
{
    SPBrandEngageClient * _brandEngageClient;
    bool _useToast;
}

- (void)fyberWithId: (NSString*) appId 
             userId: (NSString*) userId
              token: (NSString*) token
           useToast: (bool) useToast;

- (void)pauseDownloads;
- (void)resumeDownloads;
- (void)requestOffer;
- (void)requestOfferWithRewardType:(NSString*)rewardType placementId:(NSString*)placementId;
- (void)showVideoAd;

@end

@implementation JWFyber

- (void)fyberWithId: (NSString*) appId 
             userId: (NSString*) userId
              token: (NSString*) token
           useToast: (bool) useToast
{
    _useToast = useToast;
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    [SponsorPaySDK startForAppId: appId
                          userId: userId
                   securityToken: token];
}

- (void)pauseDownloads
{
    SPCacheManager *cacheManager = [SponsorPaySDK cacheManager];
    [cacheManager pauseDownloads];
}

- (void)resumeDownloads
{
    SPCacheManager *cacheManager = [SponsorPaySDK cacheManager];
    [cacheManager resumeDownloads];
}

- (void)brandEngageClient:(SPBrandEngageClient *)brandEngageClient 
          didChangeStatus:(SPBrandEngageClientStatus)newStatus
{
    switch (newStatus)
    {
        case CLOSE_FINISHED:
        {
            send_fyber_event("VIDEO_CLOSE_FINISHED", "");
        }
        case CLOSE_ABORTED:
        {
            send_fyber_event("VIDEO_CLOSE_ABORTED", "");
        }
        case STARTED:
        {
            send_fyber_event("VIDEO_STARTED", "");
        }
        case ERROR:
        {
            send_fyber_event("VIDEO_ERROR", "");
        }
    }

}

- (void)brandEngageClient:(SPBrandEngageClient *)brandEngageClient didReceiveOffers:(BOOL)areOffersAvailable
{
    if (areOffersAvailable)
    {
        send_fyber_event("OFFERS_AVAILABLE", "");
    }
    else
    {
        send_fyber_event("OFFERS_NOT_AVAILABLE", "");
    }
}

- (void)virtualCurrencyConnector:(SPVirtualCurrencyServerConnector *)connector 
  didReceiveDeltaOfCoinsResponse:(double)deltaOfCoins 
                      currencyId:(NSString*)currencyId 
                    currencyName:(NSString*)currencyName
             latestTransactionId:(NSString*)transactionId
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue: [[NSNumber alloc] initWithDouble:deltaOfCoins] forKey: @"amount"];
    [dict setValue: currencyId forKey: @"currencyId"];
    [dict setValue: currencyName forKey: @"currencyName"];
    [dict setValue: transactionId forKey: @"transactionId"];

    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject: dict
                                                       options: 0
                                                         error: &error];

    if (!jsonData) {
        NSLog(@"Unable to create json data: %@", error);
        send_fyber_event("CURRENCY_ERROR", [error.localizedDescription UTF8String]);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        send_fyber_event("CURRENCY_REWARDED", [jsonString UTF8String]);
    }
}

- (void)virtualCurrencyConnector:(SPVirtualCurrencyServerConnector *)connector 
                 failedWithError:(SPVirtualCurrencyRequestErrorType)error 
                       errorCode:(NSString*)errorCode 
                    errorMessage:(NSString*)errorMessage
{
    send_fyber_event("CURRENCY_ERROR", [errorMessage UTF8String]);
}

- (void)requestOffer
{
    _brandEngageClient = [SponsorPaySDK requestBrandEngageOffersNotifyingDelegate:self];
    [_brandEngageClient setShouldShowRewardNotificationOnEngagementCompleted: _useToast];
}

- (void)requestOfferWithRewardType:(NSString*)rewardType placementId:(NSString*)placementId
{
    [SponsorPaySDK requestBrandEngageOffersNotifyingDelegate: self 
                                                 placementId: placementId
                                      queryVCSWithCurrencyId: rewardType
                                                 vcsDelegate: self];
}

- (void)showVideoAd
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    [_brandEngageClient startWithParentViewController: topController];
}

@end

extern "C"
{

    static JWFyber * myFyber = nil;
    void jwfStart(const char *sAppId, const char *sUserId, const char *sToken, bool useToast)
    {

        if (myFyber == nil)
        {
            myFyber = [[JWFyber alloc] init];
        }

		NSString *appId = [ [NSString alloc] initWithUTF8String: sAppId ];
		NSString *userId = [ [NSString alloc] initWithUTF8String: sUserId ];
		NSString *token = [ [NSString alloc] initWithUTF8String: sToken ];

//        NMEAppDelegate *appDelegate = 
//            (NMEAppDelegate *)[[UIApplication sharedApplication] delegate];
        [myFyber fyberWithId: appId userId: userId token: token useToast: useToast];
    }

    void jwfPauseDownloads()
    {
        [myFyber pauseDownloads];
    }

    void jwfResumeDownloads()
    {
        [myFyber resumeDownloads];
    }

    void jwfRequestOffer()
    {
        [myFyber requestOffer];
    }

    void jwfRequestOfferWithReward(const char *sRewardType, const char *sPlacement)
    {
		NSString *rewardType = [ [NSString alloc] initWithUTF8String: sRewardType ];
		NSString *placementId = [ [NSString alloc] initWithUTF8String: sPlacement ];

        [myFyber requestOfferWithRewardType: rewardType placementId: placementId];
    }

    void jwfShowVideoAd()
    {
        [myFyber showVideoAd];
    }
}
