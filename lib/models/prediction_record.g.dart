// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PredictionRecordAdapter extends TypeAdapter<PredictionRecord> {
  @override
  final int typeId = 0;

  @override
  PredictionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PredictionRecord(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      mainClass: fields[2] as String,
      subclass: fields[3] as String,
      confidenceMain: fields[4] as double,
      confidenceSub: fields[5] as double,
      inferenceTime: fields[6] as int,
      timestamp: fields[7] as DateTime,
      isCorrect: fields[8] as bool?,
      isSynced: fields[9] as bool,
      mainProbabilities: (fields[10] as List).cast<double>(),
      subProbabilities: (fields[11] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, PredictionRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.mainClass)
      ..writeByte(3)
      ..write(obj.subclass)
      ..writeByte(4)
      ..write(obj.confidenceMain)
      ..writeByte(5)
      ..write(obj.confidenceSub)
      ..writeByte(6)
      ..write(obj.inferenceTime)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.isCorrect)
      ..writeByte(9)
      ..write(obj.isSynced)
      ..writeByte(10)
      ..write(obj.mainProbabilities)
      ..writeByte(11)
      ..write(obj.subProbabilities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
