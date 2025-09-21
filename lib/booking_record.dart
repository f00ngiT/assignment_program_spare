import 'package:flutter/material.dart';

class BookingRecord{
  final String phoneNum;
  final String carPlate;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String serviceTypeName;

  BookingRecord({
    required this.phoneNum,
    required this.carPlate,
    required this.description,
    required this.date,
    required this.time,
    required this.serviceTypeName,
  });

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final timeString = json['Time'] as String;
    final timeParts = timeString.split(':');
    final parsedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    return BookingRecord(
        phoneNum: json['PhoneNum'] as String,
        carPlate: json['CarPlate'] as String,
        description: json['Description'] as String,
        date: DateTime.parse(json['Date'] as String),
        time: parsedTime,
        serviceTypeName: json['ServiceType'] as String,
        );
    }
}