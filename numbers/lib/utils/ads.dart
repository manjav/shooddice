import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads.dart';

class Ads {
  static LinkedHashSet<String> _placementIds = new LinkedHashSet();

  static UnityAdState? _lastAdState;
  static init() async {
    UnityAds.init(
        gameId: "3974257",
        listener: (UnityAdState state, data) {
          if (state == UnityAdState.ready)
            _placementIds.add(data['placementId']);
          else if (state == UnityAdState.complete ||
              state == UnityAdState.skipped) _lastAdState = state;
          debugPrint("Ads state =================>> $state : $data");
        });

    var _ids = [
      "rewardedVideo",
      "powerups",
      "revive",
      "prize",
      "boostbig",
      "boostnext"
    ];
    for (var id in _ids) {
      var ready = await UnityAds.isReady(placementId: id);
      if (ready ?? false) _placementIds.add(id);
    }
  }

  static bool isReady(String placementId) =>
      _placementIds.contains(placementId);

  static Future<bool> show(String placementId) async {
    if (!isReady(placementId)) {
      debugPrint("ads $placementId is not ready.");
      return false;
    }
    _lastAdState = UnityAdState.started;
    _placementIds.remove(placementId);
    UnityAds.showVideoAd(placementId: placementId);
    const d = Duration(milliseconds: 500);
    while (_lastAdState == UnityAdState.started) await Future.delayed(d);
    return _lastAdState == UnityAdState.complete;
  }
}
