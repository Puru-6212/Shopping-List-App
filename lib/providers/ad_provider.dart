
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopping_list/services/ad_helper.dart';

class Adprovider with ChangeNotifier {
  bool isHomePageBannerLoaded = false;  // checks if banner-ad loaded 
  late BannerAd homePageBanner;

  bool isFullPageAdLoaded = false;  //check if Interstitial-ad loaded
  late InterstitialAd fullPageAD;

  void initializeHomePageBanner() async {
    homePageBanner = BannerAd( //BannerAd needs something to store its data 
        size: AdSize.banner,
        adUnitId: AdHelper.homePageBanner(), //accessing the ad-id
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            log("Home pAGE bANNER LOADED"); // displays msg on debug-console
            isHomePageBannerLoaded = true;
          },
          onAdClosed: (ad) {
            ad.dispose();
            isHomePageBannerLoaded = false;
          },
          onAdFailedToLoad: (ad, err) {
            log(err.toString());
            isHomePageBannerLoaded = false;
          },
        ),
        request: AdRequest());

    await homePageBanner.load(); //loads the ad
    notifyListeners(); //notifies the listeners for ad display
  }

  void initializeFulPageAd() async {
    await InterstitialAd.load(  //Interstitial ad can be directly called 
        adUnitId: AdHelper.fullPageAD(), //accessing the ad-id
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            log("Full Page Ad Loaded"); // displays msg on debug-console
            fullPageAD = ad;
            isFullPageAdLoaded = true;
          },
          onAdFailedToLoad: (err) {
            log(err.toString());
            isFullPageAdLoaded = false;
          },
        ));
    notifyListeners(); //notifies the listeners for ad display
  }
}
