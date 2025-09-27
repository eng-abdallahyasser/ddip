import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/drug.dart';

/// Reads `lib/sample.json`, parses entries to [Drug], and uploads them to
/// Firestore under collection `drugs` using `id` as the document id.
Future<void> uploadSamples({required void Function(String) onLog}) async {
  onLog('Loading sample.json from assets...');
  final raw = await rootBundle.loadString('lib/sample.json');
  final list = json.decode(raw) as List<dynamic>;
  onLog('Found ${list.length} entries');

  final firestore = FirebaseFirestore.instance;
  int uploaded = 0;

  for (final item in list) {
    try {
      final map = Map<String, dynamic>.from(item as Map);
      final drug = Drug.fromJson(map);
      final docId = drug.id;
      final data = drug.toMap();

      await firestore.collection('drugs').doc(docId).set(data);
      uploaded++;
      onLog('Uploaded id=$docId');
    } catch (e, st) {
      onLog('Failed to upload entry: $e');
      onLog(st.toString());
    }
  }

  onLog('Done. Uploaded $uploaded entries.');
}

/// A small debug button widget that runs the upload and shows logs.
class UploadSamplesButton extends StatefulWidget {
  const UploadSamplesButton({super.key});

  @override
  State<UploadSamplesButton> createState() => _UploadSamplesButtonState();
}

class _UploadSamplesButtonState extends State<UploadSamplesButton> {
  final List<String> _logs = [];
  bool _running = false;

  void _addLog(String s) {
    setState(() => _logs.insert(0, '${DateTime.now().toIso8601String()} - $s'));
  }

  Future<void> _run() async {
    if (_running) return;
    setState(() => _running = true);
    _addLog('Starting upload...');
    try {
      await uploadSamples(onLog: _addLog);
    } catch (e) {
      _addLog('Upload failed: $e');
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _running ? null : _run,
          child: Text(
            _running ? 'Uploading...' : 'Upload sample.json to Firestore',
          ),
        ),
        const SizedBox(height: 8),
        const Text('Logs', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(6),
            ),
            child: _logs.isEmpty
                ? const Center(child: Text('No logs yet'))
                : ListView.builder(
                    reverse: true,
                    itemCount: _logs.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        _logs[i],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// A full page that hosts the upload UI and can be used as a debug route.
class UploadSamplesPage extends StatelessWidget {
  const UploadSamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload sample.json')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: const [Expanded(child: UploadSamplesButton())]),
      ),
    );
  }
}
