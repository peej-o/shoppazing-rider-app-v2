import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RiderOrdersDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rider_orders.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE rider_orders (
            orderHeaderId INTEGER PRIMARY KEY,
            orderJson TEXT NOT NULL,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE accepted_orders (
            orderHeaderId INTEGER PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE load_transactions (
            id TEXT PRIMARY KEY,
            dateLoaded TEXT,
            amount REAL,
            remarks TEXT,
            referenceNo TEXT,
            isConfirmed INTEGER DEFAULT 0,
            lastUpdated TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveLoadTransactions(List<dynamic> transactions) async {
    final db = await database;
    final batch = db.batch();

    for (final tx in transactions) {
      final id = tx['Id'] ?? tx['id'] ?? tx['ID'] ?? '';
      final dateLoaded = tx['DateLoaded'] ?? tx['dateLoaded'] ?? '';
      final amount = tx['Amount'] ?? tx['amount'] ?? 0.0;
      final remarks = tx['Remarks'] ?? tx['remarks'] ?? '';
      final referenceNo =
          tx['ReferrenceNo'] ?? tx['ReferenceNo'] ?? tx['referenceNo'] ?? '';
      final isConfirmed = tx['IsConfirmed'] ?? tx['isConfirmed'] ?? false;

      if (id.toString().isEmpty || referenceNo.toString().isEmpty) continue;

      batch.insert('load_transactions', {
        'id': id.toString(),
        'dateLoaded': dateLoaded.toString(),
        'amount': amount is num
            ? amount
            : double.tryParse(amount.toString()) ?? 0.0,
        'remarks': remarks.toString(),
        'referenceNo': referenceNo.toString(),
        'isConfirmed': (isConfirmed == true || isConfirmed == 1) ? 1 : 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getLoadTransactions() async {
    final db = await database;
    return await db.query('load_transactions', orderBy: 'dateLoaded DESC');
  }

  static Future<void> clearLoadTransactions() async {
    final db = await database;
    await db.delete('load_transactions');
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('rider_orders');
    await db.delete('accepted_orders');
    await db.delete('load_transactions');
  }
}
