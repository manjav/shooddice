import 'package:games_services/games_services.dart';

class GameHub {
  static void submitScore(int score) {
    GamesServices.submitScore(
        score: Score(
            androidLeaderboardID: 'CgkIw9yXzt4XEAIQAQ',
            iOSLeaderboardID: 'ios_leaderboard_id',
            value: score));
  }

}
