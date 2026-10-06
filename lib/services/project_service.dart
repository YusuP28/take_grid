import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/grid_project.dart';
import '../models/grid_template.dart';

/// Wrapper metadata project untuk list di home screen.
class ProjectMeta {
  final int id;
  final String name;
  final String templateId;
  final String? thumbnailPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int filledCount;
  final int cellCount;

  ProjectMeta({
    required this.id,
    required this.name,
    required this.templateId,
    required this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
    required this.filledCount,
    required this.cellCount,
  });
}

class ProjectService {
  static const _dbName = 'take_grid_projects.db';
  static const _dbVersion = 1;
  static const _table = 'projects';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            template_id TEXT NOT NULL,
            json_data TEXT NOT NULL,
            thumbnail_path TEXT,
            filled_count INTEGER NOT NULL DEFAULT 0,
            cell_count INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_updated_at ON $_table(updated_at DESC)',
        );
      },
    );
    return _db!;
  }

  /// Simpan project baru. Return id.
  Future<int> saveProject(GridProject project, {String? name}) async {
    final db = await _open();
    final now = DateTime.now().millisecondsSinceEpoch;
    final projectName = name ?? _autoName(project);
    final json = jsonEncode(project.toJson());
    return db.insert(_table, {
      'name': projectName,
      'template_id': project.template.id,
      'json_data': json,
      'thumbnail_path': null,
      'filled_count': project.filledCount,
      'cell_count': project.template.cellCount,
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Update project existing. Return jumlah row ter-update.
  Future<int> updateProject(int id, GridProject project, {String? name}) async {
    final db = await _open();
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = <String, dynamic>{
      'json_data': jsonEncode(project.toJson()),
      'filled_count': project.filledCount,
      'cell_count': project.template.cellCount,
      'updated_at': now,
    };
    if (name != null) map['name'] = name;
    return db.update(_table, map, where: 'id = ?', whereArgs: [id]);
  }

  /// Set thumbnail path untuk project.
  Future<void> updateThumbnail(int id, String thumbnailPath) async {
    final db = await _open();
    await db.update(
      _table,
      {'thumbnail_path': thumbnailPath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Load full project. Return null kalau tidak ditemukan / template invalid.
  Future<GridProject?> loadProject(int id) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    final templateId = row['template_id'] as String;
    final template = GridTemplates.byId(templateId);
    if (template == null) return null;

    try {
      final json = jsonDecode(row['json_data'] as String) as Map<String, dynamic>;
      return GridProject.fromJson(json, template);
    } catch (e) {
      return null;
    }
  }

  /// List project meta, urut updated_at DESC.
  Future<List<ProjectMeta>> listProjects() async {
    final db = await _open();
    final rows = await db.query(_table, orderBy: 'updated_at DESC');
    return rows.map((r) => ProjectMeta(
          id: r['id'] as int,
          name: r['name'] as String,
          templateId: r['template_id'] as String,
          thumbnailPath: r['thumbnail_path'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int),
          filledCount: r['filled_count'] as int,
          cellCount: r['cell_count'] as int,
        )).toList();
  }

  /// Hapus project. Return jumlah row terhapus.
  Future<int> deleteProject(int id) async {
    final db = await _open();
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// Hapus semua project (untuk testing).
  Future<void> deleteAll() async {
    final db = await _open();
    await db.delete(_table);
  }

  /// Cek project exists.
  Future<bool> exists(int id) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Cari file thumbnail yang valid (kalau ada).
  Future<String?> getValidThumbnail(int id) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      columns: ['thumbnail_path'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final path = rows.first['thumbnail_path'] as String?;
    if (path == null) return null;
    if (!File(path).existsSync()) return null;
    return path;
  }

  String _autoName(GridProject project) {
    final now = DateTime.now();
    final ts = '${now.day}/${now.month} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    return '${project.template.name} · $ts';
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
