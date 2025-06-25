import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:entrega_app/data/services/theme_service.dart';
import '../widgets/notification_test_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _themeService = ThemeService();
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
    });
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    setState(() {
      _currentThemeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          if (kDebugMode) const NotificationTestWidget(),
          
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(
              _currentThemeMode == ThemeMode.system
                  ? 'Sistema'
                  : _currentThemeMode == ThemeMode.light
                      ? 'Claro'
                      : 'Escuro',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Escolha o tema'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text('Sistema'),
                        value: ThemeMode.system,
                        groupValue: _currentThemeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _updateThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Claro'),
                        value: ThemeMode.light,
                        groupValue: _currentThemeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _updateThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text('Escuro'),
                        value: ThemeMode.dark,
                        groupValue: _currentThemeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            _updateThemeMode(value);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 