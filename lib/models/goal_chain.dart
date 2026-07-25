import 'base_model.dart';
import 'goal.dart';

class GoalChain extends BaseModel {
  List<Goal> goalList;

  GoalChain({
    required super.name,
    super.updatedAt,
    super.isComplete,
    List<Goal>? goalList,
  }) : goalList = goalList ?? [];

  int get currentGoalIndex {
    for (int i = 0; i < goalList.length; i++) {
      if (!goalList[i].isComplete) return i;
    }
    return goalList.length;
  }

  Goal? get currentGoal {
    final idx = currentGoalIndex;
    if (idx < goalList.length) return goalList[idx];
    return null;
  }

  double get progress => goalList.isEmpty ? 0 : goalList.where((g) => g.isComplete).length / goalList.length;

  int get completedCount => goalList.where((g) => g.isComplete).length;

  void addGoal(String title) {
    goalList.add(Goal(title: title));
    updatedAt = DateTime.now();
  }

  void removeGoal(int index) {
    if (index >= 0 && index < goalList.length) {
      goalList.removeAt(index);
      updatedAt = DateTime.now();
    }
  }

  void completeCurrentGoal() {
    final idx = currentGoalIndex;
    if (idx < goalList.length) {
      goalList[idx].complete();
      updatedAt = DateTime.now();
      if (goalList.every((g) => g.isComplete)) {
        markComplete();
      }
    }
  }

  void reset() {
    for (final goal in goalList) {
      goal.isComplete = false;
    }
    isComplete = false;
    updatedAt = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'goalList': goalList.map((g) => g.toJson()).toList(),
  };

  factory GoalChain.fromJson(Map<String, dynamic> json) => GoalChain(
    name: json['name'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    goalList: (json['goalList'] as List<dynamic>)
        .map((e) => Goal.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
