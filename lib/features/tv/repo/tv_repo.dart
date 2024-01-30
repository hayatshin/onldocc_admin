import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TvRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  // supabase
  Future<List<Map<String, dynamic>>> getUserTvs(
      AdminProfileModel adminProfile) async {
    if (adminProfile.master) {
      final data =
          await _supabase.from("videos").select('*, contract_regions(*)').order(
                'createdAt',
                ascending: true,
              );
      return data;
    } else {
      final allUsers = await _supabase
          .from("videos")
          .select('*, contract_regions(*)')
          .eq('allUsers', true)
          .order(
            'createdAt',
            ascending: true,
          );
      final contractRegions = await _supabase
          .from("videos")
          .select('*, contract_regions(*)')
          .eq('allUsers', false)
          .eq('contractRegionId', adminProfile.contractRegionId)
          .order(
            'createdAt',
            ascending: true,
          );

      final combinedList = [...contractRegions, ...allUsers];
      combinedList.sort(
          (a, b) => (a["createdAt"] as int).compareTo(b["createdAt"] as int));
      return combinedList;
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

  // firebase
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllTvs() async {
    final tvRef = await _db.collection("youtube").get();
    return tvRef.docs;
  }

  // Future<void> deleteTv(String documentId) async {
  //   await _db.collection("youtube").doc(documentId).delete();
  // }

  Future<void> saveTv(Map<String, dynamic> tvJson, String documentId) async {
    await _db.collection("youtube").doc(documentId).set(tvJson);
  }
}

final tvRepo = Provider((ref) => TvRepository());
