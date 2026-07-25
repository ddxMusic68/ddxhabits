class JournalSubEntry {
  DateTime timestamp;
  String text;

  JournalSubEntry({
    required this.timestamp,
    this.text = '',
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'text': text,
  };

  factory JournalSubEntry.fromJson(Map<String, dynamic> json) => JournalSubEntry(
    timestamp: DateTime.parse(json['timestamp'] as String),
    text: json['text'] as String? ?? '',
  );
}
