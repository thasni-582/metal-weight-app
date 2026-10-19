import 'package:flutter/material.dart';

class CalculationModel {
  final String id;
  final String title;
  final String subtitle;
  final String weight;
  final String time;
  final String iconName;
  final Color bgColor;
  final Color iconColor;
  final double weightValue;
  final Map<String, dynamic> details;

  IconData get icon {
    switch (iconName) {
      case 'circle':
      case 'round_bar':
        return Icons.circle;
      case 'square':
      case 'square_bar':
        return Icons.crop_square;
      case 'layers':
      case 'sheet':
        return Icons.layers;
      case 'horizontal_rule':
        return Icons.horizontal_rule;
      case 'view_column':
      case 'beam':
        return Icons.view_column;
      case 'hexagon':
        return Icons.hexagon;
      case 'rectangle':
      case 'flat_bar':
        return Icons.rectangle;
      case 'pipe':
      case 'tube':
        return Icons.radio_button_unchecked;
      case 'angle':
      case 'timeline':
        return Icons.timeline;
      case 'channel':
      case 'view_stream':
        return Icons.view_stream;
      case 'calculate':
      default:
        return Icons.calculate;
    }
  }

  CalculationModel({
    String? id,
    required this.title,
    required this.subtitle,
    required this.weight,
    required this.time,
    required this.iconName,
    required this.bgColor,
    required this.iconColor,
    required this.weightValue,
    required this.details,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'weight': weight,
        'time': time,
        'iconName': iconName,
        'bgColor': bgColor.toARGB32(),
        'iconColor': iconColor.toARGB32(),
        'weightValue': weightValue,
        'details': details,
      };

  factory CalculationModel.fromJson(Map<String, dynamic> json) {
    return CalculationModel(
      id: json['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      weight: json['weight'] ?? '0 kg',
      time: json['time'] ?? '',
      iconName: json['iconName'] ?? 'calculate',
      bgColor: Color(json['bgColor'] ?? 0xFFDBE1FF),
      iconColor: Color(json['iconColor'] ?? 0xFF003EA8),
      weightValue: (json['weightValue'] ?? 0.0).toDouble(),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }
}
