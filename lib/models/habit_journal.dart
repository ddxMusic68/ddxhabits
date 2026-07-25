import 'base_model.dart';
import 'journal_entry.dart';

class HabitJournal extends BaseModel {
  bool isGoodHabit;
  List<JournalEntry> journalEntryList;

  HabitJournal({
    required super.name,
    this.isGoodHabit = true,
    super.updatedAt,
    super.isComplete,
    List<JournalEntry>? journalEntryList,
  }) : journalEntryList = journalEntryList ?? [];

  void addEntry(JournalEntry entry) {
    journalEntryList.add(entry);
    updatedAt = DateTime.now();
  }

  void removeEntry(int index) {
    if (index >= 0 && index < journalEntryList.length) {
      journalEntryList.removeAt(index);
      updatedAt = DateTime.now();
    }
  }

  JournalEntry? getEntryForDate(DateTime date) {
    for (final entry in journalEntryList) {
      if (entry.date.year == date.year &&
          entry.date.month == date.month &&
          entry.date.day == date.day) {
        return entry;
      }
    }
    return null;
  }

  JournalEntry getOrCreateEntryForDate(DateTime date) {
    final existing = getEntryForDate(date);
    if (existing != null) return existing;
    final entry = JournalEntry(
      date: DateTime(date.year, date.month, date.day),
    );
    addEntry(entry);
    return entry;
  }

  Set<int> getDaysWithEntries(int year, int month) {
    return journalEntryList
        .where((e) =>
            e.date.year == year &&
            e.date.month == month &&
            e.entries.isNotEmpty)
        .map((e) => e.date.day)
        .toSet();
  }

  Set<int> getDaysWithBadHabit(int year, int month) {
    return journalEntryList
        .where((e) =>
            e.date.year == year &&
            e.date.month == month &&
            e.didAnything)
        .map((e) => e.date.day)
        .toSet();
  }

  DateTime? get firstEntryDate {
    if (journalEntryList.isEmpty) return null;
    DateTime? earliest;
    for (final e in journalEntryList) {
      if (earliest == null || e.date.isBefore(earliest)) {
        earliest = e.date;
      }
    }
    return earliest;
  }

  int get currentStreak {
    if (isGoodHabit) return 0;
    final now = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    DateTime? firstEntryDate;
    for (final e in journalEntryList) {
      if (firstEntryDate == null || e.date.isBefore(firstEntryDate)) {
        firstEntryDate = e.date;
      }
    }

    final startDate = firstEntryDate != null
        ? DateTime(firstEntryDate.year, firstEntryDate.month, firstEntryDate.day)
        : checkDate;

    while (!checkDate.isBefore(startDate)) {
      final entry = getEntryForDate(checkDate);
      if (entry != null && entry.didAnything) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    if (isGoodHabit) return 0;
    final sorted = List<JournalEntry>.from(journalEntryList)
      ..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.isEmpty) return currentStreak;

    int best = 0;
    int current = 0;
    DateTime? prevDate;

    for (final entry in sorted) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (prevDate != null) {
        final diff = entryDate.difference(prevDate).inDays;
        if (diff > 1 && !entry.didAnything) {
          current += diff - 1;
        }
      }
      if (entry.didAnything) {
        if (current > best) best = current;
        current = 0;
      } else {
        current++;
      }
      prevDate = entryDate;
    }
    if (current > best) best = current;
    if (best < currentStreak) best = currentStreak;
    return best;
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'isGoodHabit': isGoodHabit,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'journalEntryList': journalEntryList.map((e) => e.toJson()).toList(),
  };

  factory HabitJournal.fromJson(Map<String, dynamic> json) => HabitJournal(
    name: json['name'] as String,
    isGoodHabit: json['isGoodHabit'] as bool? ?? true,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    journalEntryList: (json['journalEntryList'] as List<dynamic>)
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
