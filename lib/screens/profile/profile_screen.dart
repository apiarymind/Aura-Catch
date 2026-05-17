import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme_provider.dart';
import '../../providers/region_provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with WidgetsBindingObserver {
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _micStatus = PermissionStatus.denied;
  PermissionStatus _speechStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final camera = await Permission.camera.status;
    final mic = await Permission.microphone.status;
    // Android speech_to_text uses Permission.speech on some versions
    final speech = await Permission.speech.status;
    if (mounted) {
      setState(() {
        _cameraStatus = camera;
        _micStatus = mic;
        _speechStatus = speech;
      });
    }
  }

  bool get _isMicEffectivelyGranted =>
      _micStatus.isGranted || _speechStatus.isGranted;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final currentRegion = ref.watch(regionProvider);
    final strings = ref.watch(localizationProvider);
    final notifications = ref.watch(notificationProvider);
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.profileSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strings.themeSkin, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Skin Selector', style: themeData.textTheme.labelLarge),
          const SizedBox(height: 8),
          _buildSkinCard(
            context: context,
            ref: ref,
            skin: AppThemeSkin.hunter,
            currentTheme: currentTheme,
            title: 'HUNTER',
            subtitle: 'Neon Green & Black',
            swatchGradient: const LinearGradient(
              colors: [Color(0xFF39FF14), Color(0xFF121212)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 10),
          _buildSkinCard(
            context: context,
            ref: ref,
            skin: AppThemeSkin.style,
            currentTheme: currentTheme,
            title: 'STYLE',
            subtitle: 'Rose Gold & Pink',
            swatchGradient: const LinearGradient(
              colors: [Color(0xFFE5A9A9), Color(0xFFFFF0F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          const SizedBox(height: 10),
          _buildSkinCard(
            context: context,
            ref: ref,
            skin: AppThemeSkin.original,
            currentTheme: currentTheme,
            title: 'Original Aura Catch',
            subtitle: 'Royal Blue & Light',
            swatchGradient: const LinearGradient(
              colors: [Color(0xFF1B365D), Color(0xFFE5E7EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Privacy & Permissions Block
          Text('Prywatność i Uprawnienia', style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: themeData.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Aparat'),
                  subtitle: const Text('Skanowanie produktów. AI analizuje obraz w locie. Zero zapisu na serwerze.', style: TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _cameraStatus.isGranted ? 'Włączone' : 'Wyłączone',
                        style: TextStyle(
                          color: _cameraStatus.isGranted ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Otwórz ustawienia systemowe',
                        onPressed: () async {
                          await openAppSettings();
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    var status = await Permission.camera.status;
                    if (status.isGranted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Uprawnienie jest już aktywne')),
                        );
                      }
                    } else if (status.isPermanentlyDenied) {
                      await openAppSettings();
                    } else {
                      await Permission.camera.request();
                      await _checkPermissions();
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text('Mikrofon'),
                  subtitle: const Text('Wyszukiwanie głosowe. Analiza w czasie rzeczywistym. Zero zapisu na serwerze.', style: TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isMicEffectivelyGranted ? 'Włączone' : 'Wyłączone',
                        style: TextStyle(
                          color: _isMicEffectivelyGranted ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: 'Otwórz ustawienia systemowe',
                        onPressed: () async {
                          await openAppSettings();
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    // Check both mic and speech permissions (speech_to_text uses both on Android)
                    var micStatus = await Permission.microphone.status;
                    var speechStatus = await Permission.speech.status;
                    final effectivelyGranted = micStatus.isGranted || speechStatus.isGranted;

                    if (effectivelyGranted) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Uprawnienie jest już aktywne')),
                        );
                      }
                    } else if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
                      await openAppSettings();
                    } else {
                      await Permission.microphone.request();
                      await Permission.speech.request();
                      await _checkPermissions();
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(strings.notifications, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: themeData.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(strings.immediateAlerts, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(strings.immediateAlertsDesc, style: const TextStyle(fontSize: 12)),
                  value: notifications.immediateAlerts,
                  onChanged: (val) => ref.read(notificationProvider.notifier).toggleImmediateAlerts(val),
                  activeThumbColor: themeData.primaryColor,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(strings.dailySummary, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(strings.dailySummaryDesc, style: const TextStyle(fontSize: 12)),
                  value: notifications.dailySummary,
                  onChanged: (val) => ref.read(notificationProvider.notifier).toggleDailySummary(val),
                  activeThumbColor: themeData.primaryColor,
                ),
                if (notifications.dailySummary) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: Text(strings.summaryTime, style: const TextStyle(fontSize: 14)),
                    trailing: Text(
                      notifications.summaryTime.format(context),
                      style: TextStyle(
                        color: themeData.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: notifications.summaryTime,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: themeData.primaryColor,
                                onPrimary: Colors.white,
                                surface: themeData.cardColor,
                                onSurface: themeData.textTheme.bodyLarge!.color!,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        ref.read(notificationProvider.notifier).setSummaryTime(picked);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(strings.regionLanguage, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: currentRegion,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: themeData.cardColor,
            ),
            items: regionsList.map((String region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                ref.read(regionProvider.notifier).setRegion(newValue);
              }
            },
          ),
          const SizedBox(height: 32),
          Text(strings.accountInfo, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          (() {
            final user = ref.watch(authServiceProvider).currentUser;
            final userEmail = user?.email?.trim() ?? '';
            final isAnonymous = user == null || userEmail.isEmpty;

            if (!isAnonymous) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Moje Dane (Supabase)', style: themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeData.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: $userEmail'),
                        const SizedBox(height: 8),
                        Text('UID: ${user.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Data utworzenia: ${user.createdAt}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Usuń konto i dane'),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Usuń konto'),
                          content: const Text('Czy na pewno chcesz usunąć konto? Ta akcja jest nieodwracalna i spowoduje usunięcie wszystkich Twoich danych.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Anuluj'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Usuń'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await ref.read(authServiceProvider).deleteAccount();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Błąd podczas usuwania konta: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: themeData.cardColor,
                    leading: const Icon(Icons.logout, color: Colors.grey),
                    title: Text(tr('logout')),
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                    },
                  ),
                ],
              );
            } else {
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: themeData.cardColor,
                leading: const Icon(Icons.login),
                title: Text(strings.guestUser),
                subtitle: Text(strings.loginRegister),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/login'),
              );
            }
          })(),
        ],
      ),
    );
  }

  Widget _buildSkinCard({
    required BuildContext context,
    required WidgetRef ref,
    required AppThemeSkin skin,
    required AppThemeSkin currentTheme,
    required String title,
    required String subtitle,
    required Gradient swatchGradient,
  }) {
    final themeData = Theme.of(context);
    final isSelected = skin == currentTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => ref.read(themeProvider.notifier).setSkin(skin),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? themeData.primaryColor.withValues(alpha: 0.08)
                : themeData.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? themeData.primaryColor
                  : themeData.dividerColor.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: swatchGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: themeData.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: themeData.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: themeData.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
