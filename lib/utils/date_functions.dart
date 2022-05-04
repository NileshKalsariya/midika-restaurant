import 'package:intl/intl.dart';

class DateFunctions {
  static String getFormattedDate(String dateTime) {
    final template = DateFormat('dd, MMMM yyyy - hh:mm a');
    return template
        .format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateTime)!));
  }

  static String getFormattedInMMDDYY(String dateTime) {
    final template = DateFormat('hh:mm a MM/dd/yy');
    return template
        .format(DateTime.fromMillisecondsSinceEpoch(int.tryParse(dateTime)!));
  }
}
