import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class BaseDatabaseHelper {
  static final _databaseName = "my_database.db";
  static final _databaseVersion = 1;

  String get tableName;

  List<ColumnDefinition> get allColumns;

  late String primaryKeyName = _getPrimaryKeyName();

  Future<Database> get database async {
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) => _onCreate(db),
      version: _databaseVersion,
    );
  }

  void _onCreate(Database db) async {
    String columnDefinitions =
    allColumns.map((c) => '${c.name} ${c.type} ${(c.isPrivateKey
        ? "PRIMARY KEY": "")}').join(',');
    await db.execute('''
      CREATE TABLE $tableName (
        $columnDefinitions
      )
    ''');
  }

  ///插入数据
  Future<int> insert(Map<String, dynamic> record) async {
    Database db = await database;
    int result = await db.insert(tableName, record);
    await db.close();
    return result;
  }

  ///插入数据
  Future<int> insertItems(List<Map<String, dynamic>> records) async {
    Database db = await database;
    int count = 0;
    Batch batch = db.batch();
    for (var record in records) {
      batch.insert(tableName, record);
      count++;
    }
    await batch.commit(noResult: true);
    await db.close();
    return count;
  }

  ///批量删除
  Future<int> deleteByList(List<String> ids) async {
    Database db = await database;
    String whereClause = ids.map((id) => '?').join(',');
    int result = await db.delete(
      tableName,
      where: '$primaryKeyName IN ($whereClause)',
      whereArgs: ids,
    );
    await db.close();
    return result;
  }

  ///更新数据
  Future<int> update(dynamic id, Map<String, dynamic> record) async {
    Database db = await database;
    int result = await db.update(
      tableName,
      record,
      where: '$primaryKeyName = ?',
      whereArgs: [id],
    );
    await db.close();
    return result;
  }

  ///删除数据
  Future<int> delete(int id) async {
    Database db = await database;
    int result = await db.delete(
      tableName,
      where: '$primaryKeyName = ?',
      whereArgs: [id],
    );
    await db.close();
    return result;
  }

  ///获取所有表数据
  Future<List<Map<String, dynamic>>> getAllRecords() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(tableName);
    db.close();
    return result;
  }

  ///获取单条数据
  Future<Map<String, dynamic>> getRecord(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps =
    await db.query(tableName, where: '$primaryKeyName = ?', whereArgs: [id]);
    Map<String, dynamic> result = {};
    if (maps.isNotEmpty) {
      result = maps.first;
    } else {
      throw Exception('Record not found!');
    }
    db.close();
    return result;
  }

  String _getPrimaryKeyName() {
    ColumnDefinition definition = allColumns.where((element) => element.isPrivateKey).first;
    return definition.name;
  }
}

class ColumnDefinition {
  final String name;
  final String type;
  bool isPrivateKey;

  ColumnDefinition(this.name, this.type, {
    this.isPrivateKey = false
  });
}
