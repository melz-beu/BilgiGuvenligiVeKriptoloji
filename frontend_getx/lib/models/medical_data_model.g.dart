// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalData _$MedicalDataFromJson(Map<String, dynamic> json) => MedicalData(
      dataId: json['data_id'] as String,
      patientId: json['patient_id'] as String,
      dataType: json['data_type'] as String,
      value: (json['value'] as num?)?.toDouble(),
      timestamp: json['timestamp'] as String,
      deviceId: json['device_id'] as String?,
      isProcessed: json['is_processed'] as bool,
    );

Map<String, dynamic> _$MedicalDataToJson(MedicalData instance) =>
    <String, dynamic>{
      'data_id': instance.dataId,
      'patient_id': instance.patientId,
      'data_type': instance.dataType,
      'value': instance.value,
      'timestamp': instance.timestamp,
      'device_id': instance.deviceId,
      'is_processed': instance.isProcessed,
    };

OximeterData _$OximeterDataFromJson(Map<String, dynamic> json) => OximeterData(
      dataId: json['data_id'] as String,
      patientId: json['patient_id'] as String,
      timestamp: json['timestamp'] as String,
      deviceId: json['device_id'] as String?,
      spo2Value: (json['spo2_value'] as num).toDouble(),
      bpmValue: (json['bpm_value'] as num).toDouble(),
      ahiIndex: json['ahi_index'] as String,
    );

Map<String, dynamic> _$OximeterDataToJson(OximeterData instance) =>
    <String, dynamic>{
      'data_id': instance.dataId,
      'patient_id': instance.patientId,
      'timestamp': instance.timestamp,
      'device_id': instance.deviceId,
      'spo2_value': instance.spo2Value,
      'bpm_value': instance.bpmValue,
      'ahi_index': instance.ahiIndex,
    };

SleepApneaRecord _$SleepApneaRecordFromJson(Map<String, dynamic> json) =>
    SleepApneaRecord(
      recordId: json['recordId'] as String,
      patientId: json['patientId'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String?,
      deviceId: json['deviceId'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => OximeterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      blockHash: json['blockHash'] as String?,
      isMined: json['isMined'] as bool,
      metrics: json['metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SleepApneaRecordToJson(SleepApneaRecord instance) =>
    <String, dynamic>{
      'recordId': instance.recordId,
      'patientId': instance.patientId,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'deviceId': instance.deviceId,
      'dataPoints': instance.dataPoints,
      'blockHash': instance.blockHash,
      'isMined': instance.isMined,
      'metrics': instance.metrics,
    };

BlockchainBlock _$BlockchainBlockFromJson(Map<String, dynamic> json) =>
    BlockchainBlock(
      index: (json['index'] as num).toInt(),
      timestamp: json['timestamp'] as String,
      data: json['data'] as List<dynamic>,
      previousHash: json['previousHash'] as String,
      hash: json['hash'] as String,
      nonce: (json['nonce'] as num).toInt(),
      leadingZeros: (json['leadingZeros'] as num).toInt(),
    );

Map<String, dynamic> _$BlockchainBlockToJson(BlockchainBlock instance) =>
    <String, dynamic>{
      'index': instance.index,
      'timestamp': instance.timestamp,
      'data': instance.data,
      'previousHash': instance.previousHash,
      'hash': instance.hash,
      'nonce': instance.nonce,
      'leadingZeros': instance.leadingZeros,
    };

BlockchainStats _$BlockchainStatsFromJson(Map<String, dynamic> json) =>
    BlockchainStats(
      totalBlocks: (json['totalBlocks'] as num).toInt(),
      totalTransactions: (json['totalTransactions'] as num).toInt(),
      difficulty: (json['difficulty'] as num).toInt(),
      pendingTransactions: (json['pendingTransactions'] as num).toInt(),
      isValid: json['isValid'] as bool,
    );

Map<String, dynamic> _$BlockchainStatsToJson(BlockchainStats instance) =>
    <String, dynamic>{
      'totalBlocks': instance.totalBlocks,
      'totalTransactions': instance.totalTransactions,
      'difficulty': instance.difficulty,
      'pendingTransactions': instance.pendingTransactions,
      'isValid': instance.isValid,
    };
