// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      userType: json['user_type'] as String,
      fullName: json['full_name'] as String?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'user_type': instance.userType,
      'full_name': instance.fullName,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
    };

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      medicalConditions: (json['medical_conditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      assignedDoctors: (json['assigned_doctors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'phone': instance.phone,
      'emergency_contact': instance.emergencyContact,
      'medical_conditions': instance.medicalConditions,
      'assigned_doctors': instance.assignedDoctors,
    };

Doctor _$DoctorFromJson(Map<String, dynamic> json) => Doctor(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
      licenseNumber: json['license_number'] as String,
      specialization: json['specialization'] as String,
      hospital: json['hospital'] as String?,
      patients: (json['patients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
      'license_number': instance.licenseNumber,
      'specialization': instance.specialization,
      'hospital': instance.hospital,
      'patients': instance.patients,
    };

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      createdAt: json['created_at'] as String,
      isActive: json['is_active'] as bool,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'created_at': instance.createdAt,
      'is_active': instance.isActive,
      'permissions': instance.permissions,
    };
