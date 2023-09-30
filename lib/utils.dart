import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:intl/intl.dart';

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

String convertTimettampToStringDot(DateTime date) {
  final dateString =
      "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  return dateString;
}

double calculateMaxContentHeight(String description, double diaryWidth) {
  double maxHeight = 0;
  final textPainter = TextPainter(
    text: TextSpan(
      text: description,
      style: const TextStyle(
        fontSize: Sizes.size13,
      ),
    ),
    maxLines: null,
    // textDirection: TextDirection.ltr,
  )..layout(maxWidth: diaryWidth);
  double height = textPainter.height;
  if (height > maxHeight) {
    maxHeight = height;
  }
  return maxHeight;
}

String numberDecimalCommans(int number) {
  String formattedNumber = NumberFormat('#,##0').format(number);
  return formattedNumber;
}

class StartEndDate {
  final DateTime startDate;
  final DateTime endDate;

  StartEndDate({
    required this.startDate,
    required this.endDate,
  });
}

class WeekMonthDay {
  final StartEndDate thisWeek;
  final StartEndDate lastMonth;
  final StartEndDate thisMonth;

  WeekMonthDay({
    required this.thisWeek,
    required this.lastMonth,
    required this.thisMonth,
  });
}

WeekMonthDay getWeekMonthDay() {
  DateTime currentDate = DateTime.now();
  int currentWeekDay = currentDate.weekday;

  DateTime startOfThisWeek1 =
      currentDate.subtract(Duration(days: currentWeekDay - 1));
  DateTime startOfThisWeek2 = DateTime(startOfThisWeek1.year,
      startOfThisWeek1.month, startOfThisWeek1.day, 0, 0, 0);

  StartEndDate thisWeek =
      StartEndDate(startDate: startOfThisWeek2, endDate: DateTime.now());

  DateTime startDateOfLastMonth =
      DateTime(currentDate.year, currentDate.month - 1, 1, 0, 0, 0);
  DateTime endDateOfLastMonth =
      DateTime(currentDate.year, currentDate.month, 0, 23, 59, 59);
  StartEndDate lastMonth = StartEndDate(
      startDate: startDateOfLastMonth, endDate: endDateOfLastMonth);

  DateTime startDateOfThisMonth =
      DateTime(currentDate.year, currentDate.month, 1, 0, 0, 0);
  StartEndDate thisMonth =
      StartEndDate(startDate: startDateOfThisMonth, endDate: DateTime.now());

  return WeekMonthDay(
      thisWeek: thisWeek, lastMonth: lastMonth, thisMonth: thisMonth);
}

DateTime dateStringToDateTimeDot(String dateString) {
  return DateTime.parse(dateString.replaceAll('.', '-'));
}
