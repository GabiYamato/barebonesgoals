import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tracker_data.dart';
import '../services/storage_service.dart';
import '../theme/neo_brutalist_theme.dart';

class ImportExportScreen extends StatefulWidget {
  final Function(TrackerData)? onDataChanged;

  const ImportExportScreen({
    super.key,
    this.onDataChanged,
  });

  @override
  State<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends State<ImportExportScreen> {
  final TextEditingController _importController = TextEditingController();
  String? _exportedData;
  bool _isExporting = false;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _importData() async {
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
      _showMessage('Invalid data format. Please check and try again.', isError: true);
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final data = await StorageService.loadData();
      final jsonString = jsonEncode(data.toJson());
      
      setState(() {
        _exportedData = jsonString;
        _isExporting = false;
      });
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
      appBar: AppBar(
        title: const Text('Import / Export Data'),
      ),
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
                    'Paste your exported data or enter a dev code below:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _importController,
                    maxLines: 5,
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
                  ElevatedButton.icon(
                    onPressed: _importData,
                    icon: const Icon(Icons.download),
                    label: const Text('Import'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
                    'Export your data to back it up or transfer to another device:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_exportedData != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _exportedData!.length > 200 
                                ? '${_exportedData!.substring(0, 200)}...'
                                : _exportedData!,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 12),
                  ],
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportData,
                    icon: _isExporting 
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.upload),
                    label: Text(_exportedData != null ? 'Export Again' : 'Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.completedColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
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
