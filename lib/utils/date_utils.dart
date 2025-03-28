import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date to readable string
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d, y').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Format time to readable string
  static String formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return timeString;
    }
  }

  // Format date and time to readable string
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('EEEE, MMMM d, y h:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  // Get day of week from date
  static String getDayOfWeek(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get short day of week from date
  static String getShortDayOfWeek(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('E').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get month name from date
  static String getMonthName(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get short month name from date
  static String getShortMonthName(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get day of month from date
  static String getDayOfMonth(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get hour from time
  static int getHour(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return time.hour;
    } catch (e) {
      return 0;
    }
  }

  // Check if date is today
  static bool isToday(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year && date.month == today.month && date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  // Check if date is tomorrow
  static bool isTomorrow(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
    } catch (e) {
      return false;
    }
  }

  // Get relative time (e.g. "2 hours ago")
  static String getRelativeTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else {
        return formatDate(dateTimeString);
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}
