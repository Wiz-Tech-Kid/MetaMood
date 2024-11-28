import 'package:flutter/material.dart';

class MentalHealthActivity {
  final String id;
  final IconData icon;
  final String title;
  final String time;
  final String subtitle;
  final bool completed;
  final DateTime date;

  MentalHealthActivity({
    required this.id,
    required this.icon,
    required this.title,
    required this.time,
    required this.subtitle,
    required this.completed,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'icon': icon.codePoint,
      'title': title,
      'time': time,
      'subtitle': subtitle,
      'completed': completed,
      'date': date,
    };
  }

  static MentalHealthActivity fromMap(String id, Map<String, dynamic> map) {
    return MentalHealthActivity(
      id: id,
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      title: map['title'],
      time: map['time'],
      subtitle: map['subtitle'],
      completed: map['completed'],
      date: (map['date'] as DateTime),
    );
  }
}