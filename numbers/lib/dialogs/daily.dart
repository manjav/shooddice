            ]));
  }

class Days {
  static const DAY_LEN = 3600000; //86400000;
  static List<Day> list = [];

  static bool collectable = false;
  static int get remaining =>
      (Pref.dayFirst.value + (Pref.dayCount.value + 1) * DAY_LEN) -
      DateTime.now().millisecondsSinceEpoch;

  static init() {
    var dayFirst = Pref.dayFirst.value;
    var dayCount = Pref.dayCount.value;
    var millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
    var diff = millisecondsSinceEpoch - (dayFirst + dayCount * DAY_LEN);
    if (diff > DAY_LEN * 2) {
      Pref.dayFirst.set(millisecondsSinceEpoch - DAY_LEN);
      Pref.dayCount.set(dayCount = 0);
    }
    collectable = (diff < DAY_LEN * 2 && diff > DAY_LEN) || dayCount == 0;
    list.clear();
    for (var i = 0; i < 90; i++) {
      list.add(Day(
          i,
          i < dayCount
              ? DayState.collected
              : (i == dayCount && collectable
                  ? DayState.collectable
                  : DayState.waiting)));
    }
  }
}

enum DayState { waiting, collectable, collected }

class Day {
  final int index;
  DayState state;
  Day(this.index, this.state);
  int get reward => 50 * (index + 1);
  String get text => "day_l".l([index + 1]);
}
