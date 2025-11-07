// Kullanıcı veri modelleri
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String username;
  final String email;
  final String userType; // 'patient', 'doctor', 'admin'
  final String? fullName;
  final String createdAt;
  final bool isActive;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.userType,
    this.fullName,
    required this.createdAt,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Patient extends User {
  final String? dateOfBirth;
  final String? gender;
  final String? phone;
  final String? emergencyContact;
  final List<String>? medicalConditions;
  final List<String>? assignedDoctors;

  Patient({
    required String userId,
    required String username,
    required String email,
    String? fullName,
    required String createdAt,
    required bool isActive,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.emergencyContact,
    this.medicalConditions,
    this.assignedDoctors,
  }) : super(
          userId: userId,
          username: username,
          email: email,
          userType: 'patient',
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
        );

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}

@JsonSerializable()
class Doctor extends User {
  final String licenseNumber;
  final String specialization;
  final String? hospital;
  final List<String>? patients;

  Doctor({
    required String userId,
    required String username,
    required String email,
    String? fullName,
    required String createdAt,
    required bool isActive,
    required this.licenseNumber,
    required this.specialization,
    this.hospital,
    this.patients,
  }) : super(
          userId: userId,
          username: username,
          email: email,
          userType: 'doctor',
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
        );

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DoctorToJson(this);
}

@JsonSerializable()
class Admin extends User {
  final List<String> permissions;

  Admin({
    required String userId,
    required String username,
    required String email,
    String? fullName,
    required String createdAt,
    required bool isActive,
    required this.permissions,
  }) : super(
          userId: userId,
          username: username,
          email: email,
          userType: 'admin',
          fullName: fullName,
          createdAt: createdAt,
          isActive: isActive,
        );

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}