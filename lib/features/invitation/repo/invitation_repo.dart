import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepository {
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchInvitations(String userSubdistrictId) async {
    // int startSeconds = convertStartDateTimeToSeconds(startDate);
    // int endSeconds = convertEndDateTimeToSeconds(endDate);
    if (userSubdistrictId == "") {
      final data = await _supabase.from("receive_invitations").select('''
              *, 
              sendUsers:sendUserId(userId, name, gender, phone, birthYear, birthDay, subdistrictId, contractCommunityId),
              receiveUsers:receiveUserId(userId, name)
              ''');
      return data;
    } else {
      final data = await _supabase.from("receive_invitations").select('''
              *, 
              sendUsers:sendUserId(userId, name, gender, phone, birthYear, birthDay, subdistrictId, contractCommunityId),
              receiveUsers:receiveUserId(userId, name)
              ''').eq("sendUsers.subdistrictId", userSubdistrictId);
      return data;
    }
  }

  Future<List<dynamic>> fetchUserInvitation(String userId) async {
    final data = await _supabase
        .from("receive_invitations")
        .select('''
              *, 
              sendUsers:sendUserId(userId, name, gender, phone, birthYear, birthDay, subdistrictId, contractCommunityId),
              receiveUsers:receiveUserId(userId, name)
              ''')
        .eq("sendUserId", userId)
        .order("createdAt", ascending: false);
    return data;
  }
}

final invitationRepo = Provider((ref) => InvitationRepository());
