import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../providers/habit_tracker_provider.dart';
import '../utils/constants.dart';

class EntryScreen extends StatefulWidget {
  final int journalIndex;
  final DateTime date;
  final bool isGoodHabit;
  final String journalName;

  const EntryScreen({
    super.key,
    required this.journalIndex,
    required this.date,
    required this.isGoodHabit,
    required this.journalName,
  });

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late JournalEntry _entry;
  final Map<int, TextEditingController> _controllers = {};
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<HabitTrackerProvider>();
    _entry = provider.getOrCreateJournalEntryForDate(widget.journalIndex, widget.date);
    _notesController = TextEditingController(text: _entry.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveNotes(String text) {
    _entry.notes = text;
    final provider = context.read<HabitTrackerProvider>();
    provider.saveJournalEntry(widget.journalIndex, _entry);
  }

  TextEditingController _getController(int index, String text) {
    return _controllers.putIfAbsent(index, () => TextEditingController(text: text));
  }

  void _addEntry() {
    final provider = context.read<HabitTrackerProvider>();
    provider.addSubEntry(widget.journalIndex, _entry);
    setState(() {});
  }

  void _removeEntry(int subIndex) {
    final provider = context.read<HabitTrackerProvider>();
    provider.removeSubEntry(widget.journalIndex, _entry, subIndex);
    setState(() {});
  }

  void _updateText(int subIndex, String text) {
    final provider = context.read<HabitTrackerProvider>();
    provider.saveSubEntryText(widget.journalIndex, _entry, subIndex, text);
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hms();
    final accentColor = widget.isGoodHabit ? AppColors.mintDark : AppColors.coralDark;
    final bgColor = widget.isGoodHabit ? AppColors.mintLight : const Color.fromARGB(255, 226, 108, 108);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.journalName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat.yMMMMd().format(widget.date),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotesSection(accentColor),
          if (_entry.entries.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            ...List.generate(_entry.entries.length, (index) {
              final sub = _entry.entries[index];
              return _buildEntryCard(sub, index, timeFormat, accentColor, bgColor);
            }),
          ] else ...[
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Tap + to add a timestamped entry',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.emptySquare),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: null,
            minLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your thoughts...',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
              isDense: true,
            ),
            style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
            onChanged: _saveNotes,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(
    dynamic sub,
    int index,
    DateFormat timeFormat,
    Color accentColor,
    Color bgColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    timeFormat.format(sub.timestamp),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: accentColor,
                  onPressed: () => _removeEntry(index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _getController(index, sub.text),
              maxLines: null,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                isDense: true,
              ),
              style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
              onChanged: (text) => _updateText(index, text),
            ),
          ],
        ),
      ),
    );
  }
}
