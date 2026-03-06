// lib/services/database/user_session_db.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserSessionDB {
  static Completer<Database>? _dbCompleter;

  static Future<Database> get database async {
    if (_dbCompleter == null) {
      _dbCompleter = Completer();
      _initDB()
          .then((db) {
            _dbCompleter!.complete(db);
          })
          .catchError((error, stackTrace) {
            _dbCompleter!.completeError(error, stackTrace);
            _dbCompleter = null;
          });
    }
    return _dbCompleter!.future;
  }

  static Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'user_session.db');

      final db = await openDatabase(
        path,
        version: 2, // ← Changed from 1 to 2
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              access_token TEXT NOT NULL,
              token_type TEXT NOT NULL,
              expires_in INTEGER NOT NULL,
              email TEXT NOT NULL,
              business_name TEXT NOT NULL,
              merchant_id TEXT NOT NULL,
              user_id TEXT NOT NULL,
              firstname TEXT NOT NULL,
              lastname TEXT NOT NULL,
              mobile_no TEXT NOT NULL,
              mobile_confirmed TEXT NOT NULL,
              rider_id TEXT NOT NULL,
              role_name TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Drop old table and create new one without issued/expires
            await db.execute('DROP TABLE IF EXISTS users');
            await db.execute('''
              CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                access_token TEXT NOT NULL,
                token_type TEXT NOT NULL,
                expires_in INTEGER NOT NULL,
                email TEXT NOT NULL,
                business_name TEXT NOT NULL,
                merchant_id TEXT NOT NULL,
                user_id TEXT NOT NULL,
                firstname TEXT NOT NULL,
                lastname TEXT NOT NULL,
                mobile_no TEXT NOT NULL,
                mobile_confirmed TEXT NOT NULL,
                rider_id TEXT NOT NULL,
                role_name TEXT NOT NULL
              )
            ''');
          }
        },
      );
      return db;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveSession({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    required String email,
    required String businessName,
    required String merchantId,
    required String userId,
    required String firstname,
    required String lastname,
    required String mobileNo,
    required String mobileConfirmed,
    required String riderId,
    required String roleName,
    String? issued,
    String? expires,
  }) async {
    try {
      final db = await database;
      await db.delete('users');

      final sessionData = {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'email': email,
        'business_name': businessName,
        'merchant_id': merchantId,
        'user_id': userId,
        'firstname': firstname,
        'lastname': lastname,
        'mobile_no': mobileNo,
        'mobile_confirmed': mobileConfirmed,
        'rider_id': riderId,
        'role_name': roleName,
      };

      await db.insert('users', sessionData);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getSession() async {
    try {
      final db = await database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSession() async {
    final db = await database;
    await db.delete('users');
  }

  static Future<bool> isSessionValid() async {
    final session = await getSession();
    if (session == null) return false;
    return true;
  }
}
