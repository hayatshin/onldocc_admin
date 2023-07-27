import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';

class UserViewModel extends AsyncNotifier<UserModel> {
  @override
  FutureOr<UserModel> build() {
    return UserModel.empty();
  }

  List<UserModel?> filterTableRows(
      List<UserModel?> userList, String searchType, String searchKeyword) {
    if (searchType == "name") {
      final newList =
          userList.where((item) => item!.name.contains(searchKeyword)).toList();
      List<UserModel?> sortList = List.from(newList);
      sortList.sort((a, b) => a!.fullRegion.compareTo(b!.fullRegion));
      return sortList;
    } else if (searchType == "phone") {
      final newList = userList
          .where((item) => item!.phone.contains(searchKeyword))
          .toList();
      List<UserModel?> sortList = List.from(newList);
      sortList.sort((a, b) => a!.fullRegion.compareTo(b!.fullRegion));
      return sortList;
    }
    return userList;
  }

  Future<UserModel?> getUserModel(String userId) async {
    Map<String, dynamic>? userJson =
        await ref.read(userRepo).getUserProfile(userId);
    final userModel = UserModel.fromJson(userJson!);

    return userModel;
  }

  List<UserModel?> indexUserModel(
      String order, List<UserModel?> updateScoreList) {
    int count = 1;
    List<UserModel?> list = [];

    if (order == "종합 점수") {
      for (int i = 0; i < updateScoreList.length - 1; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );

          list.add(indexUpdateUser);
          if (updateScoreList[i]!.totalScore !=
              updateScoreList[i + 1]!.totalScore) {
            count++;
          }
        }
      }
    } else if (order == "걸음수") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.stepScore !=
              updateScoreList[i + 1]!.stepScore) {
            count++;
          }
        }
      }
    } else if (order == "일기") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.diaryScore !=
              updateScoreList[i + 1]!.diaryScore) {
            count++;
          }
        }
      }
    } else if (order == "댓글") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.commentScore !=
              updateScoreList[i + 1]!.commentScore) {
            count++;
          }
        }
      }
    }
    return list;
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, UserModel>(
  () => UserViewModel(),
);
