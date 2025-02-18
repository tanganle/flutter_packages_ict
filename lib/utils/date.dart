extension DateUtils on DateTime {
  //是否为今天
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  //是否为明天
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == day &&
        tomorrow.month == month &&
        tomorrow.year == year;
  }

  //是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return isAfter(weekStart.subtract(const Duration(days: 1))) &&
        isBefore(weekEnd.add(const Duration(days: 1)));
  }

  bool isThisMonth() {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  //是否为昨天以前
}
