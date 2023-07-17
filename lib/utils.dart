import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      content: Text(error),
    ),
  );
}

bool isDatePassed(String certainBirthday) {
  late bool passedOrNot;
  final now = DateTime.now();
  final currentMonth = now.month;
  final currentDate = now.day;
  final certainMonth = int.parse(certainBirthday.substring(0, 2));
  final certainDate = int.parse(certainBirthday.substring(2, 4));

  passedOrNot = currentMonth == certainMonth
      ? currentDate > certainDate
      : currentMonth > certainMonth;
  return passedOrNot;
}

String userAgeCalculation(String birthYear, String birthDay) {
  late int returnAge;
  final int currentYear = DateTime.now().year;
  final initialAge = currentYear - int.parse(birthYear);
  returnAge = isDatePassed(birthDay) ? initialAge : initialAge - 1;
  return returnAge.toString();
}

List<DateTime> getBetweenDays(DateTime startDate, DateTime endDate) {
  List<DateTime> dates = [];
  DateTime currentDate = startDate;

  while (
      currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
    dates.add(currentDate);
    currentDate = currentDate.add(const Duration(days: 1));
  }
  return dates;
}

String convertTimettampToString(DateTime date) {
  final dateString =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  return dateString;
}
