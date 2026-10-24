import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/app_database.dart';
import '../../domain/entities/assistant_template.dart';

class AssistantCatalogLocalDataSource {
  const AssistantCatalogLocalDataSource(this._database);

  final AppDatabase _database;

  Future<List<AssistantTemplate>> readAll() async {
    final Database db = await _database.instance;
    final List<Map<String, Object?>> rows = await db.query(
      'assistants',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return rows.map(_fromRow).toList();
  }

  Future<void> upsertAll(List<AssistantTemplate> assistants) async {
    final Database db = await _database.instance;
    final Batch batch = db.batch();
    for (final AssistantTemplate assistant in assistants) {
      batch.insert(
        'assistants',
        _toRow(assistant),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsert(AssistantTemplate assistant) async {
    final Database db = await _database.instance;
    await db.insert(
      'assistants',
      _toRow(assistant),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String assistantId) async {
    final Database db = await _database.instance;
    await db.delete(
      'assistants',
      where: 'id = ?',
      whereArgs: <Object?>[assistantId],
    );
  }

  Map<String, Object?> _toRow(AssistantTemplate assistant) {
    return <String, Object?>{
      'id': assistant.id,
      'name': assistant.name,
      'description': assistant.description,
      'promptIntent': assistant.promptIntent,
      'promptTemplate': assistant.promptTemplate,
      'isPremium': assistant.isPremium ? 1 : 0,
      'isCustom': assistant.isCustom ? 1 : 0,
      'isPinned': assistant.isPinned ? 1 : 0,
      'updatedAt': assistant.updatedAt.toIso8601String(),
    };
  }

  AssistantTemplate _fromRow(Map<String, Object?> row) {
    return AssistantTemplate(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      promptIntent: row['promptIntent'] as String,
      promptTemplate: row['promptTemplate'] as String,
      isPremium: (row['isPremium'] as int? ?? 0) == 1,
      isCustom: (row['isCustom'] as int? ?? 0) == 1,
      isPinned: (row['isPinned'] as int? ?? 0) == 1,
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }
}
