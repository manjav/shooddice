import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numbers/utils/analytic.dart';
import 'package:numbers/utils/prefs.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class Ads {
  static Map<AdPlace, AdState> _placements = {
    AdPlace.Interstitial: AdState.Closed,
    AdPlace.Rewarded: AdState.Closed
  };

  static Function(AdPlace, AdState)? onUpdate;
  static String platform = Platform.isAndroid ? "Android" : "iOS";
  static final isSupportAdMob = true;
  static final isSupportUnity = false;

  static final AdRequest _request = AdRequest(nonPersonalizedAds: false);
  static Map<String, BannerAd> _banners = Map();
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static RewardItem? reward;

  static var prefix = "ca-app-pub-5018637481206902/";

  static int maxFailedLoadAttempts = 3;
  static int _attemptsLoadForInterstitial = 0;
  static int _attemptsLoadForRewarded = 0;

  static init() async {
    if (isSupportAdMob) {
      MobileAds.instance.initialize();
      _getInterstitial();
      _getRewarded();
    }

    if (isSupportUnity) {
      UnityAds.init(
          gameId: "4230791",
          listener: (UnityAdState state, data) {
            AdPlace adPlace = _getPlacement(data['placementId']);
            if (state == UnityAdState.ready) {
              Analytics.ad(
                  GAAdAction.Loaded, adPlace.type, adPlace.name, "unityads");
              _updateState(adPlace, AdState.Loaded);
            } else if (state == UnityAdState.complete ||
                state == UnityAdState.skipped) {
              Analytics.ad(GAAdAction.RewardReceived, adPlace.type,
                  adPlace.name, "unityads");
              _updateState(adPlace, AdState.Closed);
            }
            debugPrint("Ads ==> state: $state, $data");
          });
    }

    for (var id in AdPlace.values) {
      var ready = await UnityAds.isReady(placementId: id.name);
      if (ready ?? false) _placements[id] = AdState.Loaded;
    }
  }

  static BannerAd getBanner(String type, {AdSize? size}) {
    var place = AdPlace.Banner;
    if (_banners.containsKey(type)) return _banners[type]!;
    var _listener = BannerAdListener(
        onAdLoaded: (ad) => _updateState(place, AdState.Loaded, ad),
        onAdFailedToLoad: (ad, error) {
          _updateState(place, AdState.FailedLoad, ad, error);
          ad.dispose();
        },
        onAdOpened: (ad) => _updateState(place, AdState.Clicked, ad),
        onAdClosed: (ad) => _updateState(place, AdState.Closed, ad),
        onAdImpression: (ad) => _updateState(place, AdState.Show, ad));
    _updateState(place, AdState.Request);
    return _banners[type] = BannerAd(
        size: size ?? AdSize.largeBanner,
        adUnitId: place.id,
        listener: _listener,
        request: _request)
      ..load();
  }

  static void _getInterstitial() {
    var place = AdPlace.Interstitial;
    InterstitialAd.load(
        adUnitId: place.id,
        request: _request,
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          _updateState(place, AdState.Loaded, ad);
          _interstitialAd = ad;
          _attemptsLoadForInterstitial = 0;
          _interstitialAd!.setImmersiveMode(true);
        }, onAdFailedToLoad: (LoadAdError error) {
          _updateState(place, AdState.FailedLoad, null, error);
          ++_attemptsLoadForInterstitial;
          _interstitialAd = null;
          if (_attemptsLoadForInterstitial <= maxFailedLoadAttempts)
            _getInterstitial();
        }));
  }

  static void _getRewarded() {
    var place = AdPlace.Rewarded;
    RewardedAd.load(
        adUnitId: place.id,
        request: _request,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _attemptsLoadForRewarded = 0;
          _updateState(place, AdState.Loaded, ad);
        }, onAdFailedToLoad: (LoadAdError error) {
          _updateState(place, AdState.FailedLoad, null, error);
          _rewardedAd = null;
          ++_attemptsLoadForRewarded;
          if (_attemptsLoadForRewarded <= maxFailedLoadAttempts) _getRewarded();
        }));
  }

  static bool isReady([AdPlace? id]) {
    var _id = id ?? AdPlace.Rewarded;
    if (_id != AdPlace.Rewarded) {
      if (Pref.playCount.value < _id.threshold) return false;
      if (Pref.noAds.value > 0) return false;
    }
    return _placements.containsKey(_id) && _placements[_id] == AdState.Loaded;
  }

  static showInterstitial() async {
    if (Pref.noAds.value > 0) return;
    if (_interstitialAd == null) {
      debugPrint("Ads ==> attempt to show interstitial before loaded.");
      return;
    }
    var place = AdPlace.Interstitial;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          _updateState(place, AdState.Closed, ad);
          ad.dispose();
          _getInterstitial();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          _updateState(place, AdState.FailedShow, ad, error);
          ad.dispose();
          _getInterstitial();
        },
        onAdImpression: (ad) => _updateState(place, AdState.Show, ad));
    _interstitialAd!.show();
    _interstitialAd = null;
    await _waitForClose(AdPlace.Interstitial);
  }

  static Future<RewardItem?> showRewarded() async {
    reward = null;
    if (_rewardedAd == null) {
      debugPrint('Ads ==> attempt to show rewarded before loaded.');
      return null;
    }
    var place = AdPlace.Rewarded;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          _updateState(place, AdState.Closed, ad);
          ad.dispose();
          _getRewarded();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          _updateState(place, AdState.FailedShow, ad, error);
          ad.dispose();
          _getRewarded();
        },
        onAdImpression: (ad) => _updateState(place, AdState.Show, ad));
    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
      reward = rewardItem;
      return _updateState(place, AdState.RewardReceived, ad);
    });
    await _waitForClose(AdPlace.Rewarded);
    _rewardedAd = null;
    return reward;
  }

  /* static Future<bool> _show([AdPlace? id]) async {
    var placement = id ?? AdPlace.Rewarded;
    if (placement.type == GAAdType.Interstitial && Pref.noAds.value > 0)
      return true; // No ads mode
    if (!isReady(placement)) {
      debugPrint("ads ${placement.name} is not ready.");
      Analytics.ad(GAAdAction.FailedShow, placement.type, placement.name);
      return false;
    }
    Analytics.ad(GAAdAction.Show, placement.type,
        placement.name); // where is this from?????
    _lastAdState = UnityAdState.started;
    _placementIds.remove(placement.name);
    UnityAds.showVideoAd(placementId: placement.name);
    const d = Duration(milliseconds: 500);
    while (_lastAdState == UnityAdState.started) await Future.delayed(d);
    return _lastAdState == UnityAdState.complete;
  } */

  static AdPlace _getPlacement(String id) {
    if (id.contains("Banner")) return AdPlace.Banner;
    if (id.contains("Interstitial")) return AdPlace.Interstitial;
    return AdPlace.Rewarded;
  }

  static void _updateState(AdPlace place, AdState state,
      [Ad? ad, AdError? error]) {
    _placements[place] = state;
    onUpdate?.call(place, state);
    print("Ads ==> ${state.order}");
    if (state.order > 0)
      Analytics.ad(state.order, place.type, place.name, "admob");
    debugPrint("Ads ==> $place ${state.toString()} ${error ?? ''}");
  }

  static _waitForClose(AdPlace adPlace) async {
    const d = Duration(milliseconds: 300);
    while (_placements[adPlace] != AdState.Closed) await Future.delayed(d);
  }

  static void pausedApp() {
    _placements.forEach((key, value) {
      if (key != AdPlace.Banner &&
          (value == AdState.Show || value == AdState.RewardReceived))
        _updateState(key, AdState.Clicked);
    });
  }
}

enum AdState {
  Closed,
  Clicked,
  Show,
  FailedShow,
  RewardReceived,
  Request,
  Loaded,
  FailedLoad
}

extension AdExt on AdState {
  int get order {
    if (this == AdState.FailedLoad) return -1;
    return index;
  }
}

enum AdPlace { Rewarded, Interstitial, Banner }

extension AdPlaceExt on AdPlace {
  String get name {
    switch (this) {
      case AdPlace.Banner:
        return "Banner_${Ads.platform}";
      case AdPlace.Interstitial:
        return "Interstitial_${Ads.platform}";
      case AdPlace.Rewarded:
        return "Rewarded_${Ads.platform}";
    }
  }

  String get id {
    switch (this) {
      case AdPlace.Banner:
        return "${Ads.prefix}9761457956";
      case AdPlace.Interstitial:
        return "${Ads.prefix}4317559580";
      case AdPlace.Rewarded:
        return "${Ads.prefix}2812906224";
    }
  }

  int get type {
    switch (this) {
      case AdPlace.Rewarded:
        return GAAdType.RewardedVideo;
      case AdPlace.Interstitial:
        return GAAdType.Interstitial;
      case AdPlace.Banner:
        return GAAdType.Banner;
    }
  }

  int get threshold {
    if (this == AdPlace.Interstitial) return 7;
    if (this == AdPlace.Banner) return 10;
    return 0;
  }
}
