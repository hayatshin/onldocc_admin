import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CognitionTestRepository {
  final _supabase = Supabase.instance.client;

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
}
