import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(NotesApp(prefs: prefs));
}

class NotesApp extends StatelessWidget {
  final SharedPreferences prefs;

  NotesApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotesScreen(prefs: prefs),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final SharedPreferences prefs;

  NotesScreen({required this.prefs});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late List<Note> notes;

  @override
  void initState() {
    super.initState();
    final NoteService noteService = NoteService(widget.prefs);
    notes = noteService.getNotes();
  }

  void _addNote() {
    final newNote = Note(id: DateTime.now().toString(), text: '');
    noteService.addNote(newNote);
    setState(() {
      notes = noteService.getNotes();
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: newNote, prefs: widget.prefs),
      ),
    ).then((_) {
      setState(() {
        notes = noteService.getNotes();
      });
    });
  }

  void _deleteNote(Note note) {
    noteService.deleteNote(note);
    setState(() {
      notes = noteService.getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: notes.isEmpty
          ? Center(child: Text('No notes yet'))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.text.isNotEmpty ? note.text : 'Untitled note'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoteScreen(note: note, prefs: widget.prefs),
                ),
              ).then((_) {
                setState(() {
                  notes = noteService.getNotes();
                });
              });
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNote(note),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: Icon(Icons.add),
      ),
    );
  }

  NoteService get noteService => NoteService(widget.prefs);
}

class NoteService {
  final SharedPreferences _prefs;

  NoteService(this._prefs);

  List<Note> getNotes() {
    final notesJson = _prefs.getStringList('notes') ?? [];
    return notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
  }

  void addNote(Note note) {
    final notes = getNotes()..add(note);
    _saveNotes(notes);
  }

  void deleteNote(Note note) {
    final notes = getNotes().where((n) => n.id != note.id).toList();
    _saveNotes(notes);
  }

  void updateNote(Note note) {
    final notes = getNotes().map((n) => n.id == note.id ? note : n).toList();
    _saveNotes(notes);
  }

  void _saveNotes(List<Note> notes) {
    final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    _prefs.setStringList('notes', notesJson);
  }
}

class Note {
  final String id;
  final String text;

  Note({required this.id, required this.text});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}

class EditNoteScreen extends StatefulWidget {
  final Note note;
  final SharedPreferences prefs;

  EditNoteScreen({required this.note, required this.prefs});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _controller;
  late Note currentNote;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentNote = widget.note;
    _controller = TextEditingController(text: currentNote.text);
  }

  Future<void> _fetchWord() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('https://random-word-api.herokuapp.com/word?number=1 '));
      if (response.statusCode == 200) {
        final List<dynamic> words = jsonDecode(response.body);
        if (words.isNotEmpty) {
          final word = words[0] as String;
          setState(() {
            _controller.text = word;
            currentNote = Note(id: currentNote.id, text: word);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch word')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveNote() {
    final noteService = NoteService(widget.prefs);
    currentNote = Note(id: currentNote.id, text: _controller.text);
    noteService.updateNote(currentNote);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter your note here',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _fetchWord,
                  child: _isLoading ? CircularProgressIndicator() : Text('Get Word of the Day'),
                ),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}