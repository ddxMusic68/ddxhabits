abstract class BaseModel {
  String name;
  DateTime updatedAt;
  bool isComplete;

  BaseModel({
    required this.name,
    DateTime? updatedAt,
    this.isComplete = false,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson();

  void markComplete() {
    isComplete = true;
    updatedAt = DateTime.now();
  }
}
