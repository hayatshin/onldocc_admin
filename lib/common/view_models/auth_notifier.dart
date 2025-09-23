import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      user = u;
      if (!isReady) isReady = true; // 첫 이벤트 수신 시 복원 완료로 간주
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _sub;
  User? user;
  bool isReady = false;

  @override
  void dispose() {
    _sub.cancel();

    super.dispose();
  }
}
