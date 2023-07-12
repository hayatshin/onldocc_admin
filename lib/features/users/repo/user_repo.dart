import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/utils.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel dbToUserModel(QueryDocumentSnapshot<Map<String, dynamic>> user) {
    final userBirthYear =
        user.data().containsKey("birthYear") ? user.get("birthYear") : "정보 없음";
    final userBirthDay =
        user.data().containsKey("birthDay") ? user.get("birthDay") : null;
    final userBirthMonth =
        userBirthDay != null ? userBirthDay.toString().substring(0, 2) : "정보";
    final userBirthDate =
        userBirthDay != null ? userBirthDay.toString().substring(2, 4) : "없음";
    final userFullBirthday = "$userBirthYear.$userBirthMonth.$userBirthDate";
    final userAge = userBirthYear != "정보 없음" && userBirthDay != "정보 없음"
        ? userAgeCalculation(userBirthYear, userBirthDay)
        : "정보 없음";
    final Timestamp? dbTimestamp =
        user.data().containsKey("timestamp") ? user.get("timestamp") : null;
    final String userRegisterDate = dbTimestamp != null
        ? DateFormat('yyyy.MM.dd').format(dbTimestamp.toDate())
        : "정보 없음";
    final userRegion =
        user.data().containsKey("region") ? user.get("region") : "정보";
    final userSmallRegion =
        user.data().containsKey("smallRegion") ? user.get("smallRegion") : "없음";
    final userFullRegion = "$userRegion $userSmallRegion";

    Map<String, dynamic> userModel = {
      "userId": user.get("userId"),
      "name": user.get("name"),
      "age": userAge,
      "fullBirthday": userFullBirthday,
      "gender": user.get("gender"),
      "phone": user.get("phone"),
      "fullRegion": userFullRegion,
      "registerDate": userRegisterDate,
    };
    UserModel convertUserModel = UserModel.fromJson(userModel);
    return convertUserModel;
  }

  Future<List<UserModel?>> getAllUserData() async {
    final userSnapshots =
        await _db.collection("users").orderBy("smallRegion").get();
    return userSnapshots.docs.map((doc) => dbToUserModel(doc)).toList();
  }

  Future<List<UserModel?>> getRegionUserData(String fullRegion) async {
    final regionStrings = fullRegion.split(" ");
    final region = regionStrings[0];
    final smallRegion = regionStrings.skip(1).join(" ");
    final userSnapshots = await _db
        .collection("users")
        .where("region", isEqualTo: region)
        .where("smallRegion", isEqualTo: smallRegion)
        .get();

    return userSnapshots.docs.map((doc) => dbToUserModel(doc)).toList();
  }

  Future<List<UserModel?>> getCommunityUserData(String community) async {
    final userSnapshots = await _db
        .collection("users")
        .where("community", arrayContains: community)
        .get();

    return userSnapshots.docs.map((doc) => dbToUserModel(doc)).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection("users").doc(userId).delete();
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final userQuery = await _db.collection("users").doc(userId).get();
    return userQuery.data();
  }
}

final userRepo = Provider((ref) => UserRepository());
