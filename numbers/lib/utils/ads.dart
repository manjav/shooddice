import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class Ads {
  static LinkedHashSet<String> _placementIds = new LinkedHashSet();

  static UnityAdState? _lastAdState;

  static String platform = "Android";
  static init() async {
    UnityAds.init(
        gameId: "4230791",
        listener: (UnityAdState state, data) {
          if (state == UnityAdState.ready)
            _placementIds.add(data['placementId']);
          else if (state == UnityAdState.complete ||
              state == UnityAdState.skipped) _lastAdState = state;
          debugPrint("Ads state =================>> $state : $data");
        });

    for (var id in [AdPlace.Rewarded]) {
      var ready = await UnityAds.isReady(placementId: id.name);
      if (ready ?? false) _placementIds.add(id.name);
    }
  }

  static bool isReady([AdPlace? id]) =>
      _placementIds.contains(id == null ? AdPlace.Rewarded.name : id.name);

  static Future<bool> show([AdPlace? id]) async {
    var placementId = id ?? AdPlace.Rewarded;
    if (!isReady(placementId)) {
      debugPrint("ads ${placementId.name} is not ready.");
      return false;
    }
    _lastAdState = UnityAdState.started;
    _placementIds.remove(placementId.name);
    UnityAds.showVideoAd(placementId: placementId.name);
    const d = Duration(milliseconds: 500);
    while (_lastAdState == UnityAdState.started) await Future.delayed(d);
    return _lastAdState == UnityAdState.complete;
  }
}

enum AdPlace { Rewarded, Interstitial, Banner }

extension AdExt on AdPlace {
  String get name {
    switch (this) {
      case AdPlace.Rewarded:
        return "Rewarded_${Ads.platform}";
      case AdPlace.Interstitial:
        return "Interstitial_${Ads.platform}";
      case AdPlace.Banner:
        return "Banner_${Ads.platform}";
    }
  }
}
