import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/utils.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel dbToUserModel(QueryDocumentSnapshot<Map<String, dynamic>> user) {
    try {
      final userBirthYear = user.data().containsKey("birthYear")
          ? user.get("birthYear")
          : "정보 없음";
      final userBirthDay =
          user.data().containsKey("birthDay") ? user.get("birthDay") : null;
      final userBirthMonth = userBirthDay != null || userBirthDay != ""
          ? userBirthDay.toString().length == 4
              ? userBirthDay.toString().substring(0, 2)
              : ""
          : "정보";
      final userBirthDate = userBirthDay != null || userBirthDay != ""
          ? userBirthDay.toString().length == 4
              ? userBirthDay.toString().substring(2, 4)
              : ""
          : "없음";

      final userFullBirthday =
          userBirthYear == "" && userBirthMonth == "" && userBirthDate == ""
              ? "정보 없음"
              : "$userBirthYear.$userBirthMonth.$userBirthDate";
      final userAge = userBirthYear != "정보 없음" &&
              userBirthDay != "정보 없음" &&
              userBirthYear != "" &&
              userBirthDay != ""
          ? userAgeCalculation(userBirthYear, userBirthDay)
          : "정보 없음";
      final Timestamp? dbTimestamp =
          user.data().containsKey("timestamp") ? user.get("timestamp") : null;
      final String userRegisterDate = dbTimestamp != null
          ? DateFormat('yyyy.MM.dd').format(dbTimestamp.toDate())
          : "정보 없음";
      final Timestamp? dbLastVisit =
          user.data().containsKey("lastVisit") ? user.get("lastVisit") : null;

      final String lastVisit = dbLastVisit != null
          ? DateFormat('yyyy.MM.dd').format(dbLastVisit.toDate())
          : "";

      final userRegion =
          user.data().containsKey("region") ? user.get("region") : "정보";
      final userSmallRegion = user.data().containsKey("smallRegion")
          ? user.get("smallRegion")
          : "없음";
      final userFullRegion = "$userRegion $userSmallRegion";

      Map<String, dynamic> userModel = {
        "userId": user.get("userId") ?? "정보 없음",
        "name": user.get("name") ?? "정보 없음",
        "age": userAge,
        "fullBirthday": userFullBirthday,
        "gender": user.get("gender") ?? "정보 없음",
        "phone": user.get("phone") ?? "정보 없음",
        "fullRegion": userFullRegion,
        "registerDate": userRegisterDate,
        "lastVisit": lastVisit,
        "totalScore": 0,
        "stepScore": 0,
        "diaryScore": 0,
        "commentScore": 0,
      };
      UserModel convertUserModel = UserModel.fromJson(userModel);
      return convertUserModel;
    } catch (e) {
      // ignore: avoid_print
      print("dbToUserModel -> ${user.data()}");
    }
    return UserModel.empty();
  }

  UserModel docToUserModel(DocumentSnapshot<Map<String, dynamic>> user) {
    try {
      final userBirthYear = user.data()!.containsKey("birthYear")
          ? user.get("birthYear")
          : "정보 없음";
      final userBirthDay =
          user.data()!.containsKey("birthDay") ? user.get("birthDay") : null;
      final userBirthMonth = userBirthDay != null
          ? userBirthDay.toString().length == 4
              ? userBirthDay.toString().substring(0, 2)
              : "77"
          : "정보";
      final userBirthDate = userBirthDay != null
          ? userBirthDay.toString().length == 4
              ? userBirthDay.toString().substring(2, 4)
              : "77"
          : "없음";

      final userFullBirthday = "$userBirthYear.$userBirthMonth.$userBirthDate";
      final userAge = userBirthYear != "정보 없음" && userBirthDay != "정보 없음"
          ? userAgeCalculation(userBirthYear, userBirthDay)
          : "정보 없음";
      final Timestamp? dbTimestamp =
          user.data()!.containsKey("timestamp") ? user.get("timestamp") : null;
      final String userRegisterDate = dbTimestamp != null
          ? DateFormat('yyyy.MM.dd').format(dbTimestamp.toDate())
          : "정보 없음";
      final Timestamp? dbLastVisit =
          user.data()!.containsKey("lastVisit") ? user.get("lastVisit") : null;
      final String lastVisit = dbLastVisit != null
          ? DateFormat('yyyy.MM.dd').format(dbLastVisit.toDate())
          : "";
      final userRegion =
          user.data()!.containsKey("region") ? user.get("region") : "정보";
      final userSmallRegion = user.data()!.containsKey("smallRegion")
          ? user.get("smallRegion")
          : "없음";
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
        "lastVisit": lastVisit,
        "totalScore": 0,
        "stepScore": 0,
        "diaryScore": 0,
        "commentScore": 0,
      };
      UserModel convertUserModel = UserModel.fromJson(userModel);
      return convertUserModel;
    } catch (e) {
      // ignore: avoid_print
      print("docToUserModel -> $e");
      return UserModel.empty();
    }
  }

  Future<List<UserModel?>> getAllUserData() async {
    try {
      final userSnapshots =
          await _db.collection("users").orderBy("timestamp").get();

      List<UserModel?> dbAllUserList =
          userSnapshots.docs.map((doc) => dbToUserModel(doc)).toList();

      return dbAllUserList;
    } catch (error) {
      print(error);
    }
    return [];
  }

  Future<List<UserModel?>> getRegionUserData(String fullRegion) async {
    final regionStrings = fullRegion.split(" ");
    final region = regionStrings[0].trim();
    final smallRegion = regionStrings.skip(1).join(" ").trim();
    final userSnapshots = await _db
        .collection("users")
        .where("region", isEqualTo: region)
        .where("smallRegion", isEqualTo: smallRegion)
        .orderBy("timestamp")
        .get();

    return userSnapshots.docs
        .map((doc) => dbToUserModel(doc))
        .toList()
        .where((element) => element.name != "탈퇴자")
        .toList();
  }

  Future<List<UserModel?>> getCommunityUserData(String community) async {
    final userSnapshots = await _db
        .collection("users")
        .where("community", arrayContains: community)
        .orderBy("timestamp")
        .get();

    return userSnapshots.docs
        .map((doc) => dbToUserModel(doc))
        .toList()
        .where((element) => element.name != "탈퇴자")
        .toList();
  }

  Future<void> deleteUser(String userId) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await user.delete();
        await _db.collection("users").doc(userId).delete();
      } else {
        print("no user signed in.");
      }
    } catch (e) {
      print('error in deleting fireauth -> $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final userQuery = await _db.collection("users").doc(userId).get();
    return userQuery.data();
  }

  Future<UserModel?> getUserModel(String userId) async {
    final userQuery = await _db.collection("users").doc(userId).get();

    if (userQuery.exists) {
      UserModel userModel = docToUserModel(userQuery);
      return userModel;
    }
    return null;
  }
}

final userRepo = Provider((ref) => UserRepository());
