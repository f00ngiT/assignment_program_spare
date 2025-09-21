import 'package:flutter/material.dart';

class ServiceType{
  final int serviceTypeId;
  final String serviceTypeName;
  final int servicePrice;

  ServiceType({
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.servicePrice,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      serviceTypeId: json['ServiceTypeId'] as int,
      serviceTypeName: json['ServiceTypeName'] as String,
      servicePrice: json['ServicePrice'] as int,
    );
  }
}