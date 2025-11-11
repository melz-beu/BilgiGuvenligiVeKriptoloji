// lib/models/medical_data_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'medical_data_model.g.dart';

@JsonSerializable()
class MedicalData {
  @JsonKey(name: 'data_id')  
  final String dataId;
  @JsonKey(name: 'patient_id')  
  final String patientId;
  @JsonKey(name: 'data_type')  
  final String dataType; // 'SpO2', 'BPM', 'OXIMETER'
  final double? value;
  final String timestamp;
  @JsonKey(name: 'device_id')  
  final String? deviceId;
  @JsonKey(name: 'is_processed')  
  final bool isProcessed;

  MedicalData({
    required this.dataId,
    required this.patientId,
    required this.dataType,
    this.value,
    required this.timestamp,
    this.deviceId,
    required this.isProcessed,
  });

  factory MedicalData.fromJson(Map<String, dynamic> json) => _$MedicalDataFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalDataToJson(this);
}

@JsonSerializable()
class OximeterData extends MedicalData {
  @JsonKey(name: 'spo2_value')  
  final double spo2Value; // Oksijen satürasyonu (%)
  @JsonKey(name: 'bpm_value')  
  final double bpmValue;  // Kalp atış hızı
  @JsonKey(name: 'ahi_index')  
  final String ahiIndex;  // Apnea-Hypopnea Index

  OximeterData({
    required String dataId,
    required String patientId,
    required String timestamp,
    String? deviceId,
    required this.spo2Value,
    required this.bpmValue,
    required this.ahiIndex,
  }) : super(
          dataId: dataId,
          patientId: patientId,
          dataType: 'OXIMETER',
          timestamp: timestamp,
          deviceId: deviceId,
          isProcessed: true,
        );

  factory OximeterData.fromJson(Map<String, dynamic> json) => _$OximeterDataFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$OximeterDataToJson(this);
}

@JsonSerializable()
class SleepApneaRecord {
  final String recordId;
  final String patientId;
  final String startTime;
  final String? endTime;
  final String deviceId;
  final List<OximeterData> dataPoints;
  final String? blockHash;
  final bool isMined;
  final Map<String, dynamic>? metrics;

  SleepApneaRecord({
    required this.recordId,
    required this.patientId,
    required this.startTime,
    this.endTime,
    required this.deviceId,
    required this.dataPoints,
    this.blockHash,
    required this.isMined,
    this.metrics,
  });

  factory SleepApneaRecord.fromJson(Map<String, dynamic> json) => _$SleepApneaRecordFromJson(json);
  Map<String, dynamic> toJson() => _$SleepApneaRecordToJson(this);

  // Kayıt süresini hesaplar (dakika)
  double get durationInMinutes {
    if (endTime == null) return 0.0;
    final start = DateTime.parse(startTime);
    final end = DateTime.parse(endTime!);
    return end.difference(start).inMinutes.toDouble();
  }

  // Ortalama SpO2 değeri
  double get averageSpO2 {
    if (dataPoints.isEmpty) return 0.0;
    final total = dataPoints.map((e) => e.spo2Value).reduce((a, b) => a + b);
    return total / dataPoints.length;
  }

  // Ortalama BPM değeri
  double get averageBPM {
    if (dataPoints.isEmpty) return 0.0;
    final total = dataPoints.map((e) => e.bpmValue).reduce((a, b) => a + b);
    return total / dataPoints.length;
  }
}

@JsonSerializable()
class BlockchainBlock {
  final int index;
  final String timestamp;
  final List<dynamic> data;
  final String previousHash;
  final String hash;
  final int nonce;
  final int leadingZeros;

  BlockchainBlock({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
    required this.hash,
    required this.nonce,
    required this.leadingZeros,
  });

  factory BlockchainBlock.fromJson(Map<String, dynamic> json) => _$BlockchainBlockFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainBlockToJson(this);
}

@JsonSerializable()
class BlockchainStats {
  final int totalBlocks;
  final int totalTransactions;
  final int difficulty;
  final int pendingTransactions;
  final bool isValid;

  BlockchainStats({
    required this.totalBlocks,
    required this.totalTransactions,
    required this.difficulty,
    required this.pendingTransactions,
    required this.isValid,
  });

  factory BlockchainStats.fromJson(Map<String, dynamic> json) => _$BlockchainStatsFromJson(json);
  Map<String, dynamic> toJson() => _$BlockchainStatsToJson(this);
}