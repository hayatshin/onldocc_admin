import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      user = u;
      isReady = true;
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
