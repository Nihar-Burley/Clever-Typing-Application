import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class UsageHistoryEntry {
  const UsageHistoryEntry({
    required this.id,
    required this.feature,
    required this.action,
    required this.inputPreview,
    required this.outputPreview,
    required this.wasSuccessful,
    required this.createdAt,
  });

  final int id;
  final String feature;
  final String action;
  final String? inputPreview;
  final String? outputPreview;
  final bool wasSuccessful;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'feature': feature,
      'action': action,
      'inputPreview': inputPreview,
      'outputPreview': outputPreview,
      'wasSuccessful': wasSuccessful,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ConsentLogEntry {
  const ConsentLogEntry({
    required this.id,
    required this.consentType,
    required this.wasGranted,
    required this.metadata,
    required this.createdAt,
  });

  final int id;
  final String consentType;
  final bool wasGranted;
  final String? metadata;
  final DateTime createdAt;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'consentType': consentType,
      'wasGranted': wasGranted,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PrivacyDashboardSnapshot {
  const PrivacyDashboardSnapshot({
    required this.usageHistory,
    required this.consentLogs,
  });

  final List<UsageHistoryEntry> usageHistory;
  final List<ConsentLogEntry> consentLogs;

  String toExportJson() {
    return const JsonEncoder.withIndent('  ').convert(
      <String, Object?>{
        'usageHistory': usageHistory.map((entry) => entry.toJson()).toList(),
        'consentLogs': consentLogs.map((entry) => entry.toJson()).toList(),
      },
    );
  }
}

/// Persists usage history and privacy consent logs.
class PrivacyRepository {
  const PrivacyRepository(this._database);

  final AppDatabase _database;

  Future<void> recordUsage({
    required String feature,
    required String action,
    String? inputPreview,
    String? outputPreview,
    required bool wasSuccessful,
  }) async {
    final Database db = await _database.instance;
    await db.insert(
      'usage_history',
      <String, Object?>{
        'feature': feature,
        'action': action,
        'inputPreview': inputPreview,
        'outputPreview': outputPreview,
        'wasSuccessful': wasSuccessful ? 1 : 0,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> recordConsent({
    required String consentType,
    required bool wasGranted,
    String? metadata,
  }) async {
    final Database db = await _database.instance;
    await db.insert(
      'consent_logs',
      <String, Object?>{
        'consentType': consentType,
        'wasGranted': wasGranted ? 1 : 0,
        'metadata': metadata,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<PrivacyDashboardSnapshot> loadDashboard() async {
    final Database db = await _database.instance;
    final List<Map<String, Object?>> usageRows = await db.query(
      'usage_history',
      orderBy: 'createdAt DESC',
      limit: 20,
    );
    final List<Map<String, Object?>> consentRows = await db.query(
      'consent_logs',
      orderBy: 'createdAt DESC',
      limit: 20,
    );
    return PrivacyDashboardSnapshot(
      usageHistory: usageRows.map(_usageFromRow).toList(),
      consentLogs: consentRows.map(_consentFromRow).toList(),
    );
  }

  Future<int> countUsageSince(DateTime since) async {
    final Database db = await _database.instance;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
        SELECT COUNT(*) AS total
        FROM usage_history
        WHERE createdAt >= ?
      ''',
      <Object?>[since.toIso8601String()],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<void> clearAll() async {
    final Database db = await _database.instance;
    await db.delete('usage_history');
    await db.delete('consent_logs');
    await db.delete('assistants');
  }

  UsageHistoryEntry _usageFromRow(Map<String, Object?> row) {
    return UsageHistoryEntry(
      id: row['id'] as int,
      feature: row['feature'] as String,
      action: row['action'] as String,
      inputPreview: row['inputPreview'] as String?,
      outputPreview: row['outputPreview'] as String?,
      wasSuccessful: (row['wasSuccessful'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }

  ConsentLogEntry _consentFromRow(Map<String, Object?> row) {
    return ConsentLogEntry(
      id: row['id'] as int,
      consentType: row['consentType'] as String,
      wasGranted: (row['wasGranted'] as int? ?? 0) == 1,
      metadata: row['metadata'] as String?,
      createdAt: DateTime.parse(row['createdAt'] as String),
    );
  }
}
