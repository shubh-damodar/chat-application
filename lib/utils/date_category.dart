import 'package:intl/intl.dart';

class DateCategory {
  DateFormat ddMMyyyyDateFormat = DateFormat('dd/MM/yyyy'),
      hmaDateFormat = DateFormat('h:m a'),
      ddMMyyyyhhmmDateFormat = DateFormat('dd/MM/yyyy H:mm'),
      dMMMyyhma = DateFormat('d MMM yy h:m a');
  DateTime _currentDateTime = DateTime.now();

  String sentDate(DateTime messageDateTime) {
    return (_currentDateTime.year == messageDateTime.year &&
            _currentDateTime.month == messageDateTime.month)
        ? (_currentDateTime.day == messageDateTime.day)
            ? dMMMyyhma.format(messageDateTime)
            : (_currentDateTime.day - messageDateTime.day == 1)
                ? 'Yesterday'
                : (_currentDateTime.day - messageDateTime.day < 9)
                    ? '${_currentDateTime.day - messageDateTime.day} days ago'
                    : dMMMyyhma.format(messageDateTime).toString()
        : dMMMyyhma.format(messageDateTime).toString();
  }
}
