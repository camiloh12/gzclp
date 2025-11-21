import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/local/app_database.dart';

/// Settings page for app configuration and preferences
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _database = sl<AppDatabase>();
  bool _isLoading = true;
  UserPreference? _preferences;
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _database.userPreferencesDao.getPreferences();
      setState(() {
        _preferences = prefs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Failed to load settings: $e');
      }
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'Unknown';
      });
    }
  }

  Future<void> _updateUnitSystem(String unitSystem) async {
    try {
      await _database.userPreferencesDao.updatePreferenceFields(
        unitSystem: unitSystem,
      );
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unit system changed to ${unitSystem == AppConstants.unitSystemMetric ? "Metric" : "Imperial"}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to update unit system: $e');
    }
  }

  Future<void> _updateRestTime(String tier, int seconds) async {
    try {
      switch (tier) {
        case 'T1':
          await _database.userPreferencesDao.updatePreferenceFields(
            t1RestSeconds: seconds,
          );
          break;
        case 'T2':
          await _database.userPreferencesDao.updatePreferenceFields(
            t2RestSeconds: seconds,
          );
          break;
        case 'T3':
          await _database.userPreferencesDao.updatePreferenceFields(
            t3RestSeconds: seconds,
          );
          break;
      }
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tier rest time updated to ${seconds}s'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to update rest time: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _preferences == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Failed to load preferences'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: [
                    // Unit System
                    _buildSectionHeader('Units'),
                    ListTile(
                      leading: const Icon(Icons.straighten),
                      title: const Text('Unit System'),
                      subtitle: Text(_preferences!.unitSystem == AppConstants.unitSystemMetric ? 'Metric (kg)' : 'Imperial (lbs)'),
                      trailing: Switch(
                        value: _preferences!.unitSystem == AppConstants.unitSystemMetric,
                        onChanged: (value) {
                          _updateUnitSystem(
                            value ? AppConstants.unitSystemMetric : AppConstants.unitSystemImperial,
                          );
                        },
                      ),
                    ),
                    const Divider(),

                    // Rest Times
                    _buildSectionHeader('Rest Times'),
                    _buildRestTimeTile('T1', _preferences!.t1RestSeconds, Colors.red),
                    _buildRestTimeTile('T2', _preferences!.t2RestSeconds, Colors.blue),
                    _buildRestTimeTile('T3', _preferences!.t3RestSeconds, Colors.green),
                    const Divider(),

                    // Data Management
                    _buildSectionHeader('Data Management'),
                    ListTile(
                      leading: const Icon(Icons.upload_file),
                      title: const Text('Export Data'),
                      subtitle: const Text('Export workout data as JSON'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoon('Export Data'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Import Data'),
                      subtitle: const Text('Restore from backup'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoon('Import Data'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Clear All Data'),
                      subtitle: const Text('Delete all workouts and reset app'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _confirmClearData,
                    ),
                    const Divider(),

                    // About
                    _buildSectionHeader('About'),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Version'),
                      subtitle: Text(_appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Help & FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showComingSoon('Help & FAQ'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('About GZCLP'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showAboutDialog,
                    ),
                  ],
                ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildRestTimeTile(String tier, int currentSeconds, Color color) {
    final minutes = currentSeconds ~/ 60;
    final seconds = currentSeconds % 60;
    final displayText = seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            tier,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text('$tier Rest Time'),
      subtitle: Text(displayText),
      trailing: const Icon(Icons.edit),
      onTap: () => _showRestTimeDialog(tier, currentSeconds),
    );
  }

  Future<void> _showRestTimeDialog(String tier, int currentSeconds) async {
    final controller = TextEditingController(text: currentSeconds.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $tier Rest Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Rest time (seconds)',
                suffixText: 'seconds',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended: ${_getRecommendedRestTime(tier)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 600) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _updateRestTime(tier, result);
    }
  }

  String _getRecommendedRestTime(String tier) {
    switch (tier) {
      case 'T1':
        return '3-5 minutes';
      case 'T2':
        return '2-3 minutes';
      case 'T3':
        return '1-2 minutes';
      default:
        return '';
    }
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your workouts, progress, and settings. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement data clearing logic
      _showComingSoon('Clear All Data');
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About GZCLP'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GZCLP Workout Tracker',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'This app helps you track and manage your GZCLP (Cody Lefever\'s GZCL Linear Progression) workouts.',
              ),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Automatic workout generation'),
              Text('• Intelligent progression tracking'),
              Text('• AMRAP set guidance'),
              Text('• Workout history and analytics'),
              Text('• Notes and annotations'),
              Text('• Rest timer'),
              SizedBox(height: 16),
              Text(
                'GZCLP is a beginner-friendly linear progression program that uses a three-tier system (T1, T2, T3) with automatic progression and reset mechanisms.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
