import 'package:games_services/games_services.dart';

import 'analytic.dart';

class Games {
  static Future<void> signIn() async {
    await GamesServices.signIn();
  }

  static void submitScore(int score) {
    GamesServices.submitScore(
        score: Score(
            androidLeaderboardID: 'CgkIw9yXzt4XEAIQAQ',
            iOSLeaderboardID: 'ios_leaderboard_id',
            value: score));
  }

  static bool showLeaderboards(String source) {
    Analytics.funnle("rankclicks");
    Analytics.design('guiClick:record:$source');
    GamesServices.showLeaderboards();
    return true;
  }
}
