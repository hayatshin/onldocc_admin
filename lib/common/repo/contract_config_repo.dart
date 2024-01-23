import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContractConfigRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>?> getRegionItems() async {
    final contractRegions =
        await _supabase.from("contract_regions").select('*, subdistricts(*)');
    return contractRegions;
  }

  Future<List<String>?> getCommunityItems() async {
    return ["없음"];
  }
}

final contractRepo = Provider((ref) => ContractConfigRepository());
