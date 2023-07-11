import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContractConfigRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<String>?> getRegionItems() async {
    List<String> list = [];
    final contractionRegions = await _db.collection("contract_region").get();
    for (var region in contractionRegions.docs) {
      list.add(region.get("fullRegion"));
    }
    return list;
  }

  Future<List<String>?> getCommunityItems() async {
    List<String> list = [];
    final contractCommunities = await _db.collection("community").get();
    for (var community in contractCommunities.docs) {
      list.add(community.get("communityTitle"));
    }
    return list;
  }
}

final contractRepo = Provider((ref) => ContractConfigRepository());
