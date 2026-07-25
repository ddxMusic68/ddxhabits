class Goal {
  String title;
  bool isComplete;

  Goal({
    required this.title,
    this.isComplete = false,
  });

  void complete() {
    isComplete = true;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'isComplete': isComplete,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    title: json['title'] as String,
    isComplete: json['isComplete'] as bool,
  );
}
