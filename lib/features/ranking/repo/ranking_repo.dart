import 'dart:convert';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/utils.dart';

class RankingRepository {
  static final pointPFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-p-functions");

  // supabase
  Future<List<dynamic>> getUserPoints(
      List<UserModel> userList, DateRange range) async {
    final startSeconds = convertStartDateTimeToSeconds(range.start);
    final endSeconds = convertEndDateTimeToSeconds(range.end);

    Map<String, dynamic> requestBody = {
      'userlist': userList,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
    };

    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      pointPFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }
    return [];
  }
}

final rankingRepo = Provider((ref) => RankingRepository());
