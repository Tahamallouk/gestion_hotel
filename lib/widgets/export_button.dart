import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

/// Export button widget for CSV and JSON export
class ExportButton extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String? filename;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const ExportButton({
    super.key,
    required this.title,
    required this.data,
    this.filename,
    this.onSuccess,
    this.onError,
  });

  @override
  State<ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends State<ExportButton> {
  bool _isLoading = false;

  Future<void> _exportAsCSV() async {
    if (widget.data.isEmpty) {
      _showMessage('Aucune donnée à exporter', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get all unique keys from data
      final Set<String> keys = {};
      for (var item in widget.data) {
        keys.addAll(item.keys);
      }
      final headers = keys.toList();

      // Build CSV content
      final List<List<dynamic>> rows = [
        headers,
        ...widget.data.map((item) {
          return headers.map((key) => item[key] ?? '').toList();
        }),
      ];

      final csv = const ListToCsvConverter().convert(rows);

      // Get downloads directory (or use temp)
      final String filename = widget.filename ?? 'export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final File file = File('${appDocDir.path}/$filename');

      await file.writeAsString(csv, encoding: utf8);

      if (!mounted) return;
      _showMessage('Exporté vers:\n${file.path}');
      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erreur: $e', isError: true);
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Exporter en CSV',
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _exportAsCSV,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.download),
        label: const Text('Exporter CSV'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
