import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TvRepository {
  final _supabase = Supabase.instance.client;

  // supabase
  Future<List<Map<String, dynamic>>> getUserTvs(
      AdminProfileModel model, String contractRegionId) async {
    if (model.master && contractRegionId == "") {
      final allUsers = await _supabase
          .from("videos")
          .select('*, contract_regions(*)')
          .eq('allUsers', true)
          .order(
            'createdAt',
            ascending: true,
          );
      return allUsers;
    } else {
      final contractRegions = await _supabase
          .from("videos")
          .select('*, contract_regions(*)')
          .eq('allUsers', false)
          .eq('contractRegionId', contractRegionId)
          .order(
            'createdAt',
            ascending: true,
          );
      return contractRegions;
    }
  }

  Future<void> addTv(TvModel tvModel) async {
    await _supabase.from("videos").insert(tvModel.toJson());
  }

  Future<void> deleteTv(String videoId) async {
    await _supabase.from("videos").delete().match({"videoId": videoId});
  }

  Future<void> editTv(String videoId, String tvTitle) async {
    await _supabase
        .from("videos")
        .update({"title": tvTitle}).match({"videoId": videoId});
  }
}

final tvRepo = Provider((ref) => TvRepository());
