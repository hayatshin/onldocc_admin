class ContractConfigModel {
  final String contractType;
  final String contractName;

  const ContractConfigModel({
    required this.contractType,
    required this.contractName,
  });

  const ContractConfigModel.empty()
      : contractType = "",
        contractName = ";";

  ContractConfigModel copyWith({
    String? contractType,
    String? contractName,
  }) {
    return ContractConfigModel(
      contractType: contractType ?? this.contractType,
      contractName: contractName ?? this.contractName,
    );
  }
}
