import 'package:flutter/material.dart';

class ContractConfigModel {
  final String contractType;
  final String contractName;

  ContractConfigModel({
    required this.contractType,
    required this.contractName,
  });
}

class ContractNotifier with ChangeNotifier {
  ContractConfigModel _contractConfigModel =
      ContractConfigModel(contractType: "", contractName: "");

  ContractConfigModel get contractConfigModel => _contractConfigModel;

  void changeContractModel({String? contractType, String? contractName}) {
    _contractConfigModel = ContractConfigModel(
      contractType: contractType ?? _contractConfigModel.contractType,
      contractName: contractName ?? _contractConfigModel.contractName,
    );

    notifyListeners();
  }
}

final contractNotifier = ContractNotifier();
