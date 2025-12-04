import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/tracker_data.dart';
import '../services/storage_service.dart';
import '../theme/neo_brutalist_theme.dart';

class ImportExportScreen extends StatefulWidget {
  final Function(TrackerData)? onDataChanged;

  const ImportExportScreen({super.key, this.onDataChanged});

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final TextEditingController _importController = TextEditingController();
  String? _exportedData;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _pickAndImportFile() async {
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        
        // Try to parse and import
        final Map<String, dynamic> json = jsonDecode(jsonString);
        final data = TrackerData.fromJson(json);
        await StorageService.saveData(data);
        widget.onDataChanged?.call(data);
        _showMessage('Data imported successfully!');
      }
    } catch (e) {
      _showMessage('Failed to import file. Please check the format.', isError: true);
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _importFromText() async {
    final jsonString = _importController.text.trim();

    if (jsonString.isEmpty) {
      _showMessage('Please paste data to import', isError: true);
      return;
    }

    // Check for dev code
    if (jsonString.toLowerCase() == 'youreadopted') {
      final sampleData = TrackerData.sampleData();
      await StorageService.saveData(sampleData);
      widget.onDataChanged?.call(sampleData);
      _showMessage('Sample data loaded successfully!');
      _importController.clear();
      return;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final data = TrackerData.fromJson(json);
      await StorageService.saveData(data);
      widget.onDataChanged?.call(data);
      _showMessage('Data imported successfully!');
      _importController.clear();
    } catch (e) {
      _showMessage(
        'Invalid data format. Please check and try again.',
        isError: true,
      );
    }
  }

  Future<void> _exportAndSaveFile() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final data = await StorageService.loadData();
      final jsonString = jsonEncode(data.toJson());
      
      // Create a temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/daily_tracker_backup_$timestamp.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      setState(() {
        _exportedData = jsonString;
        _isExporting = false;
      });

      // Share/save the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Daily Tracker Backup',
        text: 'My Daily Tracker data backup',
      );
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      _showMessage('Failed to export data', isError: true);
    }
  }

  void _copyToClipboard() {
    if (_exportedData != null) {
      Clipboard.setData(ClipboardData(text: _exportedData!));
      _showMessage('Data copied to clipboard!');
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : AppTheme.completedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export Data')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Import Section
            _buildSectionCard(
              title: 'Import Data',
              icon: Icons.download_outlined,
              iconColor: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Import from a JSON backup file:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isImporting ? null : _pickAndImportFile,
                    icon: _isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.folder_open),
                    label: const Text('Choose File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Paste JSON data directly:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _importController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Paste JSON data here...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _importFromText,
                    icon: const Icon(Icons.paste),
                    label: const Text('Import from Text'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Export Section
            _buildSectionCard(
              title: 'Export Data',
              icon: Icons.upload_outlined,
              iconColor: AppTheme.completedColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Save your data as a JSON file to back up or transfer:',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportAndSaveFile,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_alt),
                    label: const Text('Export & Save File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.completedColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_exportedData != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, 
                                color: AppTheme.completedColor, 
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Data ready! You can also copy it:',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy to Clipboard'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.completedColor,
                              side: BorderSide(color: AppTheme.completedColor),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}
