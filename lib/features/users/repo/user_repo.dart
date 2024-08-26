import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class UserRepository {
  final _supabase = Supabase.instance.client;

  Future<void> saveAdminUser(Map<String, dynamic> userJson) async {
    await _supabase.from("users").upsert(userJson);
  }

  Future<bool> checkUserExists(String certainUid) async {
    try {
      final userData = await _supabase
          .from("users")
          .select('*')
          .eq('userId', certainUid)
          .count(CountOption.exact);

      return userData.count != 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> initializeUserList(
      String userSubdistrictId) async {
    try {
      List<Map<String, dynamic>> userList = [];
      if (userSubdistrictId == "") {
        final data = await _supabase
            .from("users")
            .select('*, subdistricts(*)')
            .neq('loginType', '어드민')
            .order('createdAt', ascending: true, nullsFirst: false);
        userList = data;
      } else {
        final data = await _supabase
            .from("users")
            .select('*, subdistricts(*)')
            .neq('loginType', '어드민')
            .eq('subdistrictId', userSubdistrictId)
            .order('createdAt', ascending: true, nullsFirst: false);

        userList = data;
      }

      return userList;
    } catch (error) {
      // ignore: avoid_print
      print("initializeUserList -> $error");
    }
    return [];
  }

  Future<void> deleteUser(String userId) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await user.delete();
        await _supabase.from("users").delete().match({"userId": userId});
      } else {
        // ignore: avoid_print
        print("no user signed in.");
      }
    } catch (e) {
      // ignore: avoid_print
      print('error in deleting fireauth -> $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final userQuery =
        await _supabase.from("users").select('*').eq('userId', userId).single();
    return userQuery;
  }
}

final userRepo = Provider((ref) => UserRepository());
