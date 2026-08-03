import 'dart:math';
import 'base_model.dart';

class TimedSession {
  DateTime timestamp;
  int seconds;

  TimedSession({required this.timestamp, required this.seconds});

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'seconds': seconds,
  };

  factory TimedSession.fromJson(Map<String, dynamic> json) => TimedSession(
    timestamp: DateTime.parse(json['timestamp'] as String),
    seconds: (json['seconds'] as num).toInt(),
  );
}

class TimedHabit extends BaseModel {
  bool fasterIsBetter;
  List<TimedSession> sessions;

  TimedHabit({
    required super.name,
    super.updatedAt,
    super.isComplete,
    this.fasterIsBetter = true,
    List<TimedSession>? sessions,
  }) : sessions = sessions ?? [];

  int get sessionCount => sessions.length;

  Duration? get bestTime {
    if (sessions.isEmpty) return null;
    final seconds = fasterIsBetter
        ? sessions.map((s) => s.seconds).reduce(min)
        : sessions.map((s) => s.seconds).reduce(max);
    return Duration(seconds: seconds);
  }

  bool isNewBest(int seconds) {
    final best = bestTime;
    if (best == null) return true;
    return fasterIsBetter ? seconds < best.inSeconds : seconds > best.inSeconds;
  }

  void addSession(int seconds) {
    sessions.add(TimedSession(timestamp: DateTime.now(), seconds: seconds));
    updatedAt = DateTime.now();
  }

  void removeSession(int index) {
    if (index >= 0 && index < sessions.length) {
      sessions.removeAt(index);
      updatedAt = DateTime.now();
    }
  }

  void reset() {
    sessions.clear();
    updatedAt = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'updatedAt': updatedAt.toIso8601String(),
    'isComplete': isComplete,
    'fasterIsBetter': fasterIsBetter,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory TimedHabit.fromJson(Map<String, dynamic> json) => TimedHabit(
    name: json['name'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    isComplete: json['isComplete'] as bool,
    fasterIsBetter: json['fasterIsBetter'] as bool? ?? true,
    sessions: (json['sessions'] as List<dynamic>? ?? [])
        .map((e) => TimedSession.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
