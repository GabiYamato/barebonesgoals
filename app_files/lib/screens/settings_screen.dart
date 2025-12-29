import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/tracker_data.dart';
import '../services/storage_service.dart';
import '../theme/neo_brutalist_theme.dart';
import 'import_export_screen.dart';

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;
  final Function(TrackerData)? onDataChanged;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    this.onDataChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() {
      _settings = newSettings;
    });
    widget.onSettingsChanged(newSettings);
  }

  void _navigateToImportExport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ImportExportScreen(onDataChanged: widget.onDataChanged),
      ),
    );
  }

  Future<void> _clearAllData() async {
    final emptyData = TrackerData.empty();
    await StorageService.saveData(emptyData);
    widget.onDataChanged?.call(emptyData);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showClearDataConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              offset: Offset(6, 6),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Clear All Data?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'This will delete all your tasks and history.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _NeoButton(
                        label: 'Clear All Data',
                        background: Colors.red,
                        foreground: Colors.white,
                        onTap: () {
                          Navigator.of(context).pop();
                          _clearAllData();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _NeoButton(
                        label: 'Cancel',
                        background: Colors.black,
                        foreground: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _buildSectionCard(
            title: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dark Mode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use a dark neo-brutalist theme',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _settings.isDarkMode,
                      onChanged: (value) {
                        _updateSettings(_settings.copyWith(isDarkMode: value));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Task Section Settings
          _buildSectionCard(
            title: 'Task Section',
            children: [
              _buildSliderTile(
                title: 'Days Shown',
                value: _settings.daysShownInTaskSection.toDouble(),
                min: 3,
                max: 14,
                divisions: 11,
                onChanged: (value) {
                  _updateSettings(
                    _settings.copyWith(
                      daysShownInTaskSection: value.toInt(),
                      daysShownInGraph: value.toInt(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.shade200),
              // Sort completed to bottom setting
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sort Completed to Bottom',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Move completed tasks below incomplete ones',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _settings.sortCompletedToBottom,
                      onChanged: (value) {
                        _updateSettings(
                          _settings.copyWith(sortCompletedToBottom: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Graph Settings Section
          _buildSectionCard(
            title: 'Graph Settings',
            children: [
              // Show History in Graph
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Show History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Include historical data beyond visible days',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _settings.showHistoryInGraph,
                      onChanged: (value) {
                        _updateSettings(
                          _settings.copyWith(showHistoryInGraph: value),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Show Chart as Overlay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Float the chart above tasks instead of below',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _settings.chartAsOverlay,
                      onChanged: (value) {
                        _updateSettings(
                          _settings.copyWith(chartAsOverlay: value),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Graph Type
              InkWell(
                onTap: () => _showGraphTypeSheet(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Graph Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            AppSettings.graphTypeToString(_settings.graphType),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Theme Section
          _buildSectionCard(
            title: 'Theme',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color Scheme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose the look and feel of the app',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildThemeOption(
                      scheme: ThemeScheme.palette,
                      title: 'Bold Pink',
                      description: 'Black, pink, and light grey palette',
                    ),
                    const SizedBox(height: 8),
                    _buildThemeOption(
                      scheme: ThemeScheme.classic,
                      title: 'Classic Green',
                      description: 'White with green and blue accents',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Data Management Section
          _buildSectionCard(
            title: 'Data',
            children: [
              InkWell(
                onTap: _navigateToImportExport,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.sync_alt,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Import or Export Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.grey.shade200),
              InkWell(
                onTap: _showClearDataConfirmation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Clear All Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionCard(
            title: 'About',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.task_alt, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Tracker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(6, 6), blurRadius: 0, color: Colors.black12),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  '${value.toInt()} days',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showGraphTypeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              offset: Offset(6, 6),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Select Graph Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...GraphType.values.map(
                (type) => Column(
                  children: [
                    const Divider(height: 1),
                    InkWell(
                      onTap: () {
                        _updateSettings(_settings.copyWith(graphType: type));
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppSettings.graphTypeToString(type),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: _settings.graphType == type
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: _settings.graphType == type
                                    ? AppTheme.chartColor
                                    : Colors.black,
                              ),
                            ),
                            if (_settings.graphType == type) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check,
                                color: AppTheme.chartColor,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: _NeoButton(
                  label: 'Cancel',
                  background: Colors.black,
                  foreground: Colors.white,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required ThemeScheme scheme,
    required String title,
    required String description,
  }) {
    final isSelected = _settings.themeScheme == scheme;
    return InkWell(
      borderRadius: BorderRadius.circular(1),
      onTap: () {
        _updateSettings(_settings.copyWith(themeScheme: scheme));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    offset: Offset(4, 4),
                    blurRadius: 0,
                    color: Colors.black12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(1),
                border: Border.all(color: Colors.black, width: 1.6),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _NeoButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _NeoButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.6),
          boxShadow: const [
            BoxShadow(
              offset: Offset(4, 4),
              blurRadius: 0,
              color: Colors.black12,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
