import 'package:flutter/material.dart';

class Task {
  final String id;
  final String details;
  final DateTime time;
  final String task;

  Task({
    required this.id,
    required this.details,
    required this.time,
    required this.task,
  });
}
