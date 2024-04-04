class CareModel {
  final int partnerDates;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final int lastVisit;
  final bool partnerContact;

  CareModel({
    required this.partnerDates,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.lastVisit,
    required this.partnerContact,
  });

  CareModel copyWith({
    final int? partnerDates,
    final String? name,
    final String? age,
    final String? gender,
    final String? phone,
    final int? lastVisit,
    final bool? partnerContact,
  }) {
    return CareModel(
      partnerDates: partnerDates ?? this.partnerDates,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      lastVisit: lastVisit ?? this.lastVisit,
      partnerContact: partnerContact ?? this.partnerContact,
    );
  }
}
