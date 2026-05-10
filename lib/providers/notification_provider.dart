import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettings {
  final bool immediateAlerts;
  final bool dailySummary;
  final TimeOfDay summaryTime;

  NotificationSettings({
    this.immediateAlerts = true, 
    this.dailySummary = false,
    this.summaryTime = const TimeOfDay(hour: 20, minute: 0),
  });

  NotificationSettings copyWith({
    bool? immediateAlerts, 
    bool? dailySummary,
    TimeOfDay? summaryTime,
  }) {
    return NotificationSettings(
      immediateAlerts: immediateAlerts ?? this.immediateAlerts,
      dailySummary: dailySummary ?? this.dailySummary,
      summaryTime: summaryTime ?? this.summaryTime,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    return NotificationSettings();
  }

  void toggleImmediateAlerts(bool value) {
    state = state.copyWith(immediateAlerts: value);
  }

  void toggleDailySummary(bool value) {
    state = state.copyWith(dailySummary: value);
  }

  void setSummaryTime(TimeOfDay time) {
    state = state.copyWith(summaryTime: time);
  }
}

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationSettings>(() {
  return NotificationNotifier();
});
