import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
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

String todayToStringLine() {
  DateTime dateTime = DateTime.now();
  String formattedDate =
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  return formattedDate;
}

String daterangeToSlashString(DateRange range) {
  return "${datetimeToSlashString(range.start)} - ${datetimeToSlashString(range.end)}";
}

String datetimeToSlashString(DateTime date) {
  final dateString =
      "${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  return dateString;
}

String convertTimettampToStringDate(DateTime date) {
  final dateString =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  return dateString;
}

String convertTimettampToStringDateTime(DateTime date) {
  String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(date);
  return formattedDateTime;
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

// supabase -utils

int getCurrentSeconds() {
  int millisecondsSinceEpoch = DateTime.now().millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

String secondsToStringDot(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final f = DateFormat('yyyy.MM.dd');
  return f.format(dateTime);
}

String secondsToStringLine(int seconds) {
  try {
    final milliseconds = seconds * 1000;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    final f = DateFormat('yyyy-MM-dd');
    return f.format(dateTime);
  } catch (e) {
    return "-";
  }
}

DateTime secondsToDatetime(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  return dateTime;
}

String secondsToStringDiaryTimeLine(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String diaryHour = dateTime.hour == 24
      ? "오전 0시"
      : dateTime.hour > 12
          ? "오후 ${dateTime.hour - 12}시"
          : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.month}/${dateTime.day} $diaryHour ${dateTime.minute}분';
  return formattedDate;
}

String secondsToStringDateComment(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String formattedDate =
      '${dateTime.year.toString().substring(2)}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return formattedDate;
}

List<String> spreadDiaryImages(List data) {
  final imagelist = data.map((e) => e["image"] as String).toList();

  if (imagelist.isNotEmpty &&
      !imagelist[0].startsWith("https://firebasestorage")) {
    // supabase storage
    imagelist.sort((a, b) {
      List<String> aSegments = a.split('/');
      List<String> bSegments = b.split('/');

      int aValue = int.parse(aSegments[aSegments.length - 2]);
      int bValue = int.parse(bSegments[bSegments.length - 2]);

      return aValue.compareTo(bValue);
    });
    return imagelist;
  } else {
    // firebase storage
    return imagelist;
  }
}

int convertStartDateStringToSeconds(String startDate) {
  if (startDate.contains('.')) {
    String timeString = "00:00:00.000";
    String combineString = "${startDate.replaceAll('.', '-')} $timeString";
    DateTime dateTime = DateTime.parse(combineString);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return DateTime(2023).millisecondsSinceEpoch ~/ 1000;
  }
}

int convertEndDateStringToSeconds(String endDate) {
  if (endDate.contains('.')) {
    String timeString = "23:59:99.999";
    String combineString = "${endDate.replaceAll('.', '-')} $timeString";
    DateTime dateTime = DateTime.parse(combineString);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}

int convertStartDateTimeToSeconds(DateTime date) {
  final startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
  int millisecondsSinceEpoch = startDate.millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

int convertEndDateTimeToSeconds(DateTime date) {
  final endDate = DateTime(date.year, date.month, date.day, 23, 59, 999);
  int millisecondsSinceEpoch = endDate.millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

DateTime getThisWeekMonday() {
  DateTime now = DateTime.now();
  int difference = now.weekday - 1;
  DateTime thisweekMonday = now.subtract(Duration(days: difference));
  return thisweekMonday;
}

DateTime getLastWeekSunday() {
  DateTime now = DateTime.now();
  int difference = now.weekday - 7;
  DateTime lastweekSunday = now.subtract(Duration(days: difference + 7));
  return lastweekSunday;
}

DateTime getThisMonth1stday() {
  DateTime now = DateTime.now();
  DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
  return firstDateOfMonth;
}

DateTime getLastMonth1stday() {
  DateTime now = DateTime.now();
  DateTime firstDateOfMonth = DateTime(now.year, now.month - 1, 1);
  return firstDateOfMonth;
}

DateTime getLastMonthLastday() {
  DateTime now = DateTime.now();
  DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
  DateTime lastDateOfLastMonth =
      firstDateOfMonth.subtract(const Duration(days: 1));
  return lastDateOfLastMonth;
}
