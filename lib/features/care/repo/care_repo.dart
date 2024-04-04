import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final careRepo = Provider((ref) => CareRepository());
