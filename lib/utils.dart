import 'dart:convert';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

String encodeDateRange(DateRange dateRange) {
  final startDate = dateRange.start.toIso8601String();
  final endDate = dateRange.end.toIso8601String();
  return '$startDate,$endDate';
}

DateTime convertSecondsToDateTime(int seconds) {
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
}

String encodeSeconds(String startSeconds, String endSeconds) {
  final startSecondsInt = int.parse(startSeconds);
  final endSecondsInt = int.parse(endSeconds);
  final startDate = convertSecondsToDateTime(startSecondsInt).toIso8601String();
  final endDate = convertSecondsToDateTime(endSecondsInt).toIso8601String();
  return '$startDate,$endDate';
}

DateRange decodeDateRange(String encodedDateRange) {
  final dates = encodedDateRange.split(',');
  final startDate = DateTime.parse(dates[0]);
  final endDate = DateTime.parse(dates[1]);
  return DateRange(startDate, endDate);
}

// 엑셀
void exportExcel(
  List<List<String>> contents,
  String fileName,
) {
  Excel excel = Excel.createExcel();
  Sheet sheetObject = excel["Sheet1"];

  for (int row = 0; row < contents.length; row++) {
    List<String> eachRow = contents[row];
    for (int col = 0; col < eachRow.length; col++) {
      var cell = sheetObject.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
      cell.value = TextCellValue(eachRow[col]);
    }
  }
  excel.save(fileName: fileName);
}

Widget deleteOverlay(
    String title, Function() removeOverlay, Function() delete) {
  return Positioned.fill(
    child: Material(
      color: Colors.black38,
      child: Center(
        child: AlertDialog(
          title: Text(
            title,
            style: InjicareFont().headline03.copyWith(
                  color: Palette().darkPurple,
                ),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "정말로 삭제하시겠습니까?",
                style: InjicareFont().label03,
              ),
              Text(
                "삭제하면 다시 되돌릴 수 없습니다.",
                style: InjicareFont().label03,
              ),
            ],
          ),
          actions: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: removeOverlay,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      width: 1.5,
                      color: Palette().darkPurple,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "취소",
                      style: InjicareFont().body07,
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: delete,
                child: Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Palette().darkPurple,
                  ),
                  child: Center(
                    child: Text(
                      "삭제",
                      style: InjicareFont().body07.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

InputDecoration eventSettingInputDecorationStyle() {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white.withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
    ),
    hintStyle: contentTextStyle.copyWith(
      color: InjicareColor().gray50,
    ),
    errorStyle: const TextStyle(
      color: Colors.red,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: const BorderSide(
        width: 1.5,
        color: Colors.red,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Palette().darkBlue.withOpacity(0.5),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Palette().darkBlue.withOpacity(0.5),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Sizes.size20,
      vertical: Sizes.size20,
    ),
  );
}

InputDecoration inputDecorationStyle() {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white.withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
    ),
    errorStyle: headerTextStyle.copyWith(
      color: Colors.red,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: const BorderSide(
        width: 1.5,
        color: Colors.red,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: const BorderSide(
        width: 1.5,
        color: Colors.red,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: const BorderSide(
        width: 1.5,
        color: Colors.red,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Palette().darkGray.withOpacity(0.5),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Sizes.size20,
      ),
      borderSide: BorderSide(
        width: 1.5,
        color: Palette().darkGray.withOpacity(0.5),
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Sizes.size20,
      vertical: Sizes.size20,
    ),
  );
}

void showCompletingSnackBar(BuildContext context, String error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      duration: const Duration(
        milliseconds: 1500,
      ),
      content: Container(
        decoration: BoxDecoration(
          color: InjicareColor().gray100.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/circle-check.svg",
                width: 20,
              ),
              Gaps.h10,
              Flexible(
                child: SelectableText(
                  error,
                  style: const TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  // overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showWarningSnackBar(BuildContext context, String error) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      duration: const Duration(
        milliseconds: 1500,
      ),
      content: Container(
        decoration: BoxDecoration(
          color: InjicareColor().gray100.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/warning.svg",
                width: 20,
              ),
              Gaps.h10,
              Flexible(
                child: SelectableText(
                  error,
                  style: const TextStyle(
                    fontSize: Sizes.size14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  // overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
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
  try {
    late int returnAge;
    final int currentYear = DateTime.now().year;
    final initialAge = currentYear - int.parse(birthYear);
    returnAge = isDatePassed(birthDay) ? initialAge : initialAge - 1;
    return returnAge.toString();
  } catch (e) {
    // ignore: avoid_print
    print("userAgeCalculation: error -> $e");
    return "0";
  }
}

String userAgeGroupCalculation(String birthYear, String birthDay) {
  try {
    String returnAgeGroup = "";
    final int currentYear = DateTime.now().year;
    final initialAge = currentYear - int.parse(birthYear);
    int returnAge = isDatePassed(birthDay) ? initialAge : initialAge - 1;
    switch (returnAge) {
      case < 40:
        returnAgeGroup = "40대 미만";
        break;
      case >= 40 && < 50:
        returnAgeGroup = "40대";
        break;
      case >= 50 && < 60:
        returnAgeGroup = "50대";
        break;
      case >= 60 && < 70:
        returnAgeGroup = "60대";
        break;
      case >= 70 && < 80:
        returnAgeGroup = "70대";
        break;
      case >= 80 && < 90:
        returnAgeGroup = "80대";
        break;
      case >= 90:
        returnAgeGroup = "90대 이상";
        break;
    }
    return returnAgeGroup;
  } catch (e) {
    // ignore: avoid_print
    print("userAgeGroupCalculation: error -> $e");
    return "40대";
  }
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

String todayToStringDot() {
  DateTime dateTime = DateTime.now();
  return DateFormat('yyyy.MM.dd').format(dateTime);
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

String dateTimeToStringDateLine(DateTime dateTime) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
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

String numberDecimalCommans(int number) {
  String formattedNumber = NumberFormat('#,##0').format(number);
  return formattedNumber;
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

  String diaryHour = dateTime.hour == 24 || dateTime.hour == 0
      ? "오전 12시"
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
      List<String> aSegments = a.split('-imageOrder-');
      List<String> bSegments = b.split('-imageOrder-');

      int aValue = int.parse(aSegments.last);
      int bValue = int.parse(bSegments.last);

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
    List<String> dateParts = startDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);
    final dateTime = DateTime(year, month, day, 0, 0, 0);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return DateTime(2023).millisecondsSinceEpoch ~/ 1000;
  }
}

int convertEndDateStringToSeconds(String endDate) {
  if (endDate.contains('.')) {
    List<String> dateParts = endDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);
    final dateTime = DateTime(year, month, day, 23, 59, 59);
    int seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    return seconds;
  } else {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }
}

DateTime convertStartDateStringToDateTime(String startDate) {
  if (startDate.contains('.')) {
    List<String> dateParts = startDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    return DateTime(year, month, day, 0, 0, 0);
  } else {
    return DateTime(2024);
  }
}

DateTime convertEndDateStringToDateTime(String endDate) {
  if (endDate.contains('.')) {
    List<String> dateParts = endDate.split('.');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    return DateTime(year, month, day, 23, 59, 59);
  } else {
    return DateTime(2024);
  }
}

int convertDateTimeToSeconds(DateTime date) {
  int millisecondsSinceEpoch = date.millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

int convertStartDateTimeToSeconds(DateTime date) {
  final startDate = DateTime(date.year, date.month, date.day, 0, 0, 0);
  int millisecondsSinceEpoch = startDate.millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

int convertEndDateTimeToSeconds(DateTime date) {
  final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

  int millisecondsSinceEpoch = endDate.millisecondsSinceEpoch;
  return (millisecondsSinceEpoch / 1000).round();
}

String periodDateFormat(DateTime dateTime) {
  final formattedDate = DateFormat('yyyy/MM/dd').format(dateTime);
  return formattedDate;
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

void resultBottomModal(
    BuildContext context, String text, Function() refreshScreen) {
  showCompletingSnackBar(context, text);
  Future.delayed(const Duration(milliseconds: 500), () {
    refreshScreen();
    Navigator.of(context).pop();
  });
}

Widget noAuthorizedWidget() {
  return SelectableText(
    "권한\n없음",
    style: TextStyle(
      color: Colors.grey.shade400,
      fontSize: Sizes.size12,
    ),
    textAlign: TextAlign.center,
  );
}

String encodingType() {
  String platform = html.window.navigator.platform!.toLowerCase();
  String encodingType = platform.contains("win") ? "EUC-KR" : "utf-8";
  return encodingType;
}

void downloadCsv(String csvContent, String fileName) {
  // String platform = html.window.navigator.platform!.toLowerCase();
  final bytes = utf8.encode(csvContent);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<XFile?> fetchVideoUrlThumbnail(String videoUrl) async {
  try {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    return fileName;
  } catch (e) {
    // ignore: avoid_print
    print("fetchVideoUrlThumbnail -> $e");
  }
  return null;
}

List<String> iteratePreviousDays(int days) {
  List<String> dates = [];
  DateTime currentDate = DateTime.now();
  for (int i = 0; i < days; i++) {
    DateTime previousDate = currentDate.subtract(Duration(days: i));
    String formattedDate = DateFormat('yyyy-MM-dd').format(previousDate);
    dates.add(formattedDate);
  }
  return dates.reversed.toList();
}

String secondsToYearMonthDayHourMinute(int seconds) {
  final milliseconds = seconds * 1000;
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

  String diaryHour = dateTime.hour == 24 || dateTime.hour == 0
      ? "오전 12시"
      : dateTime.hour > 12
          ? "오후 ${dateTime.hour - 12}시"
          : "오전 ${dateTime.hour}시";

  String formattedDate =
      '${dateTime.year.toString().substring(2)}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} $diaryHour ${dateTime.minute}분';
  return formattedDate;
}
