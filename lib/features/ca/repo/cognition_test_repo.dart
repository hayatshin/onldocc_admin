import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CognitionTestRepository {
  final _supabase = Supabase.instance.client;
  String? lastTestId;
  final int offset = 20;

  Future<List<Map<String, dynamic>>> getTestData(
      String testType, AdminProfileModel adminProfileModel) async {
    if (adminProfileModel.master) {
      final query = await _supabase
          .from("cognition_test")
          .select('*, users!inner(*)')
          .eq('testType', testType)
          .order(
            'createdAt',
            ascending: false,
          );

      return query;
    } else {
      final query = await _supabase
          .from("cognition_test")
          .select('*, users!inner(*)')
          .eq('users.subdistrictId', adminProfileModel.subdistrictId)
          .eq('testType', testType)
          .order(
            'createdAt',
            ascending: false,
          );

      return query;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTestData(
    String testType,
    String userId,
    int startSeconds,
    int endSeconds,
  ) async {
    final query = await _supabase
        .from("cognition_test")
        .select('*, users!inner(*)')
        .eq('testType', testType)
        .eq('userId', userId)
        .gte("createdAt", startSeconds)
        .lte("createdAt", endSeconds)
        .order(
          'createdAt',
          ascending: false,
        );

    return query;
  }
}
