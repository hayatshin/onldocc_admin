import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CareRepository {
  final _supabase = Supabase.instance.client;

  Future<bool> checkUserStepExists(String userId, List<String> dates) async {
    try {
      final certainStep = await _supabase
          .from("steps")
          .select('step')
          .eq('userId', userId)
          .inFilter('date', dates);
      return certainStep.isNotEmpty;
    } catch (e) {
      //ignore: avoid_print
      print("checkUserStepExists -> $e");
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> fetchPartners(
      AdminProfileModel adminProfileModel) async {
    if (adminProfileModel.master) {
      final query = await _supabase
          .from("partners")
          .select('*, users!public_partners_partnerUserId_fkey(*)')
          .order(
            'createdAt',
            ascending: false,
            nullsFirst: false,
          );

      return query;
    } else {
      final partners = await _supabase.from("partners").select('''
      *,
      users:partnerUserId(*),
      sender:userId("subdistrictId")
    ''');

      final results = partners
          .where((e) =>
              e["sender"]["subdistrictId"] == adminProfileModel.subdistrictId)
          .toList();
      return results;
      // final query = await _supabase
      //     .from("partners")
      //     .select('*, users!inner(subdistrictId), users:partnerUserId(*)')
      //     .eq('users.subdistrictId', adminProfileModel.subdistrictId)
      //     .order(
      //       'createdAt',
      //       ascending: false,
      //       nullsFirst: false,
      //     );
    }
  }
}

final careRepo = Provider((ref) => CareRepository());
