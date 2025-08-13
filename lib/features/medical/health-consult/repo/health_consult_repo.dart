import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthConsultRepo {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllHealthConsults() async {
    final docs = await _supabase
        .from("health_consult_inquiries")
        .select(
            '*, users(avatar, name, birthYear, birthDay, gender, phone, fcmToken), health_consult_inquiry_images(*), health_consult_responses(*)')
        .order('createdAt', ascending: false);
    return docs;
  }

  Future<void> insertHealthConsultResponse(Map<String, dynamic> json) async {
    await _supabase.from("health_consult_responses").upsert(json);
  }
}

final healthConsultRepo = Provider((ref) => HealthConsultRepo());
