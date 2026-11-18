import 'package:flutter/material.dart';
import '../models/transaction.dart';

class CategoryItem {
  final String id;
  final String name;
  final TransactionType type;
  final IconData icon;
  final Color color;
  final bool isDefault;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = true,
  });

  CategoryItem copyWith({
    String? id,
    String? name,
    TransactionType? type,
    IconData? icon,
    Color? color,
    bool? isDefault,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
