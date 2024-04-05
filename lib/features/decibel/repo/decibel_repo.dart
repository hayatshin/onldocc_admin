import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DecibelRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchUserDecibels(
      String userSubdistrictId) async {
    if (userSubdistrictId == "") {
      final data = _supabase
          .from("decibels")
          .select('*, users!inner(*)')
          .order('createdAt', ascending: true);
      return data;
    } else {
      final data = _supabase
          .from("decibels")
          .select('*, users!inner(*)')
          .eq('users.subdistrictId', userSubdistrictId)
          .order('createdAt', ascending: true);
      return data;
    }
  }
}

final decibelRepo = Provider((ref) => DecibelRepository());
