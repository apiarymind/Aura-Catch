import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'skins/hunter_skin.dart';
import 'skins/style_skin.dart';
import 'skins/original_skin.dart';

enum AppThemeSkin { hunter, style, original }

const String themeSkinPrefKey = 'active_skin';

String appThemeSkinToStorageValue(AppThemeSkin skin) {
  switch (skin) {
    case AppThemeSkin.hunter:
      return 'HUNTER';
    case AppThemeSkin.style:
      return 'STYLE';
    case AppThemeSkin.original:
      return 'Original Aura Catch';
  }
}

AppThemeSkin appThemeSkinFromStorageValue(String? value) {
  switch (value?.toUpperCase()) {
    case 'HUNTER':
      return AppThemeSkin.hunter;
    case 'STYLE':
      return AppThemeSkin.style;
    case 'ORIGINAL AURA CATCH':
    case 'UNISEX': // keep backwards compatibility for users who had it saved
    default:
      return AppThemeSkin.original;
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final initialThemeSkinProvider = Provider<AppThemeSkin>((ref) {
  return AppThemeSkin.original;
});

class ThemeNotifier extends Notifier<AppThemeSkin> {
  SupabaseClient get _client => Supabase.instance.client;
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AppThemeSkin build() {
    final initialSkin = ref.read(initialThemeSkinProvider);

    _authSubscription ??= _client.auth.onAuthStateChange.listen((_) {
      _syncSkinFromCloudMaster();
    });
    ref.onDispose(() {
      _authSubscription?.cancel();
      _authSubscription = null;
    });

    _syncSkinFromCloudMaster();
    return initialSkin;
  }

  Future<void> setSkin(AppThemeSkin skin) async {
    state = skin;
    await _saveSkinToLocal(skin);
    await _saveSkinToCloud(skin);
  }

  Future<void> _saveSkinToLocal(AppThemeSkin skin) async {
    await _prefs.setString(themeSkinPrefKey, appThemeSkinToStorageValue(skin));
  }

  Future<void> _syncSkinFromCloudMaster() async {
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final response = await _client
          .from('users')
          .select('active_skin')
          .eq('id', user.id)
          .maybeSingle();

      final cloudSkinRaw = response?['active_skin'] as String?;
      if (cloudSkinRaw == null) return;

      final cloudSkin = appThemeSkinFromStorageValue(cloudSkinRaw);
      final localSkin = appThemeSkinFromStorageValue(_prefs.getString(themeSkinPrefKey));

      if (cloudSkin != localSkin) {
        state = cloudSkin;
        await _saveSkinToLocal(cloudSkin);
      }
    } catch (_) {
      // Keep local value if cloud sync fails.
    }
  }

  Future<void> _saveSkinToCloud(AppThemeSkin skin) async {
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      await _client.from('users').upsert({
        'id': user.id,
        'active_skin': appThemeSkinToStorageValue(skin),
      });
    } catch (_) {
      // Keep local selection even if cloud write fails.
    }
  }

  ThemeData get currentThemeData {
    switch (state) {
      case AppThemeSkin.hunter:
        return hunterTheme;
      case AppThemeSkin.style:
        return styleTheme;
      case AppThemeSkin.original:
        return originalTheme;
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeSkin>(() {
  return ThemeNotifier();
});
