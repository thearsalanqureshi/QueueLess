import 'package:intl/intl.dart';

String formatWaitMinutes(int minutes) {
  if (minutes <= 0) {
    return 'Now';
  }
  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (remainingMinutes == 0) {
    return '$hours hr';
  }

  return '$hours hr $remainingMinutes min';
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('MMM d, h:mm a').format(dateTime);
}

String peakHourLabel(int hour) {
  return DateFormat('h a').format(DateTime(2026, 1, 1, hour));
}
