import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class JournalEntry {
  String id;
  String title;
  String content;
  DateTime createdAt;
  String? mood;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.mood
  });
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  JournalPageState createState() => JournalPageState();
}

class JournalPageState extends State<JournalPage> {
  final List<JournalEntry> _entries = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref('journal_entries');

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        setState(() {
          _entries.clear();
          data.forEach((key, value) {
            _entries.add(JournalEntry(
                id: key,
                title: value['title'],
                content: value['content'],
                createdAt: DateTime.parse(value['createdAt']),
                mood: value['mood']
            ));
          });
        });
      }
    });
  }

  void _addEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _JournalEntryForm(
          onSubmit: (entry) {
            _database.push().set({
              'title': entry.title,
              'content': entry.content,
              'createdAt': entry.createdAt.toIso8601String(),
              'mood': entry.mood
            });
          },
        );
      },
    );
  }

  void _editEntry(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _JournalEntryForm(
          initialEntry: entry,
          onSubmit: (updatedEntry) {
            _database.child(updatedEntry.id).update({
              'title': updatedEntry.title,
              'content': updatedEntry.content,
              'mood': updatedEntry.mood
            });
          },
        );
      },
    );
  }

  void _deleteEntry(JournalEntry entry) {
    _database.child(entry.id).remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: _showInsights,
          ),
        ],
      ),
      body: _entries.isEmpty
          ? _EmptyStateWidget()
          : ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return _JournalEntryCard(
            entry: entry,
            onEdit: () => _editEntry(entry),
            onDelete: () => _deleteEntry(entry),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        tooltip: 'Add New Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInsights() {
    // Placeholder for NLP-based insights
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Journal Insights'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Entries: ${_entries.length}'),
            const Text('Average Mood: Coming Soon'),
            const Text('Most Common Themes: Analyzing...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _JournalEntryForm extends StatefulWidget {
  final JournalEntry? initialEntry;
  final Function(JournalEntry) onSubmit;

  const _JournalEntryForm({
    this.initialEntry,
    required this.onSubmit
  });

  @override
  _JournalEntryFormState createState() => _JournalEntryFormState();
}

class _JournalEntryFormState extends State<_JournalEntryForm> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _selectedMood;

  final List<String> _moods = [
    '😊 Happy',
    '😢 Sad',
    '�anger Angry',
    '😴 Calm',
    '�anxiety Anxious'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.initialEntry?.title ?? ''
    );
    _contentController = TextEditingController(
        text: widget.initialEntry?.content ?? ''
    );
    _selectedMood = widget.initialEntry?.mood;
  }

  void _submit() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Title and content are required'))
      );
      return;
    }

    final entry = JournalEntry(
        id: widget.initialEntry?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.initialEntry?.createdAt ?? DateTime.now(),
        mood: _selectedMood
    );

    widget.onSubmit(entry);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Entry Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Journal Entry',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedMood,
            hint: const Text('Select Mood'),
            items: _moods.map((mood) =>
                DropdownMenuItem(
                    value: mood,
                    child: Text(mood)
                )
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMood = value;
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.initialEntry == null
                ? 'Add Entry'
                : 'Update Entry'
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(
            entry.title,
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                DateFormat('MMM dd, yyyy HH:mm').format(entry.createdAt)
            ),
            if (entry.mood != null)
              Text('Mood: ${entry.mood}',
                  style: const TextStyle(color: Colors.grey)
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Entry'),
                    content: const Text('Are you sure you want to delete this journal entry?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onDelete();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              Icons.book_outlined,
              size: 100,
              color: Colors.grey[300]
          ),
          const SizedBox(height: 20),
          const Text(
            'Your journal is empty',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey
            ),
          ),
          const Text(
            'Start by adding your first entry',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey
            ),
          ),
        ],
      ),
    );
  }
}