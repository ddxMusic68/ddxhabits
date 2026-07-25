import 'journal_sub_entry.dart';

class JournalEntry {
  DateTime date;
  int count;
  String notes;
  List<JournalSubEntry> entries;

  JournalEntry({
    required this.date,
    this.count = 0,
    this.notes = '',
    List<JournalSubEntry>? entries,
  }) : entries = entries ?? [];

  bool get didAnything => entries.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'count': count,
    'notes': notes,
    'entries': entries.map((e) => e.toJson()).toList(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('entries')) {
      return JournalEntry(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
        entries: (json['entries'] as List<dynamic>?)
            ?.map((e) => JournalSubEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    final timestamps = (json['timestamps'] as List<dynamic>?)
            ?.map((t) => DateTime.parse(t as String))
            .toList() ??
        [];
    final oldContent = json['content'] as String? ?? '';
    return JournalEntry(
      date: DateTime.parse(json['date'] as String),
      count: json['count'] as int? ?? 0,
      notes: oldContent,
      entries: timestamps
          .map((ts) => JournalSubEntry(timestamp: ts, text: ''))
          .toList(),
    );
  }
}
