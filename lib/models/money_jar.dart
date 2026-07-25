import 'base_model.dart';

class MoneyJar extends BaseModel {
  double curAmount;
  double increment;
  double goalAmount;
  bool useLiquidFill;

  MoneyJar({
    required super.name,
    super.updatedAt,
    super.isComplete,
    this.curAmount = 0.0,
    this.increment = 1.0,
    this.goalAmount = 10.0,
    this.useLiquidFill = true,
  });

  double get progress => goalAmount <= 0 ? 0 : (curAmount / goalAmount).clamp(0.0, 1.0);

  void addToJar() {
    curAmount += increment;
    updatedAt = DateTime.now();
    if (curAmount >= goalAmount) {
      curAmount = goalAmount;
      markComplete();
    }
  }

  void removeFromJar() {
    curAmount -= increment;
    if (curAmount < 0) curAmount = 0;
    isComplete = false;
    updatedAt = DateTime.now();
  }

  void reset() {
    curAmount = 0.0;
    isComplete = false;
    updatedAt = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'curAmount': curAmount,
    'increment': increment,
    'goalAmount': goalAmount,
    'useLiquidFill': useLiquidFill,
  };

  factory MoneyJar.fromJson(Map<String, dynamic> json) => MoneyJar(
    name: json['name'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    curAmount: (json['curAmount'] as num).toDouble(),
    increment: (json['increment'] as num).toDouble(),
    goalAmount: (json['goalAmount'] as num).toDouble(),
    useLiquidFill: json['useLiquidFill'] as bool? ?? true,
  );
}
