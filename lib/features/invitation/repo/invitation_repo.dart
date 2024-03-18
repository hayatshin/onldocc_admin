import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchInvitations(
      DateTime startDate, DateTime endDate, String userSubdistrictId) async {
    int startSeconds = convertStartDateTimeToSeconds(startDate);
    int endSeconds = convertEndDateTimeToSeconds(endDate);
    if (userSubdistrictId == "") {
      final docs = await _supabase.rpc("get_invitations_master", params: {
        'startseconds': startSeconds,
        'endseconds': endSeconds,
      });
      return docs;
    } else {
      final docs = await _supabase.rpc("get_invitations", params: {
        'startseconds': startSeconds,
        'endseconds': endSeconds,
        'usersubdistrictid': userSubdistrictId,
      });
      return docs;
    }
  }
}

final invitationRepo = Provider((ref) => InvitationRepository());
