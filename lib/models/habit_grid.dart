import 'dart:math';
import 'base_model.dart';

class HabitGrid extends BaseModel {
  double totalCount;
  double countIncrement;
  double squareCost;
  double currentCredit;
  List<bool> boolList;

  HabitGrid({
    required super.name,
    super.updatedAt,
    super.isComplete,
    required this.totalCount,
    this.countIncrement = 1.0,
    this.squareCost = 1.0,
    this.currentCredit = 0.0,
    List<bool>? boolList,
  }) : boolList = boolList ?? List<bool>.filled(totalCount.toInt(), false);

  int get filledCount => boolList.where((b) => b).length;

  int get columns => totalCount <= 0 ? 1 : sqrt(totalCount).ceil();

  double get fillProgress => totalCount <= 0 ? 0 : filledCount / totalCount;

  double get totalSpent => squareCost * filledCount;

  void incrementCredit() {
    currentCredit += countIncrement;
    updatedAt = DateTime.now();
  }

  bool fillSquare(int index) {
    if (index < 0 || index >= boolList.length) return false;
    if (boolList[index]) return false;
    if (currentCredit < squareCost) return false;

    currentCredit -= squareCost;
    boolList[index] = true;
    updatedAt = DateTime.now();
    if (filledCount >= totalCount) {
      markComplete();
    }
    return true;
  }

  void reset() {
    boolList = List<bool>.filled(totalCount.toInt(), false);
    currentCredit = 0.0;
    isComplete = false;
    updatedAt = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'totalCount': totalCount,
    'countIncrement': countIncrement,
    'squareCost': squareCost,
    'currentCredit': currentCredit,
    'boolList': boolList,
  };

  factory HabitGrid.fromJson(Map<String, dynamic> json) => HabitGrid(
    name: json['name'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    totalCount: (json['totalCount'] as num).toDouble(),
    countIncrement: (json['countIncrement'] as num).toDouble(),
    squareCost: (json['squareCost'] as num).toDouble(),
    currentCredit: (json['currentCredit'] as num?)?.toDouble() ?? 0.0,
    boolList: (json['boolList'] as List<dynamic>).map((e) => e as bool).toList(),
  );
}
