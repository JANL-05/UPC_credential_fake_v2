import 'dart:io';
import 'package:flutter/material.dart' show TimeOfDay;

class StudentModel {
  final File? photo;
  final String fullName;
  final String studentCode;
  final String idBanner;
  final String career;
  final String campus;
  final DateTime baseDate;
  final TimeOfDay startTime;

  const StudentModel({
    this.photo,
    required this.fullName,
    required this.studentCode,
    required this.idBanner,
    required this.career,
    required this.campus,
    required this.baseDate,
    required this.startTime,
  });
}
