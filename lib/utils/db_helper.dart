import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tailor_tools/models/contact.dart';

class DbHelper {
  static const dbName = "ContactData.db";
  static const dbVersion = 1;

  //singleton Class
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(dataDirectory.path, dbName);
    return await openDatabase(dbPath,
        version: dbVersion, onCreate: _onCreateDb);
  }

  _onCreateDb(Database db, int versionNumber) async {
    String sql = '''
      CREATE TABLE ${Contact.tblContact}(
        ${Contact.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Contact.colName} VARCHAR(255) NOT NULL,
        ${Contact.colMobileNumber} VARCHAR(255) NOT NULL,        
        ${Contact.colpGuthan} VARCHAR(255) NULL,
        ${Contact.colpJhang} VARCHAR(255) NULL,
        ${Contact.colpKammar} VARCHAR(255) NULL,
        ${Contact.colpLambai} VARCHAR(255) NULL,
        ${Contact.colpLangot} VARCHAR(255) NULL,
        ${Contact.colpMori} VARCHAR(255) NULL,
        ${Contact.colpSeat} VARCHAR(255) NULL,
        ${Contact.colpdFly} VARCHAR(255) NULL,
        ${Contact.colsBay} VARCHAR(255) NULL,
        ${Contact.colsBeg} VARCHAR(255) NULL,
        ${Contact.colsChest} VARCHAR(255) NULL,
        ${Contact.colsColler} VARCHAR(255) NULL,
        ${Contact.colsKammar} VARCHAR(255) NULL,
        ${Contact.colsLambai} VARCHAR(255) NULL,
        ${Contact.colsShoulder} VARCHAR(255) NULL
      )
    ''';
    await db.execute(sql);
  }

  Future<Contact?> getContactById(int contactId) async {
    Database? db = await database;

    List<Map> contacts = await db!.query(
      Contact.tblContact,
      where: "${Contact.colId} = ?",
      whereArgs: [contactId],
    );
    return contacts.isEmpty
        ? null
        : contacts.map((contact) => Contact.fromMap(contact)).toList()[0];
  }

  Future<int> insertContact(Contact contact) async {
    Database? db = await database;
    return await db!.insert(Contact.tblContact, contact.toMap());
  }

  Future<int> updateContact(Contact contact) async {
    Database? db = await database;
    return await db!.update(Contact.tblContact, contact.toMap(),
        where: '${Contact.colId} = ?', whereArgs: [contact.id]);
  }

  Future<int> deleteContact(Contact contact) async {
    Database? db = await database;
    return await db!.delete(Contact.tblContact,
        where: '${Contact.colId} = ?', whereArgs: [contact.id]);
  }

  Future<List<Contact>> fetchContacts() async {
    Database? db = await database;
    List<Map> contacts = await db!.query(Contact.tblContact);
    return contacts.isEmpty
        ? []
        : contacts.map((contact) => Contact.fromMap(contact)).toList();
  }
}
