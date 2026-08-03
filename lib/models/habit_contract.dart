import 'base_model.dart';

class HabitContract extends BaseModel {
  String time;
  String place;
  String consequence;

  HabitContract({
    required super.name,
    super.updatedAt,
    super.isComplete,
    this.time = '',
    this.place = '',
    this.consequence = '',
  });

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'time': time,
    'place': place,
    'consequence': consequence,
  };

  factory HabitContract.fromJson(Map<String, dynamic> json) => HabitContract(
    name: json['name'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    time: json['time'] as String? ?? '',
    place: json['place'] as String? ?? '',
    consequence: json['consequence'] as String? ?? '',
  );
}
