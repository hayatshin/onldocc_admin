import 'package:firebase_auth/firebase_auth.dart';

// Map<String, String> headers = {
//   'Content-Type': 'text/plain',
// };

Future<Map<String, String>> firebaseTokenHeaders() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  if (token == null) {
    throw Exception("[firebase token] Firebase user not authenticated");
  }

  final Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  return headers;
}
