import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchInvitations(String userSubdistrictId) async {
    // int startSeconds = convertStartDateTimeToSeconds(startDate);
    // int endSeconds = convertEndDateTimeToSeconds(endDate);

    if (userSubdistrictId == "") {
      final data = await _supabase.rpc("get_invitations_master");
      return data;
    } else {
      final data = await _supabase.rpc("get_invitations_region", params: {
        "usersubdistrictid": userSubdistrictId,
      });
      return data;
    }
  }

  Future<List<dynamic>> fetchUserInvitation(String userId) async {
    final data = await _supabase
        .from("receive_invitations")
        .select('*, users!receive_invitations_receiveUserId_fkey(name)')
        .eq('sendUserId', userId);
    return data;
  }
}

final invitationRepo = Provider((ref) => InvitationRepository());
