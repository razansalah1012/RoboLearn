import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

enum NotificationCategory { workshop, update }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  final String meta;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.meta = '',
  });

  String get categoryLabel {
    switch (category) {
      case NotificationCategory.workshop:
        return 'Workshop';
      case NotificationCategory.update:
      default:
        return 'Update';
    }
  }

  Color get badgeColor {
    switch (category) {
      case NotificationCategory.workshop:
        return const Color(0xFFE8F5EE);
      case NotificationCategory.update:
      default:
        return const Color(0xFFFAF2E4);
    }
  }

  Color get badgeTextColor {
    switch (category) {
      case NotificationCategory.workshop:
        return const Color(0xFF3F6F57);
      case NotificationCategory.update:
      default:
        return const Color(0xFF9A6C1F);
    }
  }

  IconData get iconData {
    switch (category) {
      case NotificationCategory.workshop:
        return Icons.calendar_month_outlined;
      case NotificationCategory.update:
      default:
        return Icons.campaign_outlined;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'category': category.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'meta': meta,
    };
  }

  factory NotificationItem.fromMap(String id, Map<String, dynamic> map) {
    return NotificationItem(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: NotificationCategory.values.firstWhere(
        (value) => value.name == (map['category'] ?? 'update'),
        orElse: () => NotificationCategory.update,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      meta: map['meta'] ?? '',
    );
  }
}
