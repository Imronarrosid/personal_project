class TimeAgoFormatter {
  // Supported languages
  // ignore: constant_identifier_names
  static const String EN = 'en';
  // ignore: constant_identifier_names
  static const String ID = 'id';

  // Localization maps
  static const Map<String, Map<String, String>> _localizations = {
    EN: {
      'just_now': 'Just now',
      'minute': 'minute',
      'minutes': 'minutes',
      'hour': 'hour',
      'hours': 'hours',
      'day': 'day',
      'days': 'days',
      'week': 'week',
      'weeks': 'weeks',
      'month': 'month',
      'months': 'months',
      'year': 'year',
      'years': 'years',
      'ago': 'ago',
    },
    ID: {
      'just_now': 'Baru saja',
      'minute': 'menit',
      'minutes': 'menit',
      'hour': 'jam',
      'hours': 'jam',
      'day': 'hari',
      'days': 'hari',
      'week': 'minggu',
      'weeks': 'minggu',
      'month': 'bulan',
      'months': 'bulan',
      'year': 'tahun',
      'years': 'tahun',
      'ago': 'yang lalu',
    },
  };

  static String format(DateTime dateTime, {String locale = EN}) {
    // Default to English if the requested locale isn't supported
    if (!_localizations.containsKey(locale)) {
      locale = EN;
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Within the last minute
    if (difference.inSeconds < 60) {
      return _localizations[locale]!['just_now']!;
    }

    // Within the last hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return _formatWithCount(minutes, 'minute', locale);
    }

    // Within the last day
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return _formatWithCount(hours, 'hour', locale);
    }

    // Within the last week
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return _formatWithCount(days, 'day', locale);
    }

    // Within the last month
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return _formatWithCount(weeks, 'week', locale);
    }

    // Within the last year
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return _formatWithCount(months, 'month', locale);
    }

    // More than a year
    final years = (difference.inDays / 365).floor();
    return _formatWithCount(years, 'year', locale);
  }

  // Helper function to format with count and handle pluralization
  static String _formatWithCount(int count, String unit, String locale) {
    final unitKey = count == 1 ? unit : '${unit}s';
    final unitText = _localizations[locale]![unitKey]!;
    final agoText = _localizations[locale]!['ago']!;

    // For Indonesian, there's no need to show the count for some time units as they don't change form
    if (locale == ID &&
        (unit == 'minute' ||
            unit == 'hour' ||
            unit == 'day' ||
            unit == 'week' ||
            unit == 'month' ||
            unit == 'year')) {
      return '$count $unitText $agoText';
    }

    return '$count $unitText $agoText';
  }

  static const Map<String, Map<String, String>> _lastSenLocalizations = {
    EN: {
      'just_now': 'last seen recently',
      'minute_format': 'last seen %d minute ago',
      'minutes_format': 'last seen %d minutes ago',
      'hour_format': 'last seen %d hour ago',
      'hours_format': 'last seen %d hours ago',
      'day_format': 'last seen %d day ago',
      'days_format': 'last seen %d days ago',
      'week_format': 'last seen %d week ago',
      'weeks_format': 'last seen %d weeks ago',
      'month_format': 'last seen %d month ago',
      'months_format': 'last seen %d months ago',
      'year_format': 'last seen %d year ago',
      'years_format': 'last seen %d years ago',
      'yesterday': 'last seen yesterday',
      'today_format': 'last seen today at %s',
    },
    ID: {
      'just_now': 'dilihat baru saja',
      'minute_format': 'dilihat %d menit yang lalu',
      'minutes_format': 'dilihat %d menit yang lalu',
      'hour_format': 'dilihat %d jam yang lalu',
      'hours_format': 'dilihat %d jam yang lalu',
      'day_format': 'dilihat %d hari yang lalu',
      'days_format': 'dilihat %d hari yang lalu',
      'week_format': 'dilihat %d minggu yang lalu',
      'weeks_format': 'dilihat %d minggu yang lalu',
      'month_format': 'dilihat %d bulan yang lalu',
      'months_format': 'dilihat %d bulan yang lalu',
      'year_format': 'dilihat %d tahun yang lalu',
      'years_format': 'dilihat %d tahun yang lalu',
      'yesterday': 'dilihat kemarin',
      'today_format': 'dilihat hari ini pukul %s',
    },
  };

  /// Format a last online time, with optional current time for testing
  static String lastSeenFormat(
    DateTime? lastOnlineTime, {
    String locale = EN,
    DateTime? now,
  }) {
    // Handle null last online time
    if (lastOnlineTime == null) {
      return '';
    }

    // Default to English if the requested locale isn't supported
    if (!_lastSenLocalizations.containsKey(locale)) {
      locale = EN;
    }

    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(lastOnlineTime);

    // Special case for "today at XX:XX"
    final bool isSameDay = currentTime.year == lastOnlineTime.year &&
        currentTime.month == lastOnlineTime.month &&
        currentTime.day == lastOnlineTime.day;

    // Special case for "yesterday"
    final bool isYesterday = currentTime.year == lastOnlineTime.year &&
        currentTime.month == lastOnlineTime.month &&
        currentTime.day == lastOnlineTime.day + 1;

    // Format time as HH:MM
    String formatTimeString(DateTime dt) {
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // Within the last minute
    if (difference.inSeconds < 60) {
      return _lastSenLocalizations[locale]!['just_now']!;
    }

    // Today with time
    if (isSameDay) {
      final timeStr = formatTimeString(lastOnlineTime);
      return _lastSenLocalizations[locale]!['today_format']!.replaceAll('%s', timeStr);
    }

    // Yesterday
    if (isYesterday) {
      return _lastSenLocalizations[locale]!['yesterday']!;
    }

    // Within the last hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      final formatKey = minutes == 1 ? 'minute_format' : 'minutes_format';
      return _lastSenLocalizations[locale]![formatKey]!
          .replaceAll('%d', minutes.toString());
    }

    // Within the last day
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      final formatKey = hours == 1 ? 'hour_format' : 'hours_format';
      return _lastSenLocalizations[locale]![formatKey]!
          .replaceAll('%d', hours.toString());
    }

    // Within the last week
    if (difference.inDays < 7) {
      final days = difference.inDays;
      final formatKey = days == 1 ? 'day_format' : 'days_format';
      return _lastSenLocalizations[locale]![formatKey]!
          .replaceAll('%d', days.toString());
    }

    // Within the last month
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      final formatKey = weeks == 1 ? 'week_format' : 'weeks_format';
      return _lastSenLocalizations[locale]![formatKey]!
          .replaceAll('%d', weeks.toString());
    }

    // Within the last year
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      final formatKey = months == 1 ? 'month_format' : 'months_format';
      return _lastSenLocalizations[locale]![formatKey]!
          .replaceAll('%d', months.toString());
    }

    // More than a year
    final years = (difference.inDays / 365).floor();
    final formatKey = years == 1 ? 'year_format' : 'years_format';
    return _lastSenLocalizations[locale]![formatKey]!
        .replaceAll('%d', years.toString());
  }
}
