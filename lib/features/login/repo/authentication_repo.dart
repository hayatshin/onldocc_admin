import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _supabase = Supabase.instance.client;

  bool get isLoggedIn => user != null;
  User? get user => _firebaseAuth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<Map<String, dynamic>?> getAdminProfile(String uid) async {
    final doc = await _supabase
        .from("admins")
        .select('*, subdistricts(*), contract_regions(*)')
        .eq('adminId', uid)
        .single();
    return doc;
  }
}

final authRepo = Provider((ref) => AuthenticationRepository());
