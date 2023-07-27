import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_config_model.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';

class TvViewModel extends AsyncNotifier<List<TvModel>> {
  late TvRepository _tvRepository;
  @override
  FutureOr<List<TvModel>> build() async {
    _tvRepository = TvRepository();
    List<TvModel> tvList = await getCertainTvList();
    return tvList;
  }

  Future<List<TvModel>> getCertainTvList() async {
    state = const AsyncValue.loading();

    ContractConfigModel contractConfigModel =
        ref.watch(contractConfigProvider).value!;

    // String contractType = contractConfigModel.contractType;
    String contractName = contractConfigModel.contractName;

    List<TvModel> tvList = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tvs =
        await ref.read(tvRepo).getAllTvs();
    for (QueryDocumentSnapshot<Map<String, dynamic>> tv in tvs) {
      bool allUser = tv.get("allUser");

      if (allUser) {
        TvModel tvModel = TvModel.fromJson(tv.data());
        tvList.add(tvModel);
      } else {
        if (tv.data().containsKey("contractName")) {
          String tvContractName = tv.get("contractName");
          if (tvContractName == contractName) {
            TvModel tvModel = TvModel.fromJson(tv.data());
            tvList.add(tvModel);
          }
        }
      }
    }

    state = AsyncValue.data(tvList);
    return tvList;
  }

  Future<void> saveTvwithJson(String title, String link) async {
    Map<String, dynamic> tvJson = {};

    ContractConfigModel contractConfigModel =
        ref.watch(contractConfigProvider).value!;
    String contractType = contractConfigModel.contractType;
    String contractName = contractConfigModel.contractName;
    String documentId = "";
    String thumbnail = "";

    if (link.contains("youtu.be")) {
      final parts = link.split("youtu.be/");
      documentId = parts[1];
    } else if (link.contains("youtube.com")) {
      final parts = link.split("watch?v=");
      documentId = parts[1];
    }

    if (link.contains("youtu.be")) {
      thumbnail = "http://i3.ytimg.com/vi/$documentId/hqdefault.jpg";
    } else if (link.contains("youtube.com")) {
      thumbnail = "https://img.youtube.com/vi/$documentId/mqdefault.jpg";
    }

    if (contractType != "마스터") {
      tvJson = {
        "allUser": false,
        "contractType": contractType,
        "contractName": contractName,
        "documentId": documentId,
        "link": link,
        "thumbnail": thumbnail,
        "title": title,
      };
    } else {
      tvJson = {
        "allUser": true,
        "documentId": documentId,
        "link": link,
        "thumbnail": thumbnail,
        "title": title,
      };
    }

    await ref.read(tvRepo).saveTv(tvJson, documentId);
  }
}

final tvProvider = AsyncNotifierProvider<TvViewModel, List<TvModel>>(
  () => TvViewModel(),
);
