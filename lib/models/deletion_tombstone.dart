class DeletionTombstone {
  final String fileName;
  final String name;
  final DateTime deletedAt;

  const DeletionTombstone({
    required this.fileName,
    required this.name,
    required this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'name': name,
    'deletedAt': deletedAt.toIso8601String(),
  };

  factory DeletionTombstone.fromJson(Map<String, dynamic> json) => DeletionTombstone(
    fileName: json['fileName'] as String,
    name: json['name'] as String,
    deletedAt: DateTime.parse(json['deletedAt'] as String),
  );
}
