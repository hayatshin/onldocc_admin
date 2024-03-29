import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContractConfigRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getRegionItems() async {
    final contractRegions =
        await _supabase.from("contract_regions").select('*, subdistricts(*)');
    return contractRegions;
  }

  Future<String> convertSubdistrictIdToName(String? subdistrictId) async {
    if (subdistrictId != null) {
      final data = await _supabase
          .from("subdistricts")
          .select('subdistrict')
          .eq('subdistrictId', subdistrictId)
          .single();
      return data["subdistrict"];
    } else {
      return "";
    }
  }

  Future<String> convertContractCommunityIdToName(
      String? contractCommunityId) async {
    if (contractCommunityId != null) {
      final data = await _supabase
          .from("contract_communities")
          .select('name')
          .eq('contractCommunityId', contractCommunityId)
          .single();
      return data["name"];
    } else {
      return "";
    }
  }

  Future<List<Map<String, dynamic>>?> getCommunityItems(
      String subdistrictId) async {
    final contractCommunities = await _supabase
        .from("contract_communities")
        .select('*')
        .eq('subdistrictId', subdistrictId);

    return contractCommunities;
  }
}

final contractRepo = Provider((ref) => ContractConfigRepository());
