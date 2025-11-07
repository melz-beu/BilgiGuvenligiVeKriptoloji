// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      userType: json['userType'] as String,
      fullName: json['fullName'] as String?,
      createdAt: json['createdAt'] as String,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'userType': instance.userType,
      'fullName': instance.fullName,
      'createdAt': instance.createdAt,
      'isActive': instance.isActive,
    };

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      createdAt: json['createdAt'] as String,
      isActive: json['isActive'] as bool,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      assignedDoctors: (json['assignedDoctors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
      'createdAt': instance.createdAt,
      'isActive': instance.isActive,
      'dateOfBirth': instance.dateOfBirth,
      'gender': instance.gender,
      'phone': instance.phone,
      'emergencyContact': instance.emergencyContact,
      'medicalConditions': instance.medicalConditions,
      'assignedDoctors': instance.assignedDoctors,
    };

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      createdAt: json['createdAt'] as String,
      isActive: json['isActive'] as bool,
      licenseNumber: json['licenseNumber'] as String,
      specialization: json['specialization'] as String,
      hospital: json['hospital'] as String?,
      patients: (json['patients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
      'createdAt': instance.createdAt,
      'isActive': instance.isActive,
      'licenseNumber': instance.licenseNumber,
      'specialization': instance.specialization,
      'hospital': instance.hospital,
      'patients': instance.patients,
    };

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      createdAt: json['createdAt'] as String,
      isActive: json['isActive'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
      'createdAt': instance.createdAt,
      'isActive': instance.isActive,
      'permissions': instance.permissions,
    };
