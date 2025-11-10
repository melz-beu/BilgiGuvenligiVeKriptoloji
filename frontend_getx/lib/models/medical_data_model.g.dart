// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalData _$MedicalDataFromJson(Map<String, dynamic> json) => MedicalData(
      dataId: json['dataId'] as String,
      patientId: json['patientId'] as String,
      dataType: json['dataType'] as String,
      value: (json['value'] as num?)?.toDouble(),
      timestamp: json['timestamp'] as String,
      deviceId: json['deviceId'] as String?,
      isProcessed: json['isProcessed'] as bool,
    );

Map<String, dynamic> _$MedicalDataToJson(MedicalData instance) =>
    <String, dynamic>{
      'dataId': instance.dataId,
      'patientId': instance.patientId,
      'dataType': instance.dataType,
      'value': instance.value,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
      'isProcessed': instance.isProcessed,
    };

OximeterData _$OximeterDataFromJson(Map<String, dynamic> json) => OximeterData(
      dataId: json['dataId'] as String,
      patientId: json['patientId'] as String,
      timestamp: json['timestamp'] as String,
      deviceId: json['deviceId'] as String?,
      spo2Value: (json['spo2Value'] as num).toDouble(),
      bpmValue: (json['bpmValue'] as num).toDouble(),
      ahiIndex: json['ahiIndex'] as String,
    );

Map<String, dynamic> _$OximeterDataToJson(OximeterData instance) =>
    <String, dynamic>{
      'dataId': instance.dataId,
      'patientId': instance.patientId,
      'timestamp': instance.timestamp,
      'deviceId': instance.deviceId,
      'spo2Value': instance.spo2Value,
      'bpmValue': instance.bpmValue,
      'ahiIndex': instance.ahiIndex,
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
