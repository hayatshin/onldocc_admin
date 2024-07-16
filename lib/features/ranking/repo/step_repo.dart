import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StepRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserCertinDateStepData(
      String userId, DateTime startDate, DateTime endDate) async {
    List<DateTime> dateList = getBetweenDays(startDate, endDate);
    List<Map<String, dynamic>> stepList = [];

    await Future.forEach(dateList, (DateTime date) async {
      final dateString = convertTimettampToStringDate(date);

      final query = await _supabase
          .from("steps")
          .select('*')
          .eq('userId', userId)
          .eq('date', dateString);

      if (query.isNotEmpty) {
        stepList.add(query[0]);
      }
    });

    return stepList;
  }
}

final stepRepo = Provider((ref) => StepRepository());
